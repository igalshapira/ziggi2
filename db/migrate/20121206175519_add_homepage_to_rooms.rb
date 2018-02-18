class AddHomepageToRooms < ActiveRecord::Migration
  def change
      add_column :courses, :homepage, :string
  end
end
