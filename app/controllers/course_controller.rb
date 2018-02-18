# encoding: UTF-8
require 'string'
require 'bgu'

class CourseController < ApplicationController
  include CourseHelper
  # GET /courses/20119811
  # GET /courses/search_string
  before_filter :login_check
  before_filter :print_all_courses
  layout 'home'

  def print_all_courses
    # course/0
    if params[:number] == "0" and session[:user_id] == 1
      i = 0
      text = ""
      Course.all.each do |c|
        i = i + 1
        text = text + c.inspect.gsub(/</, '') + "\n"
        # Full info
        CourseGroups.find_all_by_course_id(c[:id]).each do |g|
          text = text + g.inspect + "\n"
          GroupHours.find_all_by_coursegroup_id(g[:id]).each do |h|
            text = text + h.inspect + "\n"
          end
        end
        text = text + "\n\n"
      end
      text = text + "Total: " + i.to_s
      return render :text => text
    end
  end

  def add_event(e)
    sel = UserEvent.find_by_user_id_and_event_id(@user[:id], e[:id])
    event = {}
    event['id'] = e.id
    event['title'] = e.title
    event['location'] = e.location
    event['updated_at'] = e.updated_at
    event['date_start'] = e.date_start
    event['date_end'] = e.date_end
    event['weekly'] = e.weekly
    event['staff_id'] = e.staff_id
    event['course_id'] = e.course_id
    if sel and sel[:selected]
      event['selected'] = true
    else
      event['selected'] = false
    end
    event['updated_by'] = e.user.name.split(' ')[0]
    event
  end

  def load_events(course_id)
    events = []
    Event.find_all_by_course_id(course_id).each do |e|
      events.push(add_event(e))
    end
    events
  end

  def load_recepetion_hours(course)
    reception = []
    staff = []
    course['groups'].each do |g|
      staff.push(g['staff']['id'])
    end
    Event.where("staff_id IN (?)", staff).each do |e|
      reception.push(add_event(e))
    end
    reception
  end

  # Find specific course by number and return its json or nil
  def find_by_number(id)
    id = @unilib.course_normalize(id)
    course = course_from_cache(id)

    if not course
      course = @unilib.find_by_number(id, @user.semester.year, @user.semester.semester, @user.semester.university.id)
      return nil if not course
      save_course_to_cache course
      course = course_from_cache(course['number'])
    end

    # Add events to course
    course['events'] = load_events(course['id'])
    # Add reception hours of staff
    course['reception_hours'] = load_recepetion_hours(course)
    course
  end

  def save_results_to_cache (search, results)
    cache = Searches.find_by_search_and_semester_id(search, @user.semester[:id])
    if cache
      # Force update of updated_at even if results are identical to last one
      cache.update_attributes :results => JSON.dump(results), :updated_at => Time.now
    else
      Searches.create :search => search, :results => JSON.dump(results), :semester_id => @user.semester[:id]
    end
  end

  def search_results_in_cache (search)
    cache = Searches.find_by_search_and_semester_id(search, @user.semester[:id])
    # 2 Days caching for course names
    if cache and cache.results and (Time.now - cache.updated_at) < 2.day
      results = JSON.parse(cache.results)
      results["cache"] = true
      return results
    end
    nil
  end

  def find
    #If :number is only digits, dots and dashes we assume it is course
    #number
    if /^[0-9.-]{6,10}$/.match(params[:string])
      course = find_by_number(params[:string])
      if course
        json = [{'number' => course['number'],
                 'name' => course['name']}]
        results = {'results' => json}
      end
    else
      # Find list of courses according to search string, or nil if none
      # found
      results = search_results_in_cache(params[:string])
      return render :text => JSON.dump(results) if results

      results = @unilib.find_by_name(params[:string], @user.semester.year, @user.semester.semester)
      save_results_to_cache(params[:string], results)
    end
    return render :text => JSON.dump(results) unless not results
    return render :text => "{}"
  end

  def find_sport
    stringfy = "SPORT_" + params[:day] + "_" + params[:hour]
    results = search_results_in_cache(stringfy)
    return render :text => JSON.dump(results) if results

    results = @unilib.find_sport(params[:string], @user.semester.year, @user.semester.semester, params[:day], params[:hour])
    save_results_to_cache(stringfy, results) if results
    return render :text => JSON.dump(results) unless not results
    return render :text => "{}"
  end

  def info
    json = find_by_number(params[:number])
    return render :text => JSON.dump(json) unless not json
    return render :text => "{}"
  end

  def auto_complete
    auto_complete = {}
    results = Course.where("name LIKE ?", "%" + params[:term] + "%").limit(25)
    results.each do |r|
      auto_complete[r.number] = r.name
    end

    return render :json => auto_complete
  end

  #Add courses, return only add status
  #match '/add/courses'
  def add_courses
    objects = JSON.parse(request.raw_post)
    result = []
    objects.each do |item|
      obj = {}
      obj['number'] = item["number"]
      coursenumber = @unilib.course_normalize(item["number"])
      course = find_by_number(coursenumber)
      if not course
        obj['success'] = false
      else
        u = UserCourse.where(:user_id => @user[:id], :course_id => course["id"],
                             :group => 0).first_or_create
        obj['success'] = true
      end
      result.push(obj)
    end

    render :text => JSON.dump(result)
  end

  #Add courses and return courses data
  #match '/add/courses/get'
  def add_and_get_courses
    objects = JSON.parse(request.raw_post)
    result = []
    objects.each do |item|
      coursenumber = @unilib.course_normalize(item["number"])
      course = find_by_number(coursenumber)
      if not course
        course = {}
        course['number'] = item['number']
        course['success'] = false
      else
        u = UserCourse.where(:user_id => @user[:id], :course_id => course["id"],
                             :group => 0).first_or_create
        course['success'] = true
      end
      result.push(course)
    end

    render :text => JSON.dump(result)
  end


  #match '/remove/courses'
  def remove_courses
    objects = JSON.parse(request.raw_post)
    result = []
    objects.each do |item|
      resultObject = {}
      coursenumber = @unilib.course_normalize(item["number"])
      course = Course.find_by_number_and_semester_id(coursenumber, @user.semester[:id])
      resultObject["number"] = coursenumber
      if not course
        resultObject["success"] = false
      else
          UserCourse.find_all_by_user_id_and_course_id(@user[:id], course[:id]).each do |c|
            c.destroy
          end
          resultObject["success"] = true
      end

      result.push(resultObject)
    end
    render :text => JSON.dump(result)
  end
end

