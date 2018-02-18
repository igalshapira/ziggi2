class RoomController < ApplicationController
  before_filter :login_check

  include RoomHelper
  def all
    rooms = get_rooms_info
    render :text => JSON.dump(rooms)
  end
end
