class GroupsController < ApplicationController

  def index
    @groups = Group.all
  end

  def platforms
    @group = Group.where(id: params[:id]).first
    @platforms = @group.platforms
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

  def show
    @group = Group.where( id: params[:id] ).first
    @platform = @group.platforms.page params[:platform_page]
    @sensors = @group.sensors.page params[:sensors_page]
    @sensors_all = @group.all_raw_sensors
    @events = @group.events.asc(:name).page params[:event_page]
    @events_all = @group.events
    @graphs = @group.graphs
    @alerts = @group.alerts

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
end
