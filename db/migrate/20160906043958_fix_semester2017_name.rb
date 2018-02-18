# encoding: UTF-8
class FixSemester2017Name < ActiveRecord::Migration
  def up
      Semester.all.each do |s|
	  if (s.year == 2017 and s.semester == 1)
	     s.update_attributes :name => 'סתיו תשע"ז'
	  end
	  s.save
      end	
  end

  def down
  end
end
