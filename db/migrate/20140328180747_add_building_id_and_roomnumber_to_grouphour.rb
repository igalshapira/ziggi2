class AddBuildingIdAndRoomnumberToGrouphour < ActiveRecord::Migration
  def change
    add_column :group_hours, :building_id, :integer
    add_column :group_hours, :room_number, :integer
  end
end
