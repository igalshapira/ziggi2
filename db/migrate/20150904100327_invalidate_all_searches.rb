class InvalidateAllSearches < ActiveRecord::Migration
  def change
	  Searches.record_timestamps=false
      Searches.all.each do |c|
	     c.update_attributes :updated_at => 1.years.ago
		 c.save
      end
	  Searches.record_timestamps=true
  end
end
