# encoding: UTF-8
class AddBguAutumn2014 < ActiveRecord::Migration
  def up
    Semester.create([
	{   :university_id => 1, :name => 'אביב תשע"ד',
	    :year => 2014, :semester => 2,
	    :start => DateTime.new(2014, 3, 2),
	    :end => DateTime.new(2014, 6, 20),
	    :exams_start => DateTime.new(2014, 6, 22),
	    :exams_end => DateTime.new(2014, 8, 1),
	    :active => true
	},
	{   :university_id => 2, :name => 'אביב תשע"ד',
	    :year => 2014, :semester => 2,
	    :start => DateTime.new(2014, 3, 2),
	    :end => DateTime.new(2014, 6, 20),
	    :exams_start => DateTime.new(2014, 6, 22),
	    :exams_end => DateTime.new(2014, 8, 1),
	    :active => true
	}
    ])

      Event.create([
	 { :title => "תענית  אסתר (מוקדם)", :date_start => DateTime.new(2014, 3, 13),
	     :date_end => DateTime.new(2014, 3, 13), :color => 0xeeee99},
	 { :title => "פורים", :date_start => DateTime.new(2014, 3, 16),
	     :date_end => DateTime.new(2014, 3, 16), :color => 0xeeee99},
	 { :title => "ערב פסח", :date_start => DateTime.new(2014, 4, 14),
	     :date_end => DateTime.new(2014, 4, 14), :color => 0xeeee99},
	 { :title => "פסח", :date_start => DateTime.new(2014, 4, 15),
	     :date_end => DateTime.new(2014, 4, 15), :color => 0xeeee99},
	 { :title => "פסח", :date_start => DateTime.new(2014, 4, 16),
	     :date_end => DateTime.new(2014, 4, 16), :color => 0xeeee99},
	 { :title => "פסח", :date_start => DateTime.new(2014, 4, 17),
	     :date_end => DateTime.new(2014, 4, 17), :color => 0xeeee99},
	 { :title => "פסח", :date_start => DateTime.new(2014, 4, 18),
	     :date_end => DateTime.new(2014, 4, 18), :color => 0xeeee99},
	 { :title => "פסח", :date_start => DateTime.new(2014, 4, 19),
	     :date_end => DateTime.new(2014, 4, 19), :color => 0xeeee99},
	 { :title => "פסח", :date_start => DateTime.new(2014, 4, 20),
	     :date_end => DateTime.new(2014, 4, 20), :color => 0xeeee99},
	 { :title => "פסח", :date_start => DateTime.new(2014, 4, 21),
	     :date_end => DateTime.new(2014, 4, 21), :color => 0xeeee99},
	 { :title => "יום הזיכרון לשואה ולגבורה (נדחה)", :date_start => DateTime.new(2014, 4, 28), :date_end => DateTime.new(2014, 4, 28), :color => 0xeeee99},
	 { :title => "יום הזיכרון לחללי צהל (נדחה)", :date_start => DateTime.new(2014, 5, 4), :date_end => DateTime.new(2014, 5, 4), :color => 0xeeee99}
      ])
  end

  def down
  end
end
