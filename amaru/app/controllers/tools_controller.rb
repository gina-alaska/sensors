class ToolsController < ApplicationController
  def index
    sensors = []
    current_user.current_org.platforms.all.each do |platform|
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
    @group = current_user.current_org.groups.where(name: group).first || current_user.current_org.groups.build unless group.nil?
    @group.update_attributes!( name: group ) if @group.new_record?

    params["sensors"].each do |sensor|
      platforms = current_user.current_org.platforms.where("sensors.source_field" => sensor)
      @group.platforms << platforms
    end

    respond_to do |format|
      format.html { redirect_to tools_path, notice: "Platforms were successfully grouped into group <i>#{group}</i>." }
      format.json { head :no_content }
    end
  end
end
