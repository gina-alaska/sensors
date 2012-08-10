
class AlertsController < ApplicationController
  # GET /alerts
  # GET /alerts.json
  def index
    @platform = Platform.where( slug: params[:platform_id] ).first
    @alerts = Alert.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @alerts }
    end
  end

  # GET /alerts/1
  # GET /alerts/1.json
  def show
    @platform = Platform.where( slug: params[:platform_id] ).first
    @alert = Alert.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @alert }
    end
  end

  # GET /alerts/new
  # GET /alerts/new.json
  def new
    @platform = Platform.where( slug: params[:platform_id] ).first
    @alert = Alert.new
    session["platformTabShow"] = '#alerts'

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @alert }
    end
  end

  # GET /alerts/1/edit
  def edit
    @platform = Platform.where( slug: params[:platform_id] ).first
    @alert = Alert.find(params[:id])
    @sensors = @platform.sensors
    session["platformTabShow"] = '#alerts'
  end

  # POST /alerts
  # POST /alerts.json
  def create
    @platform = Platform.where( slug: params[:platform_id] ).first
    @alert = @platform.alerts.build(params[:alert])
    session["platformTabShow"] = '#alerts'

    respond_to do |format|
      if @alert.save
        format.html { redirect_to @platform, notice: 'Alert was successfully created.' }
        format.json { render json: @alert, status: :created, location: @alert }
      else
        format.html { render action: "new" }
        format.json { render json: @alert.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /alerts/1
  # PUT /alerts/1.json
  def update
    @platform = Platform.where( slug: params[:platform_id] ).first
    @alert = Alert.find(params[:id])
    session["platformTabShow"] = '#alerts'

    respond_to do |format|
      if @alert.update_attributes(alert_params)
        format.html { redirect_to @platform, notice: 'Alert was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @alert.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /alerts/1
  # DELETE /alerts/1.json
  def destroy
    @platform = Platform.where( slug: params[:platform_id] ).first
    @alert = Alert.find(params[:id])
    @alert.destroy
    session["platformTabShow"] = '#alerts'

    respond_to do |format|
      format.html { redirect_to @platform }
      format.json { head :no_content }
    end
  end

  def remove
    @platform = Platform.where( slug: params[:platform_id] ).first
    @alert = Alert.find(params[:id])
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
    @platform = Platform.where( slug: params[:platform_id] ).first
    @alert = Alert.find(params[:id])
    @command = @alert.alert_events.create(command: "alive", index: @alert.alert_events.count)

    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "alert_events", :locals => {:platform => @platform, :alert => @alert, :f => params["f"]}
        else
          redirect_to edit_platform_alert_path(@platform, @alert)
        end        
      }
      format.js
    end
  end

  protected

  def alert_params
    e = params[:alert]
    e[:alert_events_attributes].each do |ekey, edata|
      e[:alert_events_attributes][ekey][:sensors].reject! { |i| i == '' } if e[:alert_events_attributes][ekey][:sensors].count > 1
    end
    return e
  end
end