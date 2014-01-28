class OrganizationsController < ApplicationController
  skip_before_filter :require_login

  before_filter :fetch_organization, :only => [:edit, :update, :show, :destroy, :add_user, :revoke]
  
  def index
    @organizations = current_user.organizations
  end

  def show
    system_users = User.all
    @unauth_users = system_users - @organization.users

    respond_to do |format|
      format.html 
      format.json { render json: @organization }
    end
  end

  def new
    @organization = Organization.new

    respond_to do |format|
      format.html
      format.json { render json: @organization }
    end
  end

  def edit
  end

  def create
    @organization = Organization.new(params[:organization])
    @organization.memberships << Membership.new(admin: true, user: current_user)
    @organization.users << current_user
    current_user.current_org = @organization

    current_user.save!

    respond_to do |format|
      if @organization.save
        format.html { redirect_to organizations_path, notice: 'Organization was successfully created.' }
        format.json { render json: @organization, status: :created, location: @organization }
      else
        format.html { render action: "new" }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    return access_denied unless current_user.org_admin?

    respond_to do |format|
      if @organization.update_attributes(params[:organization])
        format.html { redirect_to organizations_path, notice: 'Organization was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @organization = Organization.find(params[:id])
    @organization.destroy

    respond_to do |format|
      format.html { redirect_to organizations_path }
      format.json { head :no_content }
    end
  end

  def set_current
    @organization = Organization.where( id: params[:organization] ).first

    current_user.current_org = @organization
    current_user.save!

    respond_to do |format|
      format.js
    end
  end

  def add_user
    user = User.find(params["user"])
    @organization.add_user_to_org(user)
    
    system_users = User.all
    @unauth_users = system_users - @organization.users

    respond_to do |format|
      format.html { redirect_to organization_path(current_user.current_org), notice: "User was successfully added to #{@organization.name}." }
      format.json { head :no_content }
    end
  end

  def revoke
    user = User.find(params["user_id"])
    @organization.memberships.where(user_id: user).destroy_all
    @organization.current_users.delete(user)
    @organization.save

    respond_to do |format|
      format.html { redirect_to organization_path(current_user.current_org), notice: "User was successfully removed from #{@organization.name}." }
      format.json { head :no_content }
    end
  end

  protected

  def fetch_organization
    @organization = current_user.current_org
    require_current_org
  end
end
