# encoding: UTF-8
class String
  def heb_url_encode
    u = ""
    # Do it the very ugly way - but it works
    self.each_char do |i|
      if i[1]
        u = u + "%" + (i[1]+80).to_s(16)
      end
      if not i[1] and i[0] == 32
        u = u + "+"
      end
    end
    u
  end

  def trim
    return self.gsub(/[\s\t\302\240]+/, ' ').strip
  end
end


class RecommendedController < ApplicationController
  before_filter :login_check

  def find
    uri = URI("https://bgu4u.bgu.ac.il/pls/scwp/sc.personalCourseList")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    res = http.request(request)

    if res.code != "200"
      render :json => {'status' => 'failed'}
      return
    end

    doc = Nokogiri::HTML(res.body)
    results = {}
=begin
    rn_institution = []
    doc.search('[name="rn_institution"]').search('option').each do |option|
      rn_institution.push({ 'text'=>option.text.trim, 'value'=>option["value"]})
    end
    results['institutions'] = rn_institution
=end
    rn_degree_level = []
    doc.search('[name="rn_degree_level"]').search('option').each do |option|
      rn_degree_level.push({'text' => option.text.trim, 'value' => option["value"]})
    end
    results['degrees'] = rn_degree_level

    rn_department = []
    doc.search('[name="rn_department"]').search('option').each do |option|
      if (option["value"]=="999" || option["value"]=="11")
        next
      end
      txt = option.text.trim
      if (!txt.nil? && txt!="")
        txt = txt[0, txt.index("-")] ## remove the (number) from the end
      end
      rn_department.push({'text' => txt, 'value' => option["value"]})
    end
    results['departments'] = rn_department
    year_in_degree = @user.year_in_degree
    department = @user.department
    degree = @user.degree

    results['year_in_degree'] = year_in_degree.nil?? 0 : year_in_degree
    results['department'] = department.nil?? '' : department
    results['degree'] = degree.nil?? '' : degree
    results['status'] = 'success'
    render :text => JSON.dump(results)
  end


  def get_recommended
    #user's data, should be checked if empty in case first time
    year_in_degree = @user.year_in_degree
    department = @user.department
    degree = @user.degree

    if (year_in_degree.nil? || department.nil? || degree.nil?)
      s = {}
      s["error"] = "Neccessary variables are not set!"
      render :text => JSON.dump(s)
      return
    end

    #previously entered data
    semester = @user.semester.semester
    year = @user.semester.year
    query = {
        "cmdkey" => "PROD",
        "server" => "rep_aristo4stu3_FRHome1",
        "report" => "acrr008w",
        "desformat" => "XML",
        "DESTYPE" => "cache",
        "P_PATH" => "",
        "P_SPEC" => "",
        "P_YEAR_DEGREE" => year_in_degree,
        "P_SORT" => "1",
        "P_YEAR" => year,
        "P_SEMESTER" => semester,
        "P_INSTITUTION" => "0",
        "P_DEGREE_LEVEL" => degree,
        "P_DEPARTMENT" => department,
        "P_GLOBAL_COURSES" => "2",
        "P_WEB" => "1",
        "P_SPECIAL_PATH" => "0"
    }

    uri = URI("https://reports4u.bgu.ac.il/reports/rwservlet");
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request.set_form_data(query)
    response = http.request(request)

    doc = Nokogiri::XML(response.body)

    courses = []
    doc.search("G_FLINE").each do |course|
      courses.push({'name' => course.css("COURSE_NAME").text, 'number' => course.css("COURSE_NUMBER").text})
    end

    result = {}
    result["courses"] = courses
    render :text => JSON.dump(result)
  end
end
