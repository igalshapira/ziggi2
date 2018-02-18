class AddSemesterIdToUsers < ActiveRecord::Migration
  def change
      add_column :users, :semester_id, :integer, :default => 1
      remove_column :users, :year, :semester, :university_id
  end
end
