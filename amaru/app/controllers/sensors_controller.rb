class SensorsController < ApplicationController
  layout "group_layout"

  def create
    @group = Group.where( id: params[:group_id] ).first
    @sensor = @group.sensors.build(params[:sensor])

    respond_to do |format|
      if @sensor.save
        format.html { redirect_to group_group_sensors_path(@group), notice: 'Sensor was successfully created.' }
        format.json { head :no_content }
      else
        format.html { render action: "new" }
        format.json { render json: @sensor.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @group = Group.where( id: params[:group_id] ).first
    @sensor = @group.sensors.where( id: params[:id] ).first

    respond_to do |format|
      if @sensor.update_attributes(params[:sensor])
        format.html { redirect_to group_group_sensors_path(@group), notice: 'Sensor was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @sensor.errors, status: :unprocessable_entity }
      end
    end
  end
end
