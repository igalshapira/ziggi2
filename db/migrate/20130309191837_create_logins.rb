class CreateLogins < ActiveRecord::Migration
  def change
    create_table :logins do |t|
      t.string :ip
      t.string :browser
      t.string :provider
      t.string :referrer

      t.timestamps
    end
  end
end
