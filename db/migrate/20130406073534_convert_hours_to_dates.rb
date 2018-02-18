class ConvertHoursToDates < ActiveRecord::Migration
  def change
      add_column :group_hours, :date_start, :datetime
      add_column :group_hours, :date_end, :datetime
      remove_column :group_hours, :day, :start, :end
      CourseGroups.delete_all
  end
end
