# encoding: UTF-8
class Bgu

  def self.course_normalize(course)
    number = course.gsub(/\W+/, '')
    number.slice(0, 3) + "." + number.slice(3, 1) + "." + number.slice(4, 4)
  end

  def self.find_by_number(number, year, semester, university_id)
    self.bgu_find_by_id(number, year, semester, 0, university_id)
  end

  def self.find_by_name(string, year, semester)
    self.bgu_find_by_name(string, year, semester, 0)
  end

  def self.find_sport(string, year, semester, day, hour)
    self.bgu_find_sport(string, year, semester, day, hour)
  end

  def self.bgu_find_by_name (string, year, semester, institution)
    # TODO Use institution
    puts string.encode('windows-1255').encoding
    query = {
        "rc_search" => "advanced",
        "oc_course_name" => string.encode('windows-1255')
    }
        #query['oc_semester'] = 'on' #Take only active courses in current semster

    str = self.http_post("https://bgu4u.bgu.ac.il/pls/scwp/!sc.AnnualSearchResults", query)

    doc = Nokogiri::HTML(str)
    json = {}
    results = []
    # Find current semester name
    hd = doc.css('td.BlueInputKind')
    semester = hd[2].text.trim if hd[2]
    doc.css('td.BlackTextEng').each do |node|
      p = node.parent
      #Hebrew Title
      results.push({'number' => p.css('.BlackText').text.trim,
                    'name' => p.css('a').text.trim,
                    'semester' => semester})
    end
    json['results'] = results
    json['cache'] = false

    json
  end

  def self.bgu_find_sport(institution, year, semester, day, hour)
    # TODO Use institution
    query = {
        "oc_course_name" => "",
        "oc_lecturer_first_name" => "",
        "oc_lecturer_last_name" => "",
        "on_campus" => "",
        "on_course" => "",
        "on_course_degree_level" => "",
        "on_course_department" => 700,
        "on_course_ins" => 0,
        "on_course_ldegree_level" => "",
        "on_course_ldepartment" => "",
        "on_course_lins" => 0,
        "on_credit_points" => "",
        "on_hours" => "",
        "on_semester" => semester,
        "on_year" => year,
        "step" => 1,
        "on_day" + day => 1,
        "oc_start_time" => hour + ":00",
        "oc_end_time" => (hour.to_i + 1).to_s + ":00",
    }

    str = self.http_post("https://bgu4u.bgu.ac.il/pls/scwp/!sc.AnnualCoursesAdv", query)

    doc = Nokogiri::HTML(str)
    json = {}
    results = []
    # Find current semester name
    hd = doc.css('td.BlueInputKind')
    return nil if not hd or not hd[2]
    semester = hd[2].text.trim
    doc.css('td.BlackTextEng').each do |node|
      p = node.parent
      #Hebrew Title
      results.push({'number' => p.children[6].text.trim,
                    'name' => p.css('a').text.trim,
                    'semester' => semester})
    end
    json['results'] = results
    json['cache'] = false

    json
  end

  def self.exam_from_tr (tr)
    e = {}
    td = tr.css("td");
    e['room'] = td[1].text
    # Convert dd/mm/yyyy hh:mm => mm/dd/yyyy
    parts = td[2].text.split(' ')
    return nil if parts.length < 2
    d = parts[0].split('/')
    t = parts[1].split(':')
    e['date_start'] = DateTime.new(d[2].to_i, d[1].to_i, d[0].to_i, t[0].to_i, t[1].to_i)
    e['type'] = td[3].text
    e
  end

  def self.bgu_find_by_id (id, year, semester, institution, university_id)
    dep = id.slice(0, 3)
    level = id.slice(4, 1)
    bgu_course = id.slice(6, 4)
    query = {
        "rn_course_department" => dep,
        "rn_course_degree_level" => level,
        "rn_course" => bgu_course,
        "rn_year" => year,
        "rn_semester" => semester,
        "rn_institution" => institution
    }
    str = self.http_post("https://bgu4u.bgu.ac.il/pls/scwp/!sc.AnnualCourseSemester", query);

    # TODO: Add error if not found or service not available
    doc = Nokogiri::HTML(str)
    tds = doc.css('td')
    course = {}
    tds = doc.css('form#mainForm td.BlackText')

    return nil unless tds.length > 0

    course['number'] = tds[0].text.trim
    s = tds[1].parent.children[0].text.trim
    course['name'] = tds[1].text.trim
    course['homepage'] = tds[1].parent.css("a")[0].attr("href")
    course['points'] = tds[3].text.to_f
    course['hours'] = tds[4].text.to_f
    course['groups'] = []

    table = doc.css('form#mainForm table')[2]

    # We need to skip header and spacer rows
    i = -2
    group = nil
    hours = nil
    table.css('tr').each do |tr|
      i = i + 1
      next if i <= 0

      td = tr.css('td')
      # Option 1 - group number is the link
      number = tr.css('a').text.trim

      # Option 2 - group number is with no link
      if number.length == 0 and td[7] then
        number = td[7].text.trim
      end

      # Option 3 - no group number -
      # we are on same group from previous line
      if number.to_i > 0 then
        # We push the group once we get to the next one
        if group then
          course['groups'].push group
        end
        #group = nil
        group = {}
        group['number'] = number.to_i
        group['staff'] = td[5].text.trim
        group['type'] = td[9].text.trim
        group['hours'] = []
      end # number.to_i > 0

      # Skip empty lines
      next if not group or not td[1]

      hours = {}
      roomAsString = td[1].text.trim.to_s
      if roomAsString.eql? "" then
        roomAsString = "אין מידע על הבניין"
        buildingid = -2
        roomnumber = -2
      else
        begin
          buildingregex = /\[.*\]/
          buildingname = buildingregex.match(roomAsString).to_s
          roomAsArray = roomAsString.split(" ")
          roomnumber = roomAsArray[-1].to_i
          buildingname = buildingname[1..-2]
          room = Rooms.find_by_name_and_university_id(buildingname, university_id)
          if not room.nil?
            buildingid = room.id
          else
            raise "Unable to find "+buildingid+" in buildings table"
          end
        rescue Exception => e
          message = {}
          message['roomAsString'] = roomAsString
          message['buildingname'] = buildingname
          message['roomnumber'] = roomnumber
          message['coursenumber'] = course['number']
          message['exception'] = e
          #Mailer.report_missing_building(message).deliver
          buildingid = -1
          roomnumber = -1
        end
      end
      hours['room'] = roomAsString
      hours['building_id'] = buildingid
      hours['room_number'] = roomnumber
      # Parse: 'day X hh:dd - hh:dd' ex. יום ב 14:00 - 12:00
      re = / ([^ ]) ([0-9][0-9]:[0-9][0-9]) - ([0-9][0-9]:[0-9][0-9])/
      m = re.match(td[3].text.trim)

      if m and m[1]
        hours['day'] = m[1].unpack('U')[0] - 'א'.unpack('U')[0] + 1
        hours['start_hour'] = m[3]
        hours['end_hour'] = m[2]
        group['hours'].push hours
      end

    end # table.css('tr').each do |tr| (Hours)

    if group then
      course['groups'].push group
    end #if group
    course['number'] = dep + "." + level + "." + bgu_course

    # Exams date
    exams = []
    table = doc.css('form#mainForm table')[4]
    # XXX Extremly limited for now - only read 3 lines
    tr = table.css('tr') if table
    if tr and tr[1]
      e = exam_from_tr(tr[1])
      exams.push(e) if e
    end # if tr[1]
    if tr and tr[2]
      e = exam_from_tr(tr[2])
      exams.push(e) if e
    end # if tr[2]
    if tr and tr[3]
      e = exam_from_tr(tr[3])
      exams.push(e) if e
    end # if tr[3]
    course['exams'] = exams
    course
  end

  def self.http_post(url, query)
    uri = URI(url);
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(query)
    response = http.request(request)
    response.body
  end
end
