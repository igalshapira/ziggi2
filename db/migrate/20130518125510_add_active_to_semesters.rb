class AddActiveToSemesters < ActiveRecord::Migration
  def change
      add_column :semesters, :active, :boolean, :default => false
  end
end
