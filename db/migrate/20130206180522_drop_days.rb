class DropDays < ActiveRecord::Migration
  def change
      drop_table :days
      add_column :events, :university_id, :integer
      remove_column :events, :semester_id
  end
end
