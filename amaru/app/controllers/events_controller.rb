
class EventsController < ApplicationController
  def index
    @group = Group.where(id: params[:group_id]).first
    @events = @group.events.all

    respond_to do |format|
      format.html { render layout: "group_layout" }
      format.json { render json: @events }
    end
  end

  def show
    @event = Event.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end

  def new
    @group = Group.where(id: params[:group_id]).first
    @sensors = @group.all_raw_sensors
    @event = Event.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  def edit
    @group = Group.where(id: params[:group_id]).first
    @sensors = @group.all_raw_sensors
    @event = Event.find(params[:id])
#    @sensors = @event.groups.sensors.only(:source_field).all
#    @sensors = @platform.sensors.only(:source_field).all
  end

  def create
    @group = Group.where(id: params[:group_id]).first
    @sensors = @group.all_raw_sensors
    @event = @group.events.build(params[:event])

    respond_to do |format|
      if @event.save
        format.html { redirect_to edit_group_event_path(@group, @event), notice: 'Process was successfully created.' }
        format.json { render json: @event, status: :created, location: @event }
      else
        format.html { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @group = Group.where(id: params[:group_id]).first
    @event = @group.events.find(params[:id])
    @event.attributes = event_params

    respond_to do |format|
      if @event.save
        format.html { redirect_to group_events_path(@group), notice: 'Process was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def run_event
    @group = Group.where(id: params[:group_id]).first
    @event = @group.events.find(params[:id])

    respond_to do |format|
      if @event.async_process_event # Queue the processing event
        format.html { redirect_to group_events_path(@group), notice: 'Sensor Process Queued.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @group = Group.where(id: params[:group_id]).first
    @event = @group.events.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to group_events_path(@group) }
      format.json { head :no_content }
    end
  end

  def add
    @group = Group.where(id: params[:group_id]).first
    @event = @group.events.find(params[:id])
    @command = @event.commands.create(command: "copy", index: @event.commands.count)

    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "command", :locals => {:group => @group, :event => @event}
        else
          redirect_to edit_group_event_path(@group, @event)
        end        
      }
    end
  end

  def change
    @group = Group.where(id: params[:group_id]).first
    @event = @group.events.find(params[:id])
    @command = @event.commands.find(params[:command_id])
    @command.command = params["command"]

    render :partial => params["command"], :locals => {:command => @command}
  end

  def remove
    @group = Group.where(id: params[:group_id]).first
    @event = @group.events.find(params[:id])
    @command = @event.commands.find(params[:command_id])
    cindex = @command.index

    # Adjust indexes and remove command from database
    fixcom = @event.commands.where(:index.gt => cindex)
    fixcom.each do |command|
      command.index = command.index-1
      command.save!
    end
    @command.destroy

    render :partial => "remove", :locals => {:command_id => params[:command_id]}
  end

  def moveup
    @group = Group.where(id: params[:group_id]).first
    @event = @group.events.find(params[:id])
    @command = @event.commands.find(params[:command_id])
    cindex = @command.index

    if cindex > 0  # Switch command indexes
      scom = @event.commands.where(index: cindex-1).first
      if scom
        scom.index = cindex
        scom.save!
        @command.index = cindex-1
        @command.save!
        @event.reload
      end
    end

    render :partial=>"command", :locals=>{:platform => @platform, :event => @event}
  end

  def movedown
    @group = Group.where(id: params[:group_id]).first
    @event = @group.events.find(params[:id])
    @command = @event.commands.find(params[:command_id])
    maxindex = @event.commands.desc(:index).first.index
    cindex = @command.index

    if cindex < maxindex  # Switch command indexes
      scom = @event.commands.where(index: cindex+1).first
      if scom
        scom.index = cindex
        scom.save!
        @command.index = cindex+1
        @command.save!
        @event.reload
      end
    end

    render :partial=>"command", :locals=>{:platform => @platform, :event => @event}
  end

  protected

  def event_params
    e = params[:event]
    e[:commands] = params[:commands]
    e[:from].reject! { |i| i == '' } if e[:from].count > 1
    return e
  end
end
