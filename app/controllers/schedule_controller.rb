class ScheduleController < ApplicationController
  include ScheduleHelper
  before_filter :login_check_and_redirect

  # get 'schedule' => 'schedule#index'
  def index
    # Sanity - Make sure semester is valid, and if not - select current one
    if not @user.semester
      curr = Semester.where("start < NOW() AND university_id = 1").order('id desc').first
      @user.update_attributes :semester_id => curr.id
      @user.save
    end
  end

  #get 'share/:hash' => 'schedule#share'
  def share
    render "index"
  end

  def summary
    # get_user_summary defined in schedule_helper.rb
    render :text => JSON.dump(get_user_summary)
  end
end
