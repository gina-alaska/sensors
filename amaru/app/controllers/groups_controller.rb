class GroupsController < ApplicationController
  def show
    @group = Group.where( id: params[:id] ).first
#    @platform = Platform.where( slug: params[:id] ).first
#    @sensors = @platform.sensors.page params[:page]
#    @sensors_all = @platform.sensors
#    @events = @platform.events.asc(:name).page params[:event_page]
#    @events_all = @platform.events
#    @graphs = @platform.graphs
#    @alerts = @platform.alerts
#    @status = @platform.status

#    if session["graphParams"].nil?
#      value, units = @platform.graph_length.split(".")
#      length = value.to_i.send(units.to_sym)
#      session["graphParams"] = {"starts_at" => length, "ends_at" => nil, #"raw_sensor" => @sensors_all.first.source_field, "proc_sensor" => nil}
#    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @platform }
    end
  end

  def new
    @group = Group.new
    session["dashboardTabShow"] = '#groups'

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @platform }
    end
  end

  def edit
    @group = Group.where( id: params[:id] ).first
    session["dashboardTabShow"] = '#groups'
  end

  def create
    @group = Group.new(params[:group])
    session["dashboardTabShow"] = '#groups'

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
    session["dashboardTabShow"] = '#groups'

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
    session["dashboardTabShow"] = '#groups'

    respond_to do |format|
      format.html { redirect_to dashboard_path }
      format.json { head :no_content }
    end
  end
end
