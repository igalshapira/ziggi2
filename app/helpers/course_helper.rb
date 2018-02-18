module CourseHelper
  def get_courses_info
    json = []

    UserCourse.find_all_by_user_id_and_group(@user.id, 0).each do |c|
      next unless c.course and c.course.semester_id == @user.semester_id
      course = course_from_cache(c.course.number)
      if not course
        course = @unilib.find_by_number(c.course.number, @user.semester.year, @user.semester.semester, @user.semester.university.id)
        next unless course
        save_course_to_cache course
        course = course_from_cache(course['number'])
      end
      json.push(course)
    end
    json
  end

  def course_from_cache (number)
    @course = Course.find_by_number_and_semester_id(number, @user.semester[:id])
    # 1 Day caching for course data
    return nil unless @course and
        (((Time.now - @course.updated_at) < 4.day) or
            not @course.semester.active)

    course = {}
    course['id'] = @course['id']
    course['number'] = @course['number']
    course['name'] = @course['name']
    course['homepage'] = @course['homepage']
    course['points'] = @course['points']
    course['hours'] = @course['hours']
    groups = []
    exams = []

    # Load groups and exams dates
    CourseGroups.find_all_by_course_id(@course[:id]).each do |g|
      grp = {}
      grp['id'] = g[:id]
      grp['number'] = g[:number]
      grp['type'] = g[:group_type]
      if g.number == 0
        exams.push(grp)
        GroupHours.find_all_by_coursegroup_id(g[:id]).each do |h|
          grp['date_start'] = h[:date_start]
          grp['room'] = h[:room]
        end
        next
      end
      staff = {}
      if g.staff
        staff['id'] = g.staff.id
        staff['name'] = g.staff.name
      end
      grp['staff'] = staff
      sel = UserCourse.find_by_user_id_and_course_id_and_group(@user[:id], @course[:id], g[:number])
      if sel then
        grp['selected'] = true
      else
        grp['selected'] = false
      end
      hours = []
      GroupHours.find_all_by_coursegroup_id(g[:id]).each do |h|
        hour = {}
        hour['date_start'] = h[:date_start]
        hour['date_end'] = h[:date_end]
        hour['room'] = h[:room]
        hour['building_id'] = h[:building_id]
        hour['room_number'] = h[:room_number]
        hours.push(hour)
      end
      grp['hours'] = hours
      groups.push(grp)
    end
    course['groups'] = groups
    course['exams'] = exams
    course
  end

  def save_course_to_cache (info)
    @course = Course.find_by_number_and_semester_id(info['number'],
                                                    @user.semester[:id])
    @course = Course.create :number => info['number'],
                            :semester_id => @user.semester[:id] unless @course
    @course.update_attributes :name => info['name'],
                              :points => info['points'], :hours => info['hours'],
                              :homepage => info['homepage'], :updated_at => Time.now

    # Save groups
    CourseGroups.find_all_by_course_id(@course[:id]).each do |c|
      GroupHours.find_all_by_coursegroup_id(c[:id]).each do |g|
        g.destroy
      end
      c.destroy
    end

    info['groups'].each do |g|
      sdb = Staff.find_by_name(g['staff'])
      if not sdb
        sdb = Staff.create :name => g['staff']
      end
      gdb = CourseGroups.create :course_id => @course[:id],
                                :number => g['number'],
                                :group_type => g['type'],
                                :staff_id => sdb.id
      # Add hours
      next if not g['hours']
      g['hours'].each do |h|
        s = h['start_hour'].split(':')
        e = h['end_hour'].split(':')
        GroupHours.create :coursegroup_id => gdb[:id],
                          # We know that 2013-03-09 is saturday
                          :date_start => DateTime.new(2013, 3, 9 + h['day'], s[0].to_i, s[1].to_i),
                          :date_end => DateTime.new(2013, 3, 9 + h['day'].to_i, e[0].to_i, e[1].to_i),
                          :room => h['room'],
                          :building_id => h['building_id'],
                          :room_number => h['room_number']
      end # g['hours'].each do |h|
    end # info['groups'].each do |g|

    # Save exams as CourseGroups with number 0
    if info['exams'] then
      info['exams'].each do |e|
        # Don't save the same exam twice
        next if CourseGroups.find_by_course_id_and_number_and_group_type(@course[:id], 0, e['type'])
        gdb = CourseGroups.create :course_id => @course[:id],
                                  :number => 0, :staff_id => 0, :group_type => e['type']
        GroupHours.create :coursegroup_id => gdb[:id],
                          :date_start => e['date_start'],
                          :room => e['room'].slice(0..254)
      end # info['exams'].each do |e|
    end
  end

  # Returns array of days with list of selected groups
  def get_agenda
      courses = get_courses_info
      agenda = [[], [], [], [], [], [], []]
      courses.each do |c|
	  c['groups'].each do |g|
	      next if not g['selected']
	      g['hours'].each do |h|
		  d = h['date_start'].to_time;
		  j = {}
		  j['course'] = c['name']
		  j['group'] = g
		  j['hour'] = h
		  # Insert in sorted way
		  at = 0
		  agenda[d.wday].each do |a|
		      if a['hour']['date_start'].to_time > d
			  break
		      end
		      at = at +1
		  end
		  agenda[d.wday].insert(at, j)
	      end
	  end
      end
      agenda
  end

  def get_calendar
      #hourEvent(events, sunday, new Date(), "", "", "wc-today", "drawCurrentTimeLine");
      #hourEvent(events, sunday, semester.start, 'פתיחת סמסטר ' +
      #    semester.name);
      #hourEvent(events, sunday, semester.end, 'סיום סמסטר ' + semester.name);
      #hourEvent(events, sunday, semester.exams_start, 'תחילת בחינות סמסטר ' +
      #    semester.name);
      #console.log(semester);
      #hourEvent(events, sunday, semester.exams_end, 'סיום בחינות סמסטר ' +
      #    semester.name);
      courses = get_courses_info
      calendar = [[], [], [], [], [], [], []]
      courses.each do |c|
      end
      calendar
  end

end
