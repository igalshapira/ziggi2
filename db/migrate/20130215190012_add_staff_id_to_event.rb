class AddStaffIdToEvent < ActiveRecord::Migration
  def change
      add_column :user_events, :staff_id, :integer
  end
end
