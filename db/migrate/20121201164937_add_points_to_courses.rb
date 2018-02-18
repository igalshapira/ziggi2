class AddPointsToCourses < ActiveRecord::Migration
  def change
      add_column :courses, :points, :integer
  end
end
