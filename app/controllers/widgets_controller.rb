class WidgetsController < ApplicationController
  before_filter :login_check
  layout 'widget'

  include CourseHelper
  def agenda
      @agenda = get_agenda
  end

  def calendar
      @calendar = get_calendar
  end
end
