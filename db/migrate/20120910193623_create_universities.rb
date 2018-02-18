class CreateUniversities < ActiveRecord::Migration
  def change
    create_table :universities do |t|
      t.string :code
      t.string :name
      t.string :homepage
      t.float :lat
      t.float :lng

      t.timestamps
    end
  end
end
