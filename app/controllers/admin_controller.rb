class AdminController < ApplicationController
  layout 'admin'
  before_filter :login_check
  before_filter :admin_check

  def admin_check
    # XXX Use user roles here
    render :status => 403, :text => "403"
  end

  def event
    e = Event.find(params[:event])
    return render :status => 404, :text => "404" if not e

    return render :json => e if not params[:edit] == "true"
    return render :status => 403, :text => "403" if not params[:event] == params[:id]

    params.each do |p|
      next if not Event.column_names.include? p[0]
      next if p[0] == "id"
      next if p[0] == "created_at"
      next if p[0] == "updated_at"
      next if p[0] == "date_start"
      next if p[0] == "date_end"
      next if e[p[0]].to_s == p[1]

      e.update_attributes p[0] => p[1]
    end

    return render :json => e
  end

  def print_logins(del)
    csv = "date,ip,browser,provider,user_id,user name\n"
    Logins.limit(500).each do |l|
      csv = csv + '"' + l.created_at.to_s + '",' + l.ip + ',"' + l.browser + '",' + l.provider + "," + l.user_id.to_s + ',"' + l.user.name + "\"\n"
      l.destroy if del
    end
    render :text => csv
  end

  #get "admin/logins.csv" => "admin#logins"
  def logins
    print_logins(false)
  end

  #get "admin/logins_clear" => "admin#logins_clear"
  def logins_clear
    print_logins(true)
  end

  #match "admin/reset/:user/:password" => "admin#reset"
  def reset
    pass = Digest::SHA1.hexdigest(params[:password])
    uid = Digest::SHA1.hexdigest("YA" + pass+ "YA")
    auth = Authorization.find_by_user_id_and_provider(params[:user], "ziggi")
    if not auth
      auth = Authorization.new :user_id => params[:user], :provider => "ziggi"
    end
    auth.update_attributes :uid => uid
    auth.save
    render :text => "Password changed"
  end

  #match "admin/send_beer/:user" => "admin#send_beer"
  def send_beer
      BeerNotification.create!(:params => "",
			       :user_id => params[:user],
			       :status => "on the house")
      redirect_to :back
  end
end
