
class SensorsController < ApplicationController
  # GET /sensors
  # GET /sensors.json
  def index
    @sensors = Sensor.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sensors }
    end
  end

  # GET /sensors/1
  # GET /sensors/1.json
  def show
    @sensor = Sensor.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sensor }
    end
  end

  # GET /sensors/new
  # GET /sensors/new.json
  def new
    @platform = Platform.where( slug: params[:platform_id] ).first
    @sensor = Sensor.new
    session["platformTabShow"] = '#sensors'

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sensor }
    end
  end

  # GET /sensors/1/edit
  def edit
    @platform = Platform.where( slug: params[:platform_id] ).first
    @sensor = @platform.sensors.find(params[:id])
  end

  # POST /sensors
  # POST /sensors.json
  def create
    @platform = Platform.where( slug: params[:platform_id] ).first
    @sensor = @platform.sensors.build(params[:sensor])

    respond_to do |format|
      if @sensor.save
        format.html { redirect_to @platform, notice: 'Sensor was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "new" }
        format.json { render json: @sensor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sensors/1
  # PUT /sensors/1.json
  def update
    @platform = Platform.where( slug: params[:platform_id] ).first
    @sensor = @platform.sensors.find(params[:id])
    session["platformTabShow"] = '#sensors'

    respond_to do |format|
      if @sensor.update_attributes(params[:sensor])
        format.html { redirect_to @platform, notice: 'Sensor was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @sensor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sensors/1
  # DELETE /sensors/1.json
  def destroy
    @sensor = Sensor.find(params[:id])
    @sensor.destroy

    respond_to do |format|
      format.html { redirect_to sensors_url }
      format.json { head :no_content }
    end
  end
end