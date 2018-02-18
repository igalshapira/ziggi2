class CourseGroupsChangeStaffColumn < ActiveRecord::Migration
  def change
      remove_column :course_groups, :staff_name
      add_column :course_groups, :staff_id, :integer
  end
end
