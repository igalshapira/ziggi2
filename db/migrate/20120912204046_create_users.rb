class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.integer :year, :default => 2003
      t.integer :semester, :default => 1
      t.integer :university_id, :default => 1
      t.string :gender

      t.timestamps
    end
  end
end
