class CreateExams < ActiveRecord::Migration
  def change
    create_table :exams do |t|
      t.string :exam_type
      t.integer :course_id
      t.datetime :time
      t.string :room

      t.timestamps
    end
  end
end
