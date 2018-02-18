module StaffHelper
  def get_staff_info(staffid)
    s = Staff.find_by_id(staffid)
    return render :status => 404, :text => staffid + " not found" unless s

    json = {}
    json['id'] = s.id
    json['name'] = s.name
    json['room'] = s.room
    json['email'] = s.email
    json['phone'] = s.phone
    json['updated'] = s.updated_at
    json['reception'] = s.reception
    if s.user then
      json['updated_by'] = s.user.name.split(' ')[0]
    else
      json['updated_by'] = nil
    end

    json
  end
end