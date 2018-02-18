class BeerNotificationController < ApplicationController
    protect_from_forgery :except => [:create]

    def create
	BeerNotification.create!(:params => params, :user_id => params[:user], :status => params[:payment_status])
	render :nothing => true
    end
end
