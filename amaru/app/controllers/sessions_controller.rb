class SessionsController < ApplicationController
  skip_before_filter :require_login

  def create
    user = User.where(:provider => auth_hash['provider'], 
                      :uid => auth_hash['uid']).first || User.create_with_omniauth(auth_hash)
    session[:user_id] = user.id

    if user.save!
      redirect_to dashboard_path, notice: "#{user.name} Logged In!"
    else
      redirect_to dashboard_path
    end
  end
  
  def destroy
    reset_session
    redirect_to dashboard_path, notice: "You have logged out!"
  end
  
  def new
#    if File.exist?("no_web")
#      redirect_to '/auth/developer'
#    else
      redirect_to '/auth/gina'
#    end
  end
  
  def failure
    redirect_to dashboard_path, notice: "Authentication error: #{params[:message].humanize}"
  end
  
  protected
  
  def auth_hash
    request.env['omniauth.auth']
  end
end
