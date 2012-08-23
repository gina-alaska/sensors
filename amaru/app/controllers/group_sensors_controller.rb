class GroupSensorsController < ApplicationController
  layout "group_layout"

  def index
    @group = Group.where(id: params[:group_id]).first
    @status = @group.status.desc(:start_time).limit(6)
    @sensors = @group.sensors.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sensors }
    end
  end

  def show
    @sensor = Sensor.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sensor }
    end
  end

  def new
    @group = Group.where( id: params[:group_id] ).first
    @sensor = Sensor.new
    @status = @group.status.desc(:start_time).limit(6)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sensor }
    end
  end

  def edit
    @group = Group.where( id: params[:group_id] ).first
    @sensor = @group.sensors.find(params[:id])
    @status = @group.status.desc(:start_time).limit(6)
  end


  def destroy
    @group = Group.where( id: params[:group_id] ).first
    @sensor = @group.sensors.find(params[:id])
    @sensor.destroy

    respond_to do |format|
      format.html { redirect_to group_group_sensors_path(@group), notice: 'Sensor Deleted!' }
      format.json { head :no_content }
    end
  end
end
