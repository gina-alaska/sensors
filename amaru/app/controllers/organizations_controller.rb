class OrganizationsController < ApplicationController
  skip_before_filter :require_login
  
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
    @organization = Organization.where( id: params[:id] ).first
  end

  def create
    @organization = Organization.new(params[:organization])
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
    @organization = Organization.where( id: params[:id] ).first

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
end
