class UpdateEventsDefaults < ActiveRecord::Migration
  def change
      change_column :events, :course_id, :integer, :default => 0
      change_column :events, :staff_id, :integer, :default => 0
      change_column :events, :university_id, :integer, :default => 0
      change_column :events, :title, :string, :null => false
  end
end
