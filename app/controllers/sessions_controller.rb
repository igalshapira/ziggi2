class SessionsController < ApplicationController
  #match '/auth/:provider/callback', :to => 'sessions#create'
  def create
    auth_hash = request.env['omniauth.auth']

    auth = Authorization.find_or_create(auth_hash)
    if not auth or not auth.user
    	return render :status => 500
    end
    session[:user_id] = auth.user.id

    redirect_to schedule_url
  end

  #match '/auth/:provider/app/:access_token/:id' => 'sessions#app'
  def app
    uri = nil
    if params[:provider] == "facebook" then
      uri = URI("https://graph.facebook.com/me?access_token=" + params[:access_token])
    end
    if params[:provider] == "google_oauth2"
      uri = URI("https://www.googleapis.com/oauth2/v1/userinfo?access_token=" + params[:access_token])
    end

    return render :status => 404, :text => "404" if not uri

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
    request = Net::HTTP::Get.new(uri.request_uri)
    res = http.request(request)

    # TODO: Check if OK
    info = JSON.parse(res.body)
    # Match :id to info.id
    return render :status => 403, :text => "403" if info['id'] != params[:uid]

    auth_hash = {}
    auth_hash['provider'] = params['provider']
    auth_hash['uid'] = params['uid']
    auth_hash['info'] = info
    auth_hash['extra'] = {}
    auth_hash['extra']['raw_info'] = {'gender' => info['gender']}
    auth = Authorization.find_or_create(auth_hash)
    session[:user_id] = auth.user.id
    return render :status => 200, :json => {'email' => info['email']}
  end

  def failure
    render :text => "Some error occurs"
  end

  def destroy
    session[:user_id] = nil
    cookies[:remember] = nil
    cookies[:email] = nil
    redirect_to root_url
  end

  def login
    login = {:login => false, :email => false}
    u = User.find_by_email(params[:email])
    return render :json => login if not u

    login[:email] = true
    uid = Digest::SHA1.hexdigest("YA" + params[:password] + "YA")
    auth = Authorization.find_by_provider_and_uid_and_user_id("ziggi", uid, u.id)
    return render :json => login if not auth

    login[:login] = true
    session[:user_id] = u.id
    if params[:remember] == "true"
        cookies[:remember] = { :value => u.id, :expires => 6.months.from_now }
        cookies[:email] = { :value => u.email, :expires => 6.months.from_now }
    end
    return render :json => login
  end

  def signup
    login = {:login => false, :email => false}
    u = User.find_by_email(params[:email])
    return render :json => login if u # User already exists. Shouldn't happen
    # XXX Verify that email is actually email
    # /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/
    # /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i.match(params[:email]).nil?
    uid = Digest::SHA1.hexdigest("YA" + params[:password] + "YA")
    semester = Semester.find_by_university_id_and_active(1, true)
    user = User.new :name => params[:email], :email => params[:email], :semester_id => semester.id
    user.save
    auth = Authorization.new :user_id => user.id, :provider => "ziggi", :uid => uid
    auth.save

    session[:user_id] = user.id
    login = {:login => true, :email => true}
    return render :json => login
  end

  def update_password
    uid = Digest::SHA1.hexdigest("YA" + params[:password] + "YA")
    auth = Authorization.find_by_user_id_and_provider(session[:user_id], "ziggi")
    if not auth
      auth = Authorization.new :user_id => session[:user_id], :provider => "ziggi"
    end
    auth.update_attributes :uid => uid
    auth.save
    render :json => {:result => true}
  end
end
