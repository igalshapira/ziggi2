module EventHelper
  def all_events
    events = []

    # Find all events in the time frame that are
    # 1. Private and belongs to this user
    Event.where("user_id = ? AND date_start >= ? AND date_start <= ? AND course_id = 0 AND staff_id = 0 AND public=false", @user[:id], @user.semester.start, @user.semester.end).each do |e|
      sel = UserEvent.find_by_user_id_and_event_id(@user[:id], e[:id])
      if sel and sel[:selected] then
        e['selected'] = true
      else
        e['selected'] = false
      end
      events.push(e)
    end

    # 2. Public and were selected by user
    Event.where("date_start >= ? AND date_start <= ? AND course_id = 0 AND staff_id = 0 AND public=true AND university_id = ?", @user.semester.start, @user.semester.end, @user.semester.university.id).each do |e|
      sel = UserEvent.find_by_user_id_and_event_id(@user[:id], e[:id])
      next if not sel
      e['selected'] = true
      e['updated_by'] = e.user.name.split(' ')[0]
      events.push(e)
    end

    # 3. General events - no related to specific university.
    Event.where("university_id = 0 AND date_start >= ? AND date_start <= ?", @user.semester.start, @user.semester.end).each do |e|
      events.push(e)
    end

    events
  end
end
