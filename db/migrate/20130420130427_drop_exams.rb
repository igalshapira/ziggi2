class DropExams < ActiveRecord::Migration
  def change
      drop_table :exams
  end
end
