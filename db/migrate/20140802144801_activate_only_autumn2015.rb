class ActivateOnlyAutumn2015 < ActiveRecord::Migration
  def up
      Semester.all do |s|
	  if not (s.year == 2015 and s.semester == 1)
	     s.update_attributes :active => false
	     s.save
	  end
      end	
  end

  def down
  end
end
