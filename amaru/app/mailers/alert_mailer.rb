class AlertMailer < ActionMailer::Base
  default :from => "no_reply@sensor.gina.alaska.edu"

  def alert_email(alert, message, platform)
    body = "#{message}\n#{alert.message}"
    subject = "Alert for platform #{platform}"

    mail(:to => alert.emails, :subject => subject) do |format|
      format.text { render :text => body }
    end
  end
end