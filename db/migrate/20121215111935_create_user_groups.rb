class CreateUserGroups < ActiveRecord::Migration
  def change
    create_table :user_groups do |t|
      t.integer :user_course_id
      t.integer :course_group_id

      t.timestamps
    end
  end
end
