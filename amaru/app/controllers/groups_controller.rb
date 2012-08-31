class GroupsController < ApplicationController

  def index
    @groups = Group.all
  end

  def platforms
    @group = Group.where(id: params[:id]).first
    @platforms = @group.platforms.asc(:slug).page(params[:page]).per(6)
    pf_list = Platform.asc(:name).only(:name, :slug).collect do |p|
      [p.name, p.slug]
    end
    gr_list = @group.platforms.only(:name, :slug).collect do |p|
      [p.name, p.slug]
    end
    @platform_list = pf_list - gr_list

    respond_to do |format|
      format.html { render layout: "group_layout" }
      format.json { render json: @platforms }
    end
  end

  def data_view
    @group = Group.where(id: params[:id]).first
    @sensors_all = @group.all_raw_sensors
    @events_all = @group.sensors.asc(:source_field)
    @platforms = @group.platforms.asc(:name)

    respond_to do |format|
      format.html { render layout: "group_layout" }
      format.json { render json: @platforms }
    end
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
    session[:return_to] = platforms_group_path(@group) if params[:single] == "true"
    session[:return_to] = groups_path if params[:single] == "false"
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

logger.info session[:return_to]
    respond_to do |format|
      if @group.update_attributes(params[:group])
        format.html { redirect_to session.delete(:return_to), notice: 'Group was successfully updated.' }
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
      format.html { redirect_to groups_path }
      format.json { head :no_content }
    end
  end

  def add_platform
    @group = Group.where( id: params[:id] ).first
    @platform = Platform.where( slug: params[:slug]).first
    @group.platforms << @platform

    respond_to do |format|
      format.html { redirect_to platforms_group_path(@group) }
      format.json { head :no_content }
    end
  end

  def remove_platform
    @group = Group.where( id: params[:id] ).first
    @platform = @group.platforms.find(params[:platform_id])
    @group.platforms.delete( @platform )

    respond_to do |format|
      format.html { redirect_to platforms_group_path(@group) }
      format.json { head :no_content }
    end
  end

  def graph_update
    starts_at = params["starts_at"] == "" ? nil : params["starts_at"]
    ends_at = params["ends_at"] == "" ? nil : params["ends_at"]
    @group = Group.where( id: params[:id] ).first
#    @platform = Platform.where( slug: params[:id] ).first
    @platform = @group.platforms.where(slug: params["platforms"]).first
    @raw_data = @platform.raw_data.captured_between(starts_at, ends_at).asc(:capture_date)
    @proc_data = @platform.processed_data.captured_between(starts_at, ends_at).asc(:capture_date)
    session["graphParams"] = params

    respond_to do |format|
      format.html { render :partial => "highchart", :locals => {:raw_data => @raw_data, :raw_sensor => params["raw_sensor"], :proc_data => @proc_data, :nodata => @platform.no_data_value, :proc_sensor => params["proc_sensor"]} }
    end
  end
end
