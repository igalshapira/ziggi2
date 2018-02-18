# encoding: UTF-8
class AddAutumn2014 < ActiveRecord::Migration
  def change
    Semester.create([
	{   :university_id => 1, :name => 'סתיו תשע"ד',
	    :year => 2014, :semester => 1,
	    :start => DateTime.new(2013, 10, 20),
	    :end => DateTime.new(2014, 1, 17),
	    :exams_start => DateTime.new(2014, 1, 19),
	    :exams_end => DateTime.new(2014, 2, 28),
	    :active => true
	},
	{   :university_id => 2, :name => 'סתיו תשע"ד',
	    :year => 2014, :semester => 1,
	    :start => DateTime.new(2013, 10, 20),
	    :end => DateTime.new(2014, 1, 17),
	    :exams_start => DateTime.new(2014, 1, 19),
	    :exams_end => DateTime.new(2014, 2, 28),
	    :active => true
	}
    ])
  end
end
