class ActivateOnlyAutumn2015again < ActiveRecord::Migration
  def change
      Semester.all.each do |s|
	  if not (s.year == 2015 and s.semester == 1)
	     s.update_attributes :active => false
	     s.save
	  end
      end	
  end
end
