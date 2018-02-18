class UserController < ApplicationController
  before_filter :login_check

  #match '/semester', :to => 'user#update_semester', :via => [:post]
  def update_semester
    semester = Semester.find_by_id(params[:id])
    return render :status => 404, :text => "" unless semester
    @user.update_attributes(:semester_id => params[:id])
    @user.save
    redirect_to '/semester'
  end

  #match '/university/:uni', :to => 'user#update_university'
  def update_university
    semester = Semester.find_by_university_id_and_active(params[:uni], true)
    return render :status => 404, :text => "University is not valid" unless semester

    @user.update_attributes(:semester_id => semester.id)
    @user.save
    # Delete any saved courses. Resets user information
    UserCourse.where(:user_id => @user.id).each do |c|
      c.destroy
    end
    redirect_to schedule_url
  end

  #match 'remove/:number' => 'user#remove_course'
  def remove_course
    course = Course.find_by_number_and_semester_id(params[:number], @user.semester[:id])

    return render :status => 404, :text => "Course not found" unless course

    UserCourse.find_all_by_user_id_and_course_id(@user[:id], course[:id]).each do |c|
      c.destroy
    end
    return render :text => JSON.dump(:number => params[:number])
  end

  #match '/groups/' => 'user#save_groups'
  def save_groups
    res = {}
    # Save groups
    if params[:groups]
      params[:groups].each do |e|
        grp = e[1]
        group = CourseGroups.find_by_id(grp['id'])
        next if not group
        if grp['s'] == "true" then
          u = UserCourse.find_or_create_by_user_id_and_course_id_and_group(:user_id => @user[:id], :course_id => group.course_id, :group => group.number)
          u.save
        else
          g = UserCourse.find_by_user_id_and_course_id_and_group(@user[:id], group.course_id, group.number)
          g.destroy unless not g
        end
      end
    end

    # Save events
    if params[:events]
      params[:events].each do |e|
        ev = e[1]
        if ev['s'] == "true" then
          u = UserEvent.find_or_create_by_user_id_and_event_id(:user_id => @user[:id], :event_id => ev['id'])
          u.save
        else
          u = UserEvent.find_by_user_id_and_event_id(@user[:id], ev['id'])
          u.destroy unless not u
        end
      end
    end
    render :text => JSON.dump(res)
  end

  #get '/courses' => 'user#courses'
  # Returns list of UserCourses
  include CourseHelper

  def courses
    json = get_courses_info
    render :text => JSON.dump(json)
  end


  #match '/add/course/:id' => 'user#add_course'
  def add_course
    u = UserCourse.where(:user_id => @user[:id], :course_id => params[:id],
                         :group => 0).first_or_create
    render :json => {}
  end

  #match '/add/event/:id' => 'user#add_event'
  def add_event
    UserEvent.where(:user_id => @user[:id], :event_id => params[:id]).first_or_create
    redirect_to "/event/" + params[:id]
  end

  def save_degree_data
    @user.update_attribute(:degree, params[:degree])
    @user.update_attribute(:year_in_degree, params[:year_in_degree])
    @user.update_attribute(:department, params[:department])
    render :text => JSON.dump({'success' => true})
  end
end
