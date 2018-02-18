class ChangeSemesterDefaultValue < ActiveRecord::Migration
  def change
      change_column :users, :semester_id, :integer, :default => 0
  end
end
