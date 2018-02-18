require 'bgu'

class ApplicationController < ActionController::Base
  protect_from_forgery

   def login_check
    @user = User.find_by_id(session[:user_id])
    if not @user
      render :status => 403, :text => "403"
      return
    end
    @unilib = @user.semester.university.code.classify.constantize
  end

  def login_check_and_redirect
    @user = User.find_by_id(session[:user_id]);
    if not @user
      return redirect_to root_url
    end
    @unilib = @user.semester.university.code.classify.constantize
  end

  def login_check_and_skip_login
	@user = User.find_by_id(session[:user_id]);
	if @user
	    return redirect_to schedule_url
	end

	@user = User.find_by_id(cookies[:remember])
	if @user and @user.email = cookies[:email]
	    session[:user_id] = cookies[:remember]
	    @unilib =  @user.semester.university.code.classify.constantize
	    return redirect_to schedule_url
	end
    end

  # One time login
  # UHash is user.id + sha1("YA" + user.email + "YA")
  # Hash is random number stored in Recovery model
  def password_recovery
    session[:user_id] = nil
    id = params[:uhash].slice(0, params[:uhash].length-40)
    @user = User.find_by_id(id)
    if not @user or (@user.id.to_s + Digest::SHA1.hexdigest("YA" + @user.email + "YA") != params[:uhash])
      return render :text => "Link is not valid or expired"
    end
    r = Recovery.find_by_user_id(@user[:id])
    if not r or r[:recover_hash] != params[:hash] or (Time.now - r.updated_at) > 1.day
      return render :text => "Link is not valid or expired"
    end
    r.destroy
    session[:user_id] = @user.id
    session[:recovery] = true
    redirect_to schedule_url
  end
end

