module UniversityHelper
  def get_universities_info
    unis = []
    University.all.each do |u|
      next if u.status == 0 # XXX - Temporary. Hide universities
      j = {}
      j['id'] = u.id
      j['code'] = u.code
      j['homepage'] = u.homepage
      j['name'] = u.name
      j['lat'] = u.lat
      j['lng'] = u.lng
      unis.push(j)
    end
    unis
  end
end
