module ScheduleHelper
  def get_user_summary
    # Summary of all courses and staff
    json = []

    UserCourse.find_all_by_user_id_and_group(@user.id, 0).each do |c|
      next if not c.course
      next unless c.course.semester.id == @user.semester.id
      j = {}
      j['number'] = c.course.number
      j['name'] = c.course.name
      staff = []

      CourseGroups.find_all_by_course_id(c.course.id).each do |g|
        next if not g.staff or g.staff.name.size < 3

        s = staff.find_all { |s| s['name'] == g.staff.name }
        next if s.length > 0
        s = {}
        s['id'] = g.staff.id
        s['name'] = g.staff.name
        s['room'] = g.staff.room
        s['email'] = g.staff.email
        s['phone'] = g.staff.phone
        s['reception'] = g.staff.reception
        staff.push(s)
      end

      j['staff'] = staff
      json.push(j)
    end
    json
  end
end
