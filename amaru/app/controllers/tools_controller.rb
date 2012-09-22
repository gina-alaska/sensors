class ToolsController < ApplicationController
  def index
    sensors = []
    current_user.current_org.platforms.all.each do |platform|
      sensors << platform.sensors.collect(&:source_field)
    end
    @all_sensors = sensors.flatten.uniq
    @all_groups = current_user.current_org.groups.asc(:name).collect(&:name)

    respond_to do |format|
      format.html
    end
  end

  def by_sensor
    session["toolsTabShow"] = '#sensors'

    @success = false
    unless params["sensors"].nil?
      group = params["group"]
      @group = current_user.current_org.groups.where(name: group).first || current_user.current_org.groups.build unless group.nil?
      @group.update_attributes!( name: group ) if @group.new_record?

      params["sensors"].each do |sensor|
        platforms = current_user.current_org.platforms.where("sensors.source_field" => sensor)
        @group.platforms << platforms
      end
      @success = true
    end

    respond_to do |format|
      if @success
        flash[:notice] = "Platforms with selected sensors were successfully grouped."
        format.js
        format.html { redirect_to tools_path }
      else
        flash.now[:error] = "Please select one or more sensors to group!"
        format.js
        format.html { render 'index' }
      end
    end
  end

  def mass_platform_set
    session["toolsTabShow"] = '#mass-platforms'

    @success = false
    unless params["platforms"].nil?
      params["platforms"].each do |platform|
        platform_obj = Platform.where(name: platform).first
        platform_obj.platform_metadata = params["platform_metadata"] unless params["platform_metadata"].empty?
        platform_obj.license = params["license"] unless params["license"].empty?
        platform_obj.permissions = params["permissions"] unless params["permissions"].empty?
        platform_obj.agency = params["agency"] unless params["agency"].empty?
        platform_obj.authority = params["authority"] unless params["authority"].empty?
        platform_obj.no_data_value = params["no_data_value"] unless params["no_data_value"].empty?
        platform_obj.time_zone = params["time_zone"] unless params["time_zone"].empty?
        platform_obj.save!
      end
      @success = true
    end

    respond_to do |format|
      if @success
        flash[:notice] = "Platforms were successfully mass updated."
        format.js
        format.html { redirect_to tools_path }
      else
        flash.now[:error] = "Please select one or more platforms!"
        format.js
        format.html { render 'index' }
      end
    end
  end
end
