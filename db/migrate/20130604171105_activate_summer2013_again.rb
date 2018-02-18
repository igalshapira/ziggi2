class ActivateSummer2013Again < ActiveRecord::Migration
  def change
      Semester.find_by_year_and_semester(2013, 3) do |s|
	 s.update_attributes :active => true
	 s.save
      end	
  end
end
