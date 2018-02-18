class UpdateSummer2013Dates < ActiveRecord::Migration
  def change
      Semester.find_all_by_year_and_semester(2013, 3).each do |s|
	 s.update_attributes :end => DateTime.new(2013, 10, 12),
	    :exams_start => DateTime.new(2013, 10, 12),
	    :exams_end => DateTime.new(2013, 10, 12)
	 s.save
      end	
  end
end
