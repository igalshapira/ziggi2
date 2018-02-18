class AddUsersInfoTable < ActiveRecord::Migration

  def change
    add_column :users, :year_in_degree, :integer
    add_column :users, :department, :integer
    add_column :users, :degree, :integer
  end
end
