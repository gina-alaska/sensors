class GraphsController < ApplicationController
  def show
    @platform = Platform.where( slug: params[:platform_id] ).first
    @graph = Graph.find(params[:id])

    respond_to do |format|
      format.jpg do
        if @graph.thumb_path.nil?
          send_file(Rails.root.join("app/assets/images/view.jpg"), :disposition => "inline")
        else
          send_file(@graph.thumb_path, :disposition => "inline")
        end
      end
    end
  end

  def edit
    @platform = Platform.where( slug: params[:platform_id] ).first
    @graph = Graph.find(params[:id])
    session["platformTabShow"] = '#graphs'
  end

  def update
    @platform = Platform.where( slug: params[:platform_id] ).first
    @graph = Graph.find(params[:id])
    @graph.update_attributes(params[:graph])
    session["platformTabShow"] = '#graphs'

    respond_to do |format|
      if @graph.save
        @graph.async_graph_image_process # Queue the graph processing
        format.html { redirect_to @platform, notice: 'Graph was successfully updated.' }
        format.json { render json: @graph, status: :created, location: @graph }
      else
        format.html { render action: "edit" }
        format.json { render json: @graph.errors, status: :unprocessable_entity }
      end
    end
  end

  def new
    @platform = Platform.where( slug: params[:platform_id] ).first
    @graph = Graph.new
    session["platformTabShow"] = '#graphs'

    respond_to do |format|
      format.html
      format.json { render json: @graph }
    end
  end

  def create
    @platform = Platform.where( slug: params[:platform_id] ).first
    @graph = @platform.graphs.build(params[:graph])
    session["platformTabShow"] = '#graphs'

    respond_to do |format|
      if @graph.save
#        @graph.async_process_event # Queue the processing event
        format.html { redirect_to @platform, notice: 'Graph was successfully created.' }
        format.json { render json: @graph, status: :created, location: @graph }
      else
        format.html { render action: "new" }
        format.json { render json: @graph.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @platform = Platform.where( slug: params[:platform_id] ).first
    @graph = Graph.find(params[:id])
    @graph.destroy
    session["platformTabShow"] = '#graphs'

    respond_to do |format|
      format.html { redirect_to @platform }
      format.json { head :no_content }
    end
  end
end