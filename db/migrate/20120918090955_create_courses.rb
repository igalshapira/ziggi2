class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :number
      t.string :name
      t.integer :semester_id
      t.text :json

      t.timestamps
    end
  end
end
