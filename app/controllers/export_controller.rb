class ExportController < ApplicationController
  before_filter :login_check, :only => [:vcs, :google_redirect]

#    header("Cache-Control: no-cache, must-revalidate"); // HTTP/1.1
#header("Expires: 0");
#header("Content-Type: text/x-vCalendar");
#header("Content-Disposition: inline; filename=websched.vcs");

  Time::DATE_FORMATS[:ical] = "%Y%m%dT%H%M00"

  def add_event(id, title, location, content, dstart, dend, weeks)
    location = "" if not location
    event = "BEGIN:VEVENT\r\n" +
        "SUMMARY:" + title + "\r\n" +
        "Location:" + location + "\r\n" +
        "DESCRIPTION;ENCODING=QUOTED-PRINTABLE:" + content + "\r\n"
    # Date format is: YYYYMMDDTHHMMSSZ
    event = event + "DTSTART:" + dstart.to_formatted_s(:ical) + "\r\n"
    event = event + "DTEND:" + dend.to_formatted_s(:ical) + "\r\n"
    event = event + "RRULE:FREQ=WEEKLY;COUNT=" + weeks.to_s + ";\r\n" if weeks > 0
    event = event + "DTSTAMP:" + DateTime.now.to_formatted_s(:ical) + "\r\n"
    event = event + "UID:e" + id + "@ziggi.co\r\n"
    event = event + "END:VEVENT\r\n"
    event
  end

  def get_vcs
    vcs = "BEGIN:VCALENDAR\r\n" +
        "VERSION:2.0\r\n" +
        "PRODID:Ziggi\r\n" +
        "METHOD:PUBLISH\r\n";

    weeks = ((@user.semester.end.to_time - @user.semester.start.to_time) /
        (7 * 24 * 60 * 60)).to_i + 1
    start = @user.semester.start
    start = start - start.wday

    # Add all selected courses groups, from cache only - enough for this
    UserCourse.find_all_by_user_id(@user.id).each do |c|
      next unless c.course and c.course.semester_id == @user.semester_id
      crs = Course.find(c.course)
      CourseGroups.find_all_by_course_id_and_number(c.course, c.group).each do |g|
        GroupHours.find_all_by_coursegroup_id(g[:id]).each do |h|
          id = crs.id.to_s + "_" + g[:id].to_s + "_"+ h[:id].to_s
          if c.group == 0 # Exams
            title = crs.name + " " + g.group_type
            content = crs.name + " " + g.group_type
            s = h[:date_start]
            e = s.to_time + 60*60*2
            event_weeks = 0
          else # A course hour
            title = crs.name + " (" + g.number.to_s + ")"
            content = crs.name
            content = content + " " + g.staff.name if g.staff and g.staff.name
            s = (start + h[:date_start].wday).to_time +
                60*60*h[:date_start].hour
            e = (start + h[:date_start].wday).to_time +
                60*60*h[:date_end].hour
            event_weeks = weeks
          end
          vcs = vcs + add_event(id, title, h[:room], content, s, e,
                                event_weeks)
        end
      end
    end

    # Find all events in the timer frame that are
    # 1. Private and belongs to this user
    Event.where("user_id = ? AND date_start >= ? AND date_start <= ? AND course_id = 0 AND staff_id = 0 AND public=false", @user[:id], @user.semester.start, @user.semester.end).each do |e|
      sel = UserEvent.find_by_user_id_and_event_id(@user[:id], e[:id])
      if sel and sel[:selected] then
        vcs = vcs + add_event(e[:id].to_s, e[:title], e[:location],
                              e[:title], e[:date_start], e[:date_end],
                              (e[:weekly] ? weeks : 0))
      end
    end

    # 2. Public and were selected by user
    Event.where("date_start >= ? AND date_start <= ? AND course_id = 0 AND staff_id = 0 AND public=true AND university_id = ?", @user.semester.start, @user.semester.end, @user.semester.university.id).each do |e|
      sel = UserEvent.find_by_user_id_and_event_id(@user[:id], e[:id])
      next if not sel
      vcs = vcs + add_event(e[:id].to_s, e[:title], e[:location],
                            e[:title], e[:date_start], e[:date_end],
                            (e[:weekly] ? weeks : 0))
    end

    vcs = vcs + "END:VCALENDAR\r\n";
    vcs
  end

  def vcs
    response.headers["Content-Type"]="text/x-vCalendar"
    response.headers["Content-Disposition"]="attachment; filename=ziggi.vcs"
    render :text => get_vcs
  end
end
