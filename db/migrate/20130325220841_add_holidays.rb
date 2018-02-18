# encoding: UTF-8
class AddHolidays < ActiveRecord::Migration
  def up
      change_column :events, :user_id, :integer, :default => 0
      Event.create([
	 { :title => "ערב פסח", :date_start => DateTime.new(2013, 3, 25),
	     :date_end => DateTime.new(2013, 3, 25), :color => 0xeeee99},
	 { :title => "פסח", :date_start => DateTime.new(2013, 3, 26),
	     :date_end => DateTime.new(2013, 3, 26), :color => 0xeeee99},
	 { :title => "פסח", :date_start => DateTime.new(2013, 3, 27),
	     :date_end => DateTime.new(2013, 3, 27), :color => 0xeeee99},
	 { :title => "פסח", :date_start => DateTime.new(2013, 3, 28),
	     :date_end => DateTime.new(2013, 3, 28), :color => 0xeeee99},
	 { :title => "פסח", :date_start => DateTime.new(2013, 3, 29),
	     :date_end => DateTime.new(2013, 3, 29), :color => 0xeeee99},
	 { :title => "פסח", :date_start => DateTime.new(2013, 3, 30),
	     :date_end => DateTime.new(2013, 3, 30), :color => 0xeeee99},
	 { :title => "פסח", :date_start => DateTime.new(2013, 3, 31),
	     :date_end => DateTime.new(2013, 3, 31), :color => 0xeeee99},
	 { :title => "פסח", :date_start => DateTime.new(2013, 4, 1),
	     :date_end => DateTime.new(2013, 4, 1), :color => 0xeeee99},
	 { :title => "יום הזכרון (נדחה)", :date_start => DateTime.new(2013, 4, 15),
	     :date_end => DateTime.new(2013, 4, 15 ), :color => 0xeeee99},
	 { :title => "יום העצמאות (נדחה)", :date_start => DateTime.new(2013, 4, 16),
	     :date_end => DateTime.new(2013, 4, 16), :color => 0xeeee99},
	 { :title => "ערב שבועות", :date_start => DateTime.new(2013, 5, 14),
	     :date_end => DateTime.new(2013, 5, 14), :color => 0xeeee99},
	 { :title => "שבועות", :date_start => DateTime.new(2013, 5, 15),
	     :date_end => DateTime.new(2013, 5, 15), :color => 0xeeee99}
    ])
  end

  def down
  end
end
