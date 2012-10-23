class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user
  before_filter :require_login

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def require_login
    unless current_user
      redirect_to dashboard_path, notice: 'Login First!' unless current_user
    end
  end

  def require_current_org
    if !current_user or current_user.current_org.nil?
      flash[:notice]="Please select a valid organization from the current organization drop down menu."
      redirect_to "/dashboard"
      return false
    end
  end
end
