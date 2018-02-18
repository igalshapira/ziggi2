class AddUniversityIdToRooms < ActiveRecord::Migration
  def change
      add_column :rooms, :university_id, :integer
  end
end
