class AlertsController < ApplicationController
  
  def index
    @group = Group.where( id: params[:group_id] ).first
    @alerts = @group.alerts.all

    respond_to do |format|
      format.html { render layout: "group_layout" }
      format.json { render json: @alerts }
    end
  end

  def show
    @platform = Platform.where( slug: params[:platform_id] ).first
    @alert = Alert.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @alert }
    end
  end

  def new
    @group = Group.where( id: params[:group_id] ).first
    @alert = Alert.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @alert }
    end
  end

  def edit
    @group = Group.where( id: params[:group_id] ).first
    @alert = @group.alerts.find(params[:id])
    @sensors = @group.all_raw_sensors
  end

  def create
    @group = Group.where( id: params[:group_id] ).first
    @alert = @group.alerts.build(params[:alert])

    respond_to do |format|
      if @alert.save
        format.html { redirect_to edit_group_alert_path(@group, @alert), notice: 'Alert was successfully created.' }
        format.json { render json: @alert, status: :created, location: @alert }
      else
        format.html { render action: "new" }
        format.json { render json: @alert.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @group = Group.where( id: params[:group_id] ).first
    @alert = @group.alerts.find(params[:id])

    respond_to do |format|
      if @alert.update_attributes(alert_params)
        format.html { redirect_to group_alerts_path(@group), notice: 'Alert was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @alert.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @group = Group.where( id: params[:group_id] ).first
    @alert = @group.alerts.find(params[:id])
    @alert.destroy

    respond_to do |format|
      format.html { redirect_to group_alerts_path(@group) }
      format.json { head :no_content }
    end
  end

  def remove
    @group = Group.where( id: params[:group_id] ).first
    @alert = @group.alerts.find(params[:id])
    @command = @alert.alert_events.find(params[:command_id])
    cindex = @command.index

    # Adjust indexes and remove command from database
    fixcom = @alert.alert_events.where(:index.gt => cindex)
    fixcom.each do |command|
      command.index = command.index-1
      command.save!
    end
    @command.destroy

    render :partial => "remove", :locals => {:command_id => params[:command_id]}
  end

  def add
    @group = Group.where( id: params[:group_id] ).first
    @alert = @group.alerts.find(params[:id])
    @command = @alert.alert_events.create(command: "alive", index: @alert.alert_events.count)

    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "alert_events", :locals => {:group => @group, :alert => @alert, :f => params["f"]}
        else
          redirect_to edit_group_alert_path(@group, @alert)
        end        
      }
      format.js
    end
  end

  protected

  def alert_params
    e = params[:alert]
    unless e[:alert_events_attributes].nil?
      e[:alert_events_attributes].each do |ekey, edata|
        e[:alert_events_attributes][ekey][:sensors].reject! { |i| i == '' } if e[:alert_events_attributes][ekey][:sensors].count > 1
      end
    end
    return e
  end
end
