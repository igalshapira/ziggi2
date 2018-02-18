# encoding: UTF-8
class AddBgu2015 < ActiveRecord::Migration
  def up
    Semester.create([
	{   :university_id => 1, :name => 'סתיו תשע"ה',
	    :year => 2015, :semester => 1,
	    :start => DateTime.new(2014, 10, 26),
	    :end => DateTime.new(2015, 1, 23),
	    :exams_start => DateTime.new(2015, 1, 25),
	    :exams_end => DateTime.new(2015, 6, 3),
	    :active => true
	},
	{   :university_id => 2, :name => 'סתיו תשע"ה',
	    :year => 2015, :semester => 1,
	    :start => DateTime.new(2014, 10, 26),
	    :end => DateTime.new(2015, 1, 23),
	    :exams_start => DateTime.new(2015, 1, 25),
	    :exams_end => DateTime.new(2015, 6, 3),
	    :active => true
	},
	{   :university_id => 1, :name => 'אביב תשע"ה',
	    :year => 2015, :semester => 2,
	    :start => DateTime.new(2015, 3, 8),
	    :end => DateTime.new(2015, 6, 26),
	    :exams_start => DateTime.new(2015, 6, 28),
	    :exams_end => DateTime.new(2015, 7, 31),
	    :active => false
	},
	{   :university_id => 2, :name => 'אביב תשע"ה',
	    :year => 2015, :semester => 2,
	    :start => DateTime.new(2015, 3, 8),
	    :end => DateTime.new(2015, 6, 26),
	    :exams_start => DateTime.new(2015, 6, 28),
	    :exams_end => DateTime.new(2015, 7, 31),
	    :active => false
	}
    ])

      Event.create([
         { :title => "חנוכה", :date_start => DateTime.new(2014, 12, 21),
             :date_end => DateTime.new(2014, 12, 21), :color => 0xeeee99},
         { :title => "תענית אסתר", :date_start => DateTime.new(2015, 3, 4),
             :date_end => DateTime.new(2015, 3, 4), :color => 0xeeee99},
         { :title => "פורים", :date_start => DateTime.new(2015, 3, 5),
             :date_end => DateTime.new(2015, 3, 5), :color => 0xeeee99},
         { :title => "פסח", :date_start => DateTime.new(2015, 4, 5),
             :date_end => DateTime.new(2015, 4, 5), :color => 0xeeee99},
         { :title => "פסח", :date_start => DateTime.new(2015, 4, 6),
             :date_end => DateTime.new(2015, 4, 6), :color => 0xeeee99},
         { :title => "פסח", :date_start => DateTime.new(2015, 4, 7),
             :date_end => DateTime.new(2015, 4, 7), :color => 0xeeee99},
         { :title => "פסח", :date_start => DateTime.new(2015, 4, 8),
             :date_end => DateTime.new(2015, 4, 8), :color => 0xeeee99},
         { :title => "פסח", :date_start => DateTime.new(2015, 4, 9),
             :date_end => DateTime.new(2015, 4, 9), :color => 0xeeee99},
         { :title => "פסח", :date_start => DateTime.new(2015, 4, 10),
             :date_end => DateTime.new(2015, 4, 10), :color => 0xeeee99},
    ])
  end
end
