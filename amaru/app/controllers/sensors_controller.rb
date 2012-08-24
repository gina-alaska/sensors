class SensorsController < ApplicationController
  before_filter :fetch_parent

  def index
    @sensors = @parent.sensors

    respond_to do |format|
      format.html { render layout: "group_layout" }
      format.json { render json: @sensor }
    end
  end

  def new
    @sensor = @parent.sensors.build 

    respond_to do |format|
      format.html
      format.json { render json: @sensor }
    end
  end

  def edit
    @sensor = @parent.sensors.where(id: params[:id]).first 

    respond_to do |format|
      format.html
      format.json { render json: @sensor }
    end
  end

  def create
    @sensor = @parent.sensors.build(params[:sensor])

    respond_to do |format|
      if @sensor.save
        format.html { redirect_to @parent, notice: 'Sensor was successfully created.' }
        format.json { head :no_content }
      else
        format.html { render action: "new" }
        format.json { render json: @sensor.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @sensor = @parent.sensors.where( id: params[:id] ).first

    respond_to do |format|
      if @sensor.update_attributes(params[:sensor])
        format.html { redirect_to @parent, notice: 'Sensor was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @sensor.errors, status: :unprocessable_entity }
      end
    end
  end

  protected

  def fetch_parent
    if params[:group_id]
      @group = @parent = Group.find(params[:group_id]) if params[:group_id]
      @return_to = group_sensors_path(@group)
    end
    if params[:platform_id]
      @platform = @parent = Platform.where(slug: params[:platform_id]).first
      @return_to = @platform
    end
  end
end
