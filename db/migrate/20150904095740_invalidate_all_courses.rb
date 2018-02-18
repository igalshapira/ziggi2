class InvalidateAllCourses < ActiveRecord::Migration
  def change
	  Course.record_timestamps=false
      Course.all.each do |c|
	     c.update_attributes :updated_at => 1.years.ago
		 c.save
      end
	  Course.record_timestamps=true
  end
end
