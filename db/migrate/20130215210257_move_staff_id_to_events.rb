class MoveStaffIdToEvents < ActiveRecord::Migration
  def change
      add_column :events, :staff_id, :integer
      remove_column :user_events, :staff_id
  end
end
