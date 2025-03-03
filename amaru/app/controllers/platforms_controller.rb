class PlatformsController < ApplicationController
  before_filter :require_current_org

  def index
    @platforms = current_user.current_org.platforms.asc(:name).page params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @platforms }
    end
  end

  def show
    @platform = Platform.where( slug: params[:id] ).first
    @sensors = @platform.sensors.page params[:page]
    @sensors_all = @platform.sensors.collect(&:source_field)
    @group_sensors = @platform.all_group_sensors
    @groups = @platform.groups.collect(&:name)
    
    if session["graphParams"].nil?
      session["graphParams"] = {}
      session["graphParams"]["platforms"] = nil
      session["graphParams"]["raw_sensor"] = nil
      session["graphParams"]["proc_sensor"] = nil
      session["graphParams"]["starts_at"] = nil
      session["graphParams"]["ends_at"] = nil
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @platform }
    end
  end

  def new
    @platform = Platform.new
    session["dashboardTabShow"] = '#platforms'

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @platform }
    end
  end

  def edit
    @platform = Platform.where( slug: params[:id] ).first
    case params[:group_id]
    when "false"
      session[:return_to] = platforms_path
    when "show"
      session[:return_to] = platform_path(@platform)
    else
      @group = Group.where( id: params[:group_id]).first
      session[:return_to] = platforms_group_path(@group)
    end
  end

  def create
    @platform = current_user.current_org.platforms.build(params[:platform])
    session["dashboardTabShow"] = '#platforms'

    respond_to do |format|
      if @platform.save
        format.html { redirect_to platforms_path, notice: 'Platform was successfully created.' }
        format.json { render json: platforms_path, status: :created, location: @platform }
      else
        format.html { render action: "new" }
        format.json { render json: @platform.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @platform = Platform.where( slug: params[:id] ).first

    respond_to do |format|
      if @platform.update_attributes(params[:platform])
        format.html { redirect_to session[:return_to], notice: 'Platform was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @platform.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @platform = Platform.where(slug: params[:id])
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
    session["platformTabShow"] = '#dataview'
    session["graphParams"] = params
    Time.zone = @platform.time_zone

    respond_to do |format|
      format.html { render :partial => "highchart", :locals => {:raw_data => @raw_data, :raw_sensor => params["raw_sensor"], :nodata => @platform.no_data_value} }
    end
  end

  def upload
    platform = Platform.where( slug: params[:id] ).first
    upload_file = params[:ingest]
    import_object = RestImport.new(platform.slug, platform.group.token, upload_file)

    respond_to do |format|
      if import_object.import
        format.html { redirect_to platforms_path, notice: 'Data uploaded' }
      end
    end
  end
end
