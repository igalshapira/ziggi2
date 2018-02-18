class ActivateSummer2013 < ActiveRecord::Migration
  def up
      Semester.find_by_year_and_semester(2013, 3) do |s|
	 s.update_attributes :active => true
	 s.save
      end	
  end

  def down
  end
end
