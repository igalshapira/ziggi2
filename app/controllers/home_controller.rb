class HomeController < ApplicationController
  layout 'home'
  before_filter :login_check_and_skip_login
end
