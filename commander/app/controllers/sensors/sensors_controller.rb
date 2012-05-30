class Sensors::SensorsController < ApplicationController
  # GET /sensors/sensors
  # GET /sensors/sensors.json
  def index
    if params[:platform_id].nil?
      flash[:error] = "Sensors must be accessed through a platform!"
      return redirect_to "/"
    end
    @sensors_sensors = Sensors::Sensor.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sensors_sensors }
    end
  end

  # GET /sensors/sensors/1
  # GET /sensors/sensors/1.json
  def show
    if params[:platform_id].nil?
      flash[:error] = "Sensors must be accessed through a platform!"
      return redirect_to "/"
    end
    @sensors_sensor = Sensors::Sensor.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sensors_sensor }
    end
  end

  # GET /sensors/sensors/1/edit
  def edit
    @sensors_platform = Sensors::Platform.where(slug: params[:platform_id]).first
    @sensors_sensor = @sensors_platform.sensors.find(params[:id])
  end

  # POST /sensors/sensors
  # POST /sensors/sensors.json
  def create
    @sensors_platform = Sensors::Platform.where(slug: params[:platform_id]).first
    @sensors_sensor = Sensors::Sensor.new(params[:sensors_sensor])

    respond_to do |format|
      if @sensors_platform.sensors.push( @sensors_sensor )
        format.html { redirect_to @sensors_platform, notice: 'Sensor was successfully created.' }
        format.json { render json: @sensors_sensor, status: :created, location: @sensors_sensor }
      else
        format.html { render action: "new" }
        format.json { render json: @sensors_sensor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sensors/sensors/1
  # PUT /sensors/sensors/1.json
  def update
    @sensors_platform = Sensors::Platform.where(slug: params[:platform_id]).first
    @sensors_sensor = @sensors_platform.sensors.find(params[:id])

    respond_to do |format|
      if @sensors_sensor.update_attributes(params[:sensors_sensor])
        format.html { redirect_to @sensors_platform, notice: 'Sensor was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @sensors_sensor.errors, status: :unprocessable_entity }
      end
    end
  end

end
