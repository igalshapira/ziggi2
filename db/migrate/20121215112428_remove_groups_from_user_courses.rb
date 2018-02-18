class RemoveGroupsFromUserCourses < ActiveRecord::Migration
  def change
      remove_column :user_courses, :groups
  end
end
