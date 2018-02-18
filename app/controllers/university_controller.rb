class UniversityController < ApplicationController
  before_filter :login_check

  include UniversityHelper
  def all
    unis = get_universities_info
    render :text => JSON.dump(unis)
  end
end
