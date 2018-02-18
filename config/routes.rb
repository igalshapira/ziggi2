Ziggi::Application.routes.draw do
  root :to => 'home#index'

  get '/ziggi'  => redirect('/')

  get '/full_info', :to => 'app#get_data'

  get "admin" => "admin#admin"
  get "admin/logins.csv" => "admin#logins"
  get "admin/logins_clear" => "admin#logins_clear"
  match "admin/:university" => "admin#university", :constraints => { :university => /[0-9]+/ }
  match "admin/users/:page" => "admin#users"
  match "admin/user/:user" => "admin#user", :constraints => { :user => /[^\/]+/ }
  match "admin/reset/:user/:password" => "admin#reset"
  match "admin/send_beer/:user" => "admin#send_beer"
  match "admin/events/:page" => "admin#events"
  match "admin/event/:event" => "admin#event"
  match "admin/staff" => "admin#staff"
  get "admin/beer" => "admin#beer"

  #Login
  get '/login', :to => 'sessions#login'
  get '/signup', :to => 'sessions#signup'
  get '/logout', :to => 'sessions#destroy'
  match '/pass', :to => 'sessions#update_password'
  match '/auth/:provider/callback', :to => 'sessions#create'
  match '/auth/failure', :to => 'sessions#failure'
  match '/auth/:provider/app/:access_token/:uid' => 'sessions#app', :constraints => { :access_token => /[^\/]+/ }
  get 'recover/:uhash/:hash' => 'application#password_recovery'

  #Schedule
  get 'schedule' => 'schedule#index'
  match 'share' => 'share#delete', :via => [:delete]
  match 'share' => 'share#create', :via => [:get]
  get 'share_denied' => 'share#share_denied'
  get 'share/:uhash/:hash' => 'share#share'
  get 'summary' => 'schedule#summary'

  # Update User University and Semester
  match '/universities', :to => 'university#all'
  match '/university/:uni', :to => 'user#update_university'
  match '/remove/courses' => 'course#remove_courses', :via => [:post]
  match '/remove/:number' => 'user#remove_course', :constraints => { :number => /[^\/]+/ }
  match '/groups/' => 'user#save_groups', :via => [:post]
  get '/courses' => 'user#courses'
  match '/add/courses/get' => 'course#add_and_get_courses', :via => [:post]
  match '/add/courses' => 'course#add_courses', :via => [:post]
  match '/add/course/:id' => 'user#add_course'
  match '/add/event/:id' => 'user#add_event'

  # Semester information
  match '/semester', :to => 'semester#info', :via => [:get]
  match '/semester', :to => 'user#update_semester', :via => [:post]

  # Search for courses
  match 'search/:string' => 'course#find', :constraints => { :string => /[^\/]+/ }
  match 'auto' => 'course#auto_complete'
  match 'course/:number' => 'course#info', :constraints => { :number => /[^\/]+/ }
  match 'sport/:day/:hour' => 'course#find_sport'
  match 'sylabus/:number' => 'course#sylabus', :constraints => { :number => /[^\/]+/ }

  # Staff
  match 'staff' => 'staff#update', :via => [:post]
  match 'staff/:id' => 'staff#info'
  get 'rank/:id' => 'staff_rank#info'
  match 'rank' => 'staff_rank#rank', :via => [:post]

  # Events
  match 'events' => 'event#all'
  match 'event/:id' => 'event#delete', :via => [:delete], :constraints => { :ud => /[0-9]+/ }
  get 'event/:id' => 'event#show', :constraints => { :ud => /[0-9]+/ }
  match 'event' => 'event#create'
  match 'event_del/:event_id' => 'event#delete'
  match 'public/:str' => 'event#search_public', :constraints => { :str => /[^\/]+/ }

  # Exports
  get '/export/schedule.vcs' => 'export#vcs'

  # Messages
  get '/messages' => 'messages#show'

  # Rooms
  match '/rooms' => 'room#all'

  get '/recommended' => 'recommended#find'
  match '/recommended' => 'recommended#get_recommended', :via => [:post]
  match '/save_degree_data' => 'user#save_degree_data', :via => [:post]

  get '/token' => 'app#get_csrf_token'

  # Static Widgets
  get '/w/agenda' => 'widgets#agenda'
  get '/w/cal' => 'widgets#calendar'
  
  # Beer Donations
  match '/beer_notify/:user' => 'beer_notification#create'

  # Static pages
  match ':action' => 'static#:action'
end
