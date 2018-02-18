class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :user_id
      t.integer :semester_id
      t.string :search
      t.string :content
      t.string :location

      t.timestamps
    end
  end
end
