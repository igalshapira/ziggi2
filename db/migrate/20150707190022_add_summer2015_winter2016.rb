# encoding: UTF-8
class AddSummer2015Winter2016 < ActiveRecord::Migration
  def up
      Semester.all.each do |s|
	     s.update_attributes :active => false
	  end

    Semester.create([
	{   :university_id => 1, :name => 'קיץ תשע"ה',
	    :year => 2015, :semester => 3,
	    :start => DateTime.new(2015, 8, 2),
	    :end => DateTime.new(2015, 9, 18),
	    :exams_start => DateTime.new(2015, 9, 20),
	    :exams_end => DateTime.new(2015, 10, 23),
	    :active => true
	},
	{   :university_id => 1, :name => 'סתיו תשע"ו',
	    :year => 2016, :semester => 1,
	    :start => DateTime.new(2015, 10, 25),
	    :end => DateTime.new(2016, 1, 22),
	    :exams_start => DateTime.new(2016, 1, 24),
	    :exams_end => DateTime.new(2016, 3, 4),
	    :active => false
	},
	{   :university_id => 1, :name => 'אביב תשע"ו',
	    :year => 2016, :semester => 2,
	    :start => DateTime.new(2016, 3, 6),
	    :end => DateTime.new(2016, 7, 1),
	    :exams_start => DateTime.new(2016, 7, 3),
	    :exams_end => DateTime.new(2016, 9, 30),
	    :active => false
	}
    ])
  end
end
