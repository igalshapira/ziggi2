# encoding: UTF-8
class ActivateWinter2016 < ActiveRecord::Migration
  def up
      Semester.all.each do |s|
	  if (s.year == 2016 and s.semester == 1)
	     s.update_attributes :active => true
	  else
	     s.update_attributes :active => false
	  end
	  s.save
      end	
  end

  def down
  end
end
