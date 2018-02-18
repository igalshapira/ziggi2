class UserGroupsRenameCourseGroupId < ActiveRecord::Migration
  def change
      add_column :user_groups, :user_id, :integer
      remove_column :user_groups, :user_course_id
  end
end
