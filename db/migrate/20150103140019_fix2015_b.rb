class Fix2015B < ActiveRecord::Migration
  def change
      Semester.find_by_year_and_semester(2015, 1) do |s|
	  s.update_attributes :exams_end => DateTime.new(2015, 3, 5)
	  s.save
      end	
  end
end
