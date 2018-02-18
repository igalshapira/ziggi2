class CreateBeerNotifications < ActiveRecord::Migration
  def change
    create_table :beer_notifications do |t|
      t.text :params
      t.integer :user_id
      t.string :status

      t.timestamps
    end
  end
end
