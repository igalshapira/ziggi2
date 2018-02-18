class UserGroupsChangeCourseGroupsId < ActiveRecord::Migration
  def change
      add_column :user_courses, :group, :integer
      drop_table :user_groups
  end
end
