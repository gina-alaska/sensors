class GroupsController < ApplicationController
  def index
    @group = Group.all
  end

  def show
    @group = Group.where( id: params[:id] ).first
    @platform = @group.platforms.page params[:platform_page]
    @sensors = @group.sensors.page params[:sensors_page]
    @sensors_all = @group.all_raw_sensors
    @events = @group.events.asc(:name).page params[:event_page]
    @events_all = @group.events
    @graphs = @group.graphs
    @alerts = @group.alerts
    @status = @group.status.latest

#    if session["graphParams"].nil?
#      value, units = @platform.graph_length.split(".")
#      length = value.to_i.send(units.to_sym)
#      session["graphParams"] = {"starts_at" => length, "ends_at" => nil, #"raw_sensor" => @sensors_all.first.source_field, "proc_sensor" => nil}
#    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @group }
    end
  end

  def new
    @group = Group.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @group }
    end
  end

  def edit
    @group = Group.where( id: params[:id] ).first
  end

  def create
    @group = Group.new(params[:group])

    respond_to do |format|
      if @group.save
        format.html { redirect_to dashboard_path, notice: 'Group was successfully created.' }
        format.json { render json: @group, status: :created, location: @group }
      else
        format.html { render action: "new" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @group = Group.where( id: params[:id] ).first

    respond_to do |format|
      if @group.update_attributes(params[:group])
        format.html { redirect_to dashboard_path, notice: 'Group was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      format.html { redirect_to dashboard_path }
      format.json { head :no_content }
    end
  end
end
