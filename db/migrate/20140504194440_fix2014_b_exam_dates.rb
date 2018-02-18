class Fix2014BExamDates < ActiveRecord::Migration
  def change
      Semester.find_all_by_exams_end(DateTime.new(2014, 8, 1)).each do |s|
	  s.update_attributes :exams_end => DateTime.new(2014, 8, 8)
	  s.save
      end
  end
end
