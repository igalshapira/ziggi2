# encoding: UTF-8
class AddSemesters2017 < ActiveRecord::Migration
  def up
       Semester.all.each do |s|
	     s.update_attributes :active => false
	  end

    Semester.create([
	{   :university_id => 1, :name => 'סתיז תשע"ז',
	    :year => 2017, :semester => 1,
	    :start => DateTime.new(2016, 10, 29),
	    :end => DateTime.new(2017, 1, 26),
	    :exams_start => DateTime.new(2017, 1, 28),
	    :exams_end => DateTime.new(2017, 3, 9),
	    :active => true
	},
	{   :university_id => 1, :name => 'אביב תשע"ז',
	    :year => 2017, :semester => 2,
	    :start => DateTime.new(2017, 3, 11),
	    :end => DateTime.new(2017, 6, 29),
	    :exams_start => DateTime.new(2017, 7, 1),
	    :exams_end => DateTime.new(2017, 9, 30),
	    :active => false
	}
    ])
  end
end