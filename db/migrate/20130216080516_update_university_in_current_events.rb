class UpdateUniversityInCurrentEvents < ActiveRecord::Migration
  def change
      Event.all.each do |e|
	  e.update_attributes :university_id => e.user.semester.university_id
      end
  end
end
