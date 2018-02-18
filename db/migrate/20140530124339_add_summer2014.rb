# encoding: UTF-8
class AddSummer2014 < ActiveRecord::Migration
  def up
      Event.create([
	 { :title => "ערב שבועות", :date_start => DateTime.new(2013, 5, 14),
	     :date_end => DateTime.new(2014, 6, 3), :color => 0xeeee99},
	 { :title => "שבועות", :date_start => DateTime.new(2013, 5, 15),
	     :date_end => DateTime.new(2014, 6, 4), :color => 0xeeee99}
    ])

    Semester.create([
	{   :university_id => 1, :name => 'קיץ תשע"ג',
	    :year => 2014, :semester => 3,
	    :start => DateTime.new(2014, 8, 3),
	    :end => DateTime.new(2014, 9, 19),
	    :active => true
	},
	{   :university_id => 2, :name => 'קיץ תשע"ג',
	    :year => 2014, :semester => 3,
	    :start => DateTime.new(2014, 8, 3),
	    :end => DateTime.new(2014, 9, 19),
	    :active => true
	}
    ])
  end
end
