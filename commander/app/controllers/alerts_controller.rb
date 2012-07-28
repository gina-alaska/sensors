
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
    @alert.attributes = params[:alert]
    session["platformTabShow"] = '#alerts'

    respond_to do |format|
      if @alert.save
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

  def add
    @platform = Platform.where( slug: params[:platform_id] ).first
    @alert = Alert.find(params[:id])
    @command = @alert.alert_event.create(command: "alive", index: @alert.commands.count)

    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "command", :locals => {:platform => @platform, :alert => @alert}
        else
          redirect_to edit_platform_alert_path(@platform, @alert)
        end        
      }
    end
  end

  def change
  protected

  def alert_params
    e = params[:alert]
#    e[:commands] = params[:commands]
    e[:from].reject! { |i| i == '' } if e[:from].count > 1
    return e
  end
end
