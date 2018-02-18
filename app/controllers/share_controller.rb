class ShareController < ApplicationController
  before_filter :login_check, :only => [:create, :delete]

  # UHash is user.id + sha1("YA" + user.email + "YA")
  # Hash is random number stored in share models
  def share
    id = params[:uhash].slice(0, params[:uhash].length-40)
    @user = User.find_by_id(id)
    if not @user or (@user.id.to_s + Digest::SHA1.hexdigest("YA" + @user.email + "YA") != params[:uhash])
      return render 'share_denied'
    end
    s = Share.find_by_user_id(@user[:id])
    if not s or s[:share_hash] != params[:hash]
      return render 'share_denied'
    end
  end

  def create
    hash = Digest::SHA1.hexdigest Time.now.to_s
    s = Share.find_by_user_id(@user[:id])
    s = Share.new :user_id => @user[:id] unless s
    s.update_attributes :share_hash => hash
    s.save
    render :json => {:url => hash}
  end

  def delete
    s = Share.find_by_user_id(@user[:id])
    s.destroy if s
    render :json => {:url => ""}
  end
end
