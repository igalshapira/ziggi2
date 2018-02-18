class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.integer :semester_id
      t.string :search
      t.string :results

      t.timestamps
    end
  end
end
