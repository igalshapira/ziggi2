class CourseGroupRenameType < ActiveRecord::Migration
  def change
      add_column :course_groups, :group_type, :string
      remove_column :course_groups, :type
  end
end
