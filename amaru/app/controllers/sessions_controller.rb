class SessionsController < ApplicationController
  skip_before_filter :require_login

  def create
    user = User.where(:provider => auth_hash['provider'], 
                      :uid => auth_hash['uid']).first || User.create_with_omniauth(auth_hash)
    session[:user_id] = user.id
    
    unless user.authority or user.email.nil?
      p = Authority.where(email: user.email).first
      user.authority = p
    end
    
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
    redirect_to '/auth/gina'
  end
  
  def failure
    redirect_to dashboard_path, notice: "Authentication error: #{params[:message].humanize}"
  end
  
  protected
  
  def auth_hash
    request.env['omniauth.auth']
  end
end