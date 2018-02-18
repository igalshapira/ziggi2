class CreateDays < ActiveRecord::Migration
  def change
    create_table :days do |t|
      t.datetime :date
      t.integer :university_id
      t.string :title

      t.timestamps
    end
  end
end
