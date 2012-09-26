class OrganizationsController < ApplicationController
  skip_before_filter :require_login

  before_filter :fetch_organization, :only => [:edit, :update, :show, :destroy]
  
  def index
    @organizations = current_user.organizations
  end

  def new
    @organization = Organization.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @organization }
    end
  end

  def edit
    #@organization = Organization.where( id: params[:id] ).first
    # if @organization.admin? current_user
    # if current_user.admin? this is very bad
  end

  def create
    @organization = Organization.new(params[:organization])
    @organization.users << current_user
    current_user.current_org = @organization

    # Set admin on user that created the organization
    @organization.memberships.where(user: current_user).update_attribute(:admin, true)

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
    #@organization = current_user.current_org
    #@organization = Organization.where( id: params[:id] ).first
    return access_denied unless current_user.admin?

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

  protected

  def fetch_organization
    @organization = current_user.current_org
  end
end
