class AddSemesters2018 < ActiveRecord::Migration
def up
       Semester.all.each do |s|
	     s.update_attributes :active => false
	  end

    Semester.create([
	{   :university_id => 1, :name => 'סתיו תשע"ח',
	    :year => 2018, :semester => 1,
	    :start => DateTime.new(2017, 10, 22),
	    :end => DateTime.new(2018, 1, 18),
	    :exams_start => DateTime.new(2018, 1, 22),
	    :exams_end => DateTime.new(2018, 3, 6),
	    :active => true
	},
	{   :university_id => 1, :name => 'אביב תשע"ח',
	    :year => 2018, :semester => 2,
	    :start => DateTime.new(2018, 3, 5),
	    :end => DateTime.new(2018, 6, 22),
	    :exams_start => DateTime.new(2018, 6, 24),
	    :exams_end => DateTime.new(2018, 9, 30),
	    :active => false
	}
    ])
  end
end
