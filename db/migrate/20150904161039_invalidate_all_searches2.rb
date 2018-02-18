class InvalidateAllSearches2 < ActiveRecord::Migration
  def up
	  Searches.record_timestamps=false
      Searches.all.each do |c|
	     c.update_attributes :updated_at => 1.years.ago
		 c.save
      end
	  Searches.record_timestamps=true
  end

  def down
  end
end
