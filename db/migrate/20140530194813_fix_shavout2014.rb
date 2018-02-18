class FixShavout2014 < ActiveRecord::Migration
  def up
      Event.find_by_color_and_date_start(0xeeee99, DateTime.new(2013, 5, 14)) do |e|
	 e.update_attributes :date_start => DateTime.new(2014, 6, 3)
	 e.save
      end	
      Event.find_by_color_and_date_start(0xeeee99, DateTime.new(2013, 5, 15)) do |e|
	 e.update_attributes :date_start => DateTime.new(2014, 6, 4)
	 e.save
      end	
  end

  def down
  end
end
