class DeactivateSummer2013 < ActiveRecord::Migration
  def change
      Semester.find_all_by_year_and_semester(2013, 3).each do |s|
	 s.update_attributes :active => false
	 s.save
      end	
  end
end
