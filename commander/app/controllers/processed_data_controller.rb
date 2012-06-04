
class ProcessedDataController < ApplicationController
  # GET /processed_data
  # GET /processed_data.json
  def index
    @processed_data = ProcessedDatum.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @processed_data }
    end
  end

  # GET /processed_data/1
  # GET /processed_data/1.json
  def show
    @processed_datum = ProcessedDatum.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @processed_datum }
    end
  end

  # GET /processed_data/new
  # GET /processed_data/new.json
  def new
    @processed_datum = ProcessedDatum.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @processed_datum }
    end
  end

  # GET /processed_data/1/edit
  def edit
    @processed_datum = ProcessedDatum.find(params[:id])
  end

  # POST /processed_data
  # POST /processed_data.json
  def create
    @processed_datum = ProcessedDatum.new(params[:processed_datum])

    respond_to do |format|
      if @processed_datum.save
        format.html { redirect_to @processed_datum, notice: 'Processed datum was successfully created.' }
        format.json { render json: @processed_datum, status: :created, location: @processed_datum }
      else
        format.html { render action: "new" }
        format.json { render json: @processed_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /processed_data/1
  # PUT /processed_data/1.json
  def update
    @processed_datum = ProcessedDatum.find(params[:id])

    respond_to do |format|
      if @processed_datum.update_attributes(params[:processed_datum])
        format.html { redirect_to @processed_datum, notice: 'Processed datum was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @processed_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /processed_data/1
  # DELETE /processed_data/1.json
  def destroy
    @processed_datum = ProcessedDatum.find(params[:id])
    @processed_datum.destroy

    respond_to do |format|
      format.html { redirect_to processed_data_url }
      format.json { head :no_content }
    end
  end
end
