class PlatformsController < ApplicationController
  # GET /platforms
  # GET /platforms.json
  def index
    @platforms = Platform.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @platforms }
    end
  end

  # GET /platforms/1
  # GET /platforms/1.json
  def show
    @platform = Platform.where( slug: params[:id] ).first
    @sensors = @platform.sensors.page params[:page]
    @sensors_all = @platform.sensors
    @events = @platform.events.page params[:event_page]
    @events_all = @platform.events
    @failures = Resque::Failure.all(0, Resque::Failure.count)
    if @failures.is_a? Hash
      @failures = [@failures]
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @platform }
    end
  end

  # GET /platforms/new
  # GET /platforms/new.json
  def new
    @platform = Platform.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @platform }
    end
  end

  # GET /platforms/1/edit
  def edit
    @platform = Platform.where( slug: params[:id] ).first
  end

  # POST /platforms
  # POST /platforms.json
  def create
    @platform = Platform.new(params[:platform])

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

    respond_to do |format|
      format.html { render :partial => "highchart", :locals => {:raw_data => @raw_data, :proc_data => @proc_data, :raw_sensor => params["raw_sensor"], :proc_sensor => params["proc_sensor"], :nodata => @platform.no_data_value} }
    end
  end
end
