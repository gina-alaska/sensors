class PlatformsController < ApplicationController
  layout "group_layout"

  def index
    @group = Group.where(id: params[:group_id]).first
    @platforms = @group.platforms
    @status = @group.status.latest

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @platforms }
    end
  end

  def show
    @group = Group.where(id: params[:group_id]).first
    @platform = Platform.where( slug: params[:id] ).first
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

  # GET /platforms/new
  # GET /platforms/new.json
  def new
    @platform = Platform.new
    session["dashboardTabShow"] = '#platforms'

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @platform }
    end
  end

  # GET /platforms/1/edit
  def edit
    @platform = Platform.where( slug: params[:id] ).first
    session["dashboardTabShow"] = '#platforms'
  end

  # POST /platforms
  # POST /platforms.json
  def create
    @platform = Platform.new(params[:platform])
    session["dashboardTabShow"] = '#platforms'

    respond_to do |format|
      if @platform.save
        format.html { redirect_to @platform, notice: 'Platform was successfully created.' }
        format.json { render json: @platform, status: :created, location: @platform }
      else
        format.html { render action: "new" }
        format.json { render json: @platform.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /platforms/1
  # PUT /platforms/1.json
  def update
    @platform = Platform.where( slug: params[:id] ).first
    session["dashboardTabShow"] = '#platforms'

    respond_to do |format|
      if @platform.update_attributes(params[:platform])
        format.html { redirect_to @platform, notice: 'Platform was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @platform.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /platforms/1
  # DELETE /platforms/1.json
  def destroy
    @platform = Platform.find(params[:id])
    @platform.destroy
    session["dashboardTabShow"] = '#platforms'

    respond_to do |format|
      format.html { redirect_to platforms_url }
      format.json { head :no_content }
    end
  end

  def graph_update
    starts_at = params["starts_at"] == "" ? nil : params["starts_at"]
    ends_at = params["ends_at"] == "" ? nil : params["ends_at"]
    @platform = Platform.where( slug: params[:id] ).first
    @raw_data = @platform.raw_data.captured_between(starts_at, ends_at).asc(:capture_date)
    @proc_data = @platform.processed_data.captured_between(starts_at, ends_at).asc(:capture_date)
    session["platformTabShow"] = '#dataview'
    session["graphParams"] = params

    respond_to do |format|
      format.html { render :partial => "highchart", :locals => {:raw_data => @raw_data, :proc_data => @proc_data, :raw_sensor => params["raw_sensor"], :proc_sensor => params["proc_sensor"], :nodata => @platform.no_data_value} }
    end
  end
end
