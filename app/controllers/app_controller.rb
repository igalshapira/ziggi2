class AppController < ApplicationController
  before_filter :login_check
  # /token
  def get_csrf_token
    #returns json to allow future modifications
    json = {}
    json['token'] = form_authenticity_token
    render :text => JSON.dump(json)
  end

  include CourseHelper
  def get_courses
      get_courses_info
  end

  include StaffHelper
  def get_staffs
    staffs = []
    UserCourse.find_all_by_user_id_and_group(@user.id, 0).each do |c|
      next unless c.course and c.course.semester_id == @user.semester_id
      CourseGroups.find_all_by_course_id(c.course[:id]).each do |g|
        if g.staff.nil?
          next
        end
        staffId = g.staff.id
	json = get_staff_info(staffId)
	staffs.push(json)
      end
    end
    staffs
  end

  include UniversityHelper
  def get_universities
    get_universities_info
  end

  include RoomHelper
  def get_rooms
      get_rooms_info
  end

  include SemesterHelper
  def get_semester
    semester_info(@user.semester)
  end

  def get_data
    data = {}
    data['courses'] = get_courses
    data['rooms'] = get_rooms
    data['staffs'] = get_staffs
    data['universities'] = get_universities
    data['rooms'] = get_rooms
    data['semester'] = get_semester
    render :text => JSON.dump(data)
  end
end
