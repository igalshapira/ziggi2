class Activate2017b < ActiveRecord::Migration
  def change
      Semester.all.each do |s|
	  if (s.year == 2017 and s.semester == 2)
	     s.update_attributes :active => true
	  else
	     s.update_attributes :active => false
	  end
	  s.save
      end	
  end
end
