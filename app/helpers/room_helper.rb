module RoomHelper
  def get_rooms_info
    rooms = []
    Rooms.find_all_by_university_id(@user.semester.university_id).each do |r|
      j = {}
      j['id'] = r.id
      j['lat'] = r.lat
      j['lng'] = r.lng
      j['name'] = r.name
      j['comment'] = r.comment
      rooms.push(j)
    end
    rooms
  end
end