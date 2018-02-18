class AddAckToBeerNotifications < ActiveRecord::Migration
    def change
	add_column :beer_notifications, :ack, :bool
    end
end
