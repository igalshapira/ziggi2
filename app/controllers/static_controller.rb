class StaticController < ApplicationController
  layout 'static'

  def password_recovery
    @user = User.find_by_email(params[:email])
    return if not @user

    # If already sent - just update the stamp
    r = Recovery.find_or_create_by_user_id(:user_id => @user.id)
    if not r.recover_hash
      r.recover_hash = Digest::SHA1.hexdigest Time.now.to_s
    end
    r.save
    uhash = @user.id.to_s + Digest::SHA1.hexdigest("YA" + @user.email + "YA")
    link = 'http://www.ziggi.co.il/recover/' + uhash + '/' + r.recover_hash
    Mailer.password_recovery(@user.email, link).deliver
  end
end
