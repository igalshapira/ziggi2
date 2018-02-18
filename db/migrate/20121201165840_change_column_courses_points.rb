class ChangeColumnCoursesPoints < ActiveRecord::Migration
    def change
	change_column :courses, :hours, :float
	change_column :courses, :points, :float
    end
end
