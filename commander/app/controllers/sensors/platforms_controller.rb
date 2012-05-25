class Sensors::PlatformsController < ApplicationController
  # GET /sensors/platforms
  # GET /sensors/platforms.json
  def index
    @sensors_platforms = Sensors::Platform.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sensors_platforms }
    end
  end

  # GET /sensors/platforms/1
  # GET /sensors/platforms/1.json
  def show
    @sensors_platform = Sensors::Platform.where(slug: params[:id]).first

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sensors_platform }
    end
  end

  # GET /sensors/platforms/new
  # GET /sensors/platforms/new.json
  def new
    @sensors_platform = Sensors::Platform.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sensors_platform }
    end
  end

  # GET /sensors/platforms/1/edit
  def edit
    @sensors_platform = Sensors::Platform.where(slug: params[:id]).first
  end

  # POST /sensors/platforms
  # POST /sensors/platforms.json
  def create
    @sensors_platform = Sensors::Platform.new(params[:sensors_platform])

    respond_to do |format|
      if @sensors_platform.save
        format.html { redirect_to @sensors_platform, notice: 'Platform was successfully created.' }
        format.json { render json: @sensors_platform, status: :created, location: @sensors_platform }
      else
        format.html { render action: "new" }
        format.json { render json: @sensors_platform.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sensors/platforms/1
  # PUT /sensors/platforms/1.json
  def update
    @sensors_platform = Sensors::Platform.where(slug: params[:id]).first

    respond_to do |format|
      if @sensors_platform.update_attributes(params[:sensors_platform])
        format.html { redirect_to @sensors_platform, notice: 'Platform was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @sensors_platform.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sensors/platforms/1
  # DELETE /sensors/platforms/1.json
  def destroy
    @sensors_platform = Sensors::Platform.where(slug: params[:id]).first
    @sensors_platform.destroy

    respond_to do |format|
      format.html { redirect_to sensors_platforms_url }
      format.json { head :no_content }
    end
  end
end
