class EventController < ApplicationController
  include EventHelper
  before_filter :login_check

  # User can see one of several types of events
  # 1. Private and belongs to this user (/events)
  # 2. Public and were selected by user (/events)
  # 3. Public and belongs to user course (/course/:number)
  # 4. Public and belongs to user staff (/course/:number?)

  #match 'events' => 'event#all'
  def all
    render :json => all_events
  end

  def show
    e = Event.find_by_id(params[:id])
    if not e or (not e.public and not e.user_id == @user[:id])
      return render :json => {}
    end
    u = UserEvent.find_by_user_id_and_event_id(@user[:id], params[:id])
    e[:selected] = u != nil
    render :json => e.to_json
  end

  def create
    #For security: verify that course_id belongs to user
    id = params[:id].to_i
    if id > 0
      e = Event.find_by_id(id)
      if not e.public and not e.user_id == @user[:id]
        return render :status => 403, :text => "403" if not e
      end
    else
      e = Event.create! :user_id => @user.id, :university_id => @user.semester.university.id,
                        :title => params[:title]
      # When creating - automatic add it to user selection
      u = UserEvent.find_or_create_by_user_id_and_event_id(:user_id => @user[:id], :event_id => e.id)
      u.save
    end
    return render :json => {} if not e
    a = {}
    a[:title] = params[:title] if params[:title]
    a[:content] = params[:content] if params[:content]
    a[:location] = params[:location] if params[:location]
    a[:weekly] = params[:weekly] == "true" if params[:weekly]
    a[:public] = params[:public] == "true" if params[:public]
    a[:course_id] = params[:course_id] if params[:course_id]
    a[:staff_id] = params[:staff_id] if params[:staff_id]
    a[:color] = params[:color].slice(1, 6).to_i(16) if params[:color]
    a[:date_start] = params[:date_start] if params[:date_start]
    a[:date_end] = params[:date_end] if params[:date_end]

    e.update_attributes a

    e[:selected] = true
    render :json => e.to_json
  end

  #match 'event/:id' => 'event#delete', :via => [:delete], :constraints => { :ud => /[0-9]+/ }
  def delete
    e = Event.find_by_id(params[:id])
    return render :status => 404, :text => "404" unless e
    # Check if can remove it
    # If belongs to course or staff, anyone can delete it
    if e.course_id > 0 or e.staff_id > 0 then
      e.destroy
      return render :json => {}
    end
    if not e.public then
      if e.user_id == @user.id
        e.destroy
        return render :json => {}
      end
      return render :status => 403, :text => "403" unless e
    end
    # Else - we are public, anyone can delete. So we simply remove it from user
    if e
      e.destroy
    end
    render :json => {}
  end

  def search_public
    events = []
    Event.where("public = true AND course_id = 0 AND date_start >= ? AND date_start <= ? AND title LIKE ?", @user.semester.start, @user.semester.end, "%#{params[:str]}%").each do |e|
      events.push({:id => e.id, :title => e.title})
    end
    render :json => events
  end
end
