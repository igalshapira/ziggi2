class AddGroupsToUserCourses < ActiveRecord::Migration
  def change
      add_column :user_courses, :groups, :string
  end
end
