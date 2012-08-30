class ToolsController < ApplicationController
  def index
    sensors = []
    Platform.all.each do |platform|
      sensors << platform.sensors.collect(&:source_field)
    end
    @all_sensors = sensors.flatten.uniq
    @all_groups = Group.asc(:name).collect(&:name)

    respond_to do |format|
      format.html
    end
  end

  def by_sensor
    group = params["group"]
    @group = Group.where(name: group).first || Group.new unless group.nil?
    @group.update_attributes!( name: group ) if @group.new_record?

    params["sensors"].each do |sensor|
      platforms = Platform.where("sensors.source_field" => sensor)
      @group.platforms << platforms
    end

    respond_to do |format|
      format.html { redirect_to tools_path, notice: "Platforms were successfully grouped into group <i>#{group}</i>." }
      format.json { head :no_content }
    end
  end
end
