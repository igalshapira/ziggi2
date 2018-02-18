class StaffController < ApplicationController
  before_filter :login_check

  #match 'staff/:id' => 'staff#info'
  include StaffHelper
  def info
    json = get_staff_info(params[:id])
    render :text => JSON.dump(json)
  end

  #match 'staffs' => 'staff#update', :via => [:put]
  def update
    update = {:user_id => @user['id']}
    staff = Staff.find(params[:id])
    render :status => 404, :text => "404" unless staff

    if params[:phone]
      val = params[:phone]
      update[:phone] = val
    end
    if params[:room]
      val = params[:room]
      update[:room] = val
    end
    if params[:email]
      val = params[:email]
      update[:email] = val
    end
    if params[:reception]
      val = params[:reception]
      update[:reception] = val
    end
    staff.update_attributes update
    if params[:editable]
      return render :text => val
    end
    redirect_to "/staff/" + params[:id]
  end
end
