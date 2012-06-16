
class EventsController < ApplicationController
  # GET /events
  # GET /events.json
  def index
    @events = Event.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @event = Event.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/new
  # GET /events/new.json
  def new
    @platform = Platform.where( slug: params[:platform_id] ).first
    @sensors = @platform.sensors.only(:source_field).all
    @event = Event.new
    session["platformTabShow"] = '#processing'

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/1/edit
  def edit
    @platform = Platform.where( slug: params[:platform_id] ).first
    @sensors = @platform.sensors.only(:source_field).all
    @event = Event.find(params[:id])
    session["platformTabShow"] = '#processing'
  end

  # POST /events
  # POST /events.json
  def create
    @platform = Platform.where( slug: params[:platform_id] ).first
    @event = @platform.events.build(params[:event])
    session["platformTabShow"] = '#processing'

    respond_to do |format|
      if @event.save
        @event.async_process_event # Queue the processing event
        format.html { redirect_to edit_platform_event_path(@platform, @event), notice: 'Event was successfully created.' }
        format.json { render json: @event, status: :created, location: @event }
      else
        format.html { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @platform = Platform.where( slug: params[:platform_id] ).first
    @event = Event.find(params[:id])
    session["platformTabShow"] = '#processing'
    @event.attributes = event_params

    respond_to do |format|
      if @event.save
        @event.async_process_event # Queue the processing event
        format.html { redirect_to @platform, notice: 'Event was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @platform = Platform.where( slug: params[:platform_id] ).first
    @event = Event.find(params[:id])
    @event.destroy
    session["platformTabShow"] = '#processing'

    respond_to do |format|
      format.html { redirect_to @platform }
      format.json { head :no_content }
    end
  end

  def add
    @platform = Platform.where( slug: params[:platform_id] ).first
    @event = Event.find(params[:id])
    @command = @event.commands.create(command: "copy", index: @event.commands.count)

    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "command", :locals => {:command => @command}
        else
          redirect_to edit_platform_event_path(@platform, @event)
        end        
      }
    end
  end

  def change
    @platform = Platform.where( slug: params[:platform_id] ).first
    @event = Event.find(params[:id])
    @command = @event.commands.find(params[:command_id])
    @command.command = params["command"]

    render :partial => params["command"], :locals => {:command => @command}
  end

  def remove
    @platform = Platform.where( slug: params[:platform_id] ).first
    @event = Event.find(params[:id])
    @command = @event.commands.find(params[:command_id])
    @command.destroy
#    render :text => "Removed"
    render :partial => "remove", :locals => {:command_id => params[:command_id]}
  end

  protected

  def event_params
    e = params[:event]
    e[:commands] = params[:commands]
    return e
  end
end
