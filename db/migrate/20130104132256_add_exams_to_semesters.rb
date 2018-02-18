class AddExamsToSemesters < ActiveRecord::Migration
  def change
      add_column :semesters, :exams_start, :date
      add_column :semesters, :exams_end, :date
  end
end
