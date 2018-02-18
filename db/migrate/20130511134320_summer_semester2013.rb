# encoding: UTF-8
class SummerSemester2013 < ActiveRecord::Migration
  def up
    Semester.create([
	{   :university_id => 1, :name => 'קיץ תשע"ג',
	    :year => 2013, :semester => 3,
	    :start => DateTime.new(2013, 8, 1),
	    :end => DateTime.new(2013, 9, 12),
	    :exams_start => DateTime.new(2013, 9, 15),
	    :exams_end => DateTime.new(2013, 9, 30)
	},
	{   :university_id => 2, :name => 'קיץ תשע"ג',
	    :year => 2013, :semester => 3,
	    :start => DateTime.new(2013, 8, 1),
	    :end => DateTime.new(2013, 9, 12),
	    :exams_start => DateTime.new(2013, 9, 15),
	    :exams_end => DateTime.new(2013, 9, 30)
	}
    ])
  end

  def down
  end
end
