# encoding: UTF-8
class MessagesController < ApplicationController
  before_filter :login_check

  # get '/messages' => 'messages#show'
  def show
    messages = []
    #if session[:herokuapp] and not cookies[:heroku]
    #    msg = { :title => "כתובת מקוצרת חדשה",
    #	:content => "ניתן לגשת לזיגי דרך הכתובת המקוצרת http://www.ziggi.co" }
    #    cookies.permanent[:heroku] = true
    #    messages.push msg
    #end
    #if not cookies[:msg1]
    #    # XXX Display only if user has some classes
    #    # And in semester #1
    #    msg = { :title => "דירוג מרצים סמסטר א'",
    #	:content => "האם דירגת כבר את המרצים של סמסטר א'?<br/><a href=\"#m=summary\">לחץ כאן לדירוג</a>" }
    #    messages.push msg
    #    cookies.permanent[:msg1] = true
    #end
    #if not cookies[:semester_32013]
    #    msg = { :title => "סמסטר קיץ",
    #	:content => "סמסטר קיץ נפתח לבניית מערכת.<br/>לחצו על '&gt;' מעל המערכת למעבר לסמסטר הבא." }
    #    messages.push msg
    #    cookies.permanent[:semester_32013] = true
    #end
    #if not cookies[:msg_agenda]
    #    msg = { :title => "חדש באתר",
    #	:content => "תמיכה מוגברת בסמרטפונים וטבלטים.<br/> ווידג'ט סדר יום חדש למציאת השיעור הבא בקלות.<br/> נסו לגלוש בסמטרפון הקרוב." }
    #    messages.push msg
    #    cookies.permanent[:msg_agenda] = true
    #end
   #days = Time.now - Time.new(2015, 1, 15)
   #if not cookies[:semester_22015] and days < 30.day
   #    msg = { :title => "סמסטר אביב",
   #	:content => "סמסטר אביב נפתח לבניית מערכת.<br/>לחצו על '&gt;' מעל המערכת למעבר לסמסטר הבא." }
   #    messages.push msg
   #    cookies.permanent[:semester_22015] = true
   #end
    
    # Show beer messages to old users who did not donate just yet
   # beer = BeerNotification.find_by_user_id(@user[:id])
   # days = Time.now - @user.created_at.to_time
   # if beer # Did we say thank you nicely?
	#if not beer.ack
	#    msg = { :content => 'תודה רבה על תרומתך לזיגי!<br/>צוות זיגי מודה לך מכל הלב על העזרה.'}
	#    messages.push msg
	#    beer.ack = true
	#    beer.save
	#end
   # elsif days > 120.day # This is an old user
	#if (not cookies[:beerc] or cookies[:beerc].to_i > 10)
	#    msg = { :content => 'זיגי עזר לך כל השנה. לא תפרגן לו בבירה?
	#    <a href="javascript:ziggi.beer()">לחץ פה לפרטים</a>',
	#    :position => "center" }
	#    messages.push msg
	#    cookies[:beerc] = 0
	#else
	#    cookies[:beerc] = cookies[:beerc].to_i + 1
	#end
    #end

   days = Time.now - Time.new(2015, 10, 23)
   if not cookies[:semester_12016] and days < 14.day
       msg = { :title => "בהצלחה",
   	:content => "בהצלחה לכל הסטודנטים בסמסטר א' 2016!" }
       messages.push msg
       cookies.permanent[:semester_12016] = true
   end

    if session[:recovery]
      msg = {:title => "שינוי סיסמא",
             :content => "נכנסת דרך לינק חד פעמי לשינוי סיסמא. שנה את הסיסמא דרך תפריט הגדרות בצד שמאל של התפריט העליון."}
      messages.push msg
      session[:recovery] = false
    end
    render :json => messages
  end
end
