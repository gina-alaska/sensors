class OrganizationController < ApplicationController
  skip_before_filter :require_login
  
  def index
    @current_organization = current_user.organizations.first
    @organization = current_user.organizations
  end
end
