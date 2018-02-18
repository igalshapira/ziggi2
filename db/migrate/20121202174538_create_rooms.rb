class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.string :name
      t.text :comment
      t.float :lat
      t.float :lng

      t.timestamps
    end
  end
end
