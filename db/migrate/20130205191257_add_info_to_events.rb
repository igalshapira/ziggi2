class AddInfoToEvents < ActiveRecord::Migration
  def change
      add_column :events, :public, :boolean, :default => false
      add_column :events, :weekly, :boolean, :default => false
  end
end
