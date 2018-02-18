class SemesterController < ApplicationController
  include SemesterHelper
  before_filter :login_check

  def info
    render :text => JSON.dump(semester_info(@user.semester))
  end
end
