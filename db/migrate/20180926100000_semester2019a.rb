class Semester2019a < ActiveRecord::Migration
def up
    Semester.all.each do |s|
        s.update_attributes :active => false
    end

    Semester.create([
	{   :university_id => 1, :name => 'סתיו תשע"ט',
	    :year => 2019, :semester => 1,
	    :start => DateTime.new(2018, 10, 14),
	    :end => DateTime.new(2019, 1, 8),
	    :exams_start => DateTime.new(2019, 1, 10),
	    :exams_end => DateTime.new(2019, 2, 22),
	    :active => true
	}
    ])
  end
end
