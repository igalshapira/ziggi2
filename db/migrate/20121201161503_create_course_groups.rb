class CreateCourseGroups < ActiveRecord::Migration
  def change
    create_table :course_groups do |t|
      t.integer :course_id
      t.integer :number
      t.integer :staff_id

      t.timestamps
    end
  end
end
