# encoding: UTF-8
class Mailer < ActionMailer::Base
  default from: "ziggi@ziggi.co.il"

  def password_recovery(email, link)
    @link = link
    mail(to: email,
         subject: 'איפוס סיסמא')
  end

  def debug_error(obj, obj1)
      @obj = obj
      @obj1 = obj1
      mail(to: "error@ziggi.co.il", subject: 'Error message')
  end

  def report_missing_building(message)
    @message = message
    mail(to: "error@ziggi.co.il", subject: 'Missing Building Reported ('+ DateTime.now().to_s() +')')
  end
end
