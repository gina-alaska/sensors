class Sensors::ProcessSensorsController < ApplicationController
  # GET /sensors/process_sensors
  # GET /sensors/process_sensors.json
  def index
    @sensors_platform = Sensors::Platform.where(slug: "barrow_mass_balance").first
    @sensors_process_sensors = Sensors::ProcessSensor.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sensors_process_sensors }
    end
  end

  # GET /sensors/process_sensors/1
  # GET /sensors/process_sensors/1.json
  def show
    @sensors_process_sensor = Sensors::ProcessSensor.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sensors_process_sensor }
    end
  end

  # GET /sensors/process_sensors/new
  # GET /sensors/process_sensors/new.json
  def new
    @sensors_platform = Sensors::Platform.where(slug: "barrow_mass_balance").first
    @sensors_process_sensor = Sensors::ProcessSensor.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sensors_process_sensor }
    end
  end

  # GET /sensors/process_sensors/1/edit
  def edit
    @sensors_platform = Sensors::Platform.where(slug: params[:platform_id]).first
    @sensors_process_sensor = Sensors::ProcessSensor.find(params[:id])
  end

  # POST /sensors/process_sensors
  # POST /sensors/process_sensors.json
  def create
    @sensors_platform = Sensors::Platform.where(slug: params[:platform_id]).first
    @sensors_process_sensor = Sensors::ProcessSensor.new(params[:sensors_process_sensor])

    @sensors_platform.process_sensor = @sensors_process_sensor
    respond_to do |format|
      if @sensors_process_sensor.save
        format.html { redirect_to @sensors_process_sensor, notice: 'Process sensor was successfully created.' }
        format.json { render json: @sensors_process_sensor, status: :created, location: @sensors_process_sensor }
      else
        format.html { render action: "new" }
        format.json { render json: @sensors_process_sensor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sensors/process_sensors/1
  # PUT /sensors/process_sensors/1.json
  def update
    @sensors_platform = Sensors::Platform.where(slug: params[:platform_id]).first
    @sensors_process_sensor = Sensors::ProcessSensor.find(params[:id])

    respond_to do |format|
      if @sensors_process_sensor.update_attributes(params[:sensors_process_sensor])
        format.html { redirect_to @sensors_process_sensor, notice: 'Process sensor was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @sensors_process_sensor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sensors/process_sensors/1
  # DELETE /sensors/process_sensors/1.json
  def destroy
    @sensors_process_sensor = Sensors::ProcessSensor.find(params[:id])
    @sensors_process_sensor.destroy

    respond_to do |format|
      format.html { redirect_to sensors_process_sensors_url }
      format.json { head :no_content }
    end
  end
end
