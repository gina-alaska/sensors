class GraphsController < ApplicationController

  def index
    @group = Group.where(id: params[:group_id]).first
    @graphs = @group.graphs.all

    respond_to do |format|
      format.html { render layout: "group_layout" }
      format.json { render json: @events }
    end
  end

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
    @group = Group.where(id: params[:group_id]).first
    @graph = @group.graphs.find(params[:id])
  end

  def update
    @group = Group.where(id: params[:group_id]).first
    @graph = @group.graphs.find(params[:id])
    @graph.update_attributes(params[:graph])

    respond_to do |format|
      if @graph.save
        @graph.async_graph_image_process unless @graph.disabled # Queue the graph processing
        format.html { redirect_to group_graphs_path(@group), notice: 'Graph was successfully updated.' }
        format.json { render json: @graph, status: :created, location: @graph }
      else
        format.html { render action: "edit" }
        format.json { render json: @graph.errors, status: :unprocessable_entity }
      end
    end
  end

  def new
    @group = Group.where(id: params[:group_id]).first
    @graph = Graph.new

    respond_to do |format|
      format.html
      format.json { render json: @graph }
    end
  end

  def create
    @group = Group.where(id: params[:group_id]).first
    @graph = @group.graphs.build(params[:graph])
    @graph.last_run = Time.zone.now

    respond_to do |format|
      if @graph.save
        @graph.async_graph_image_process unless @graph.disabled # Queue the processing event
        format.html { redirect_to group_graphs_path(@group), notice: 'Graph was successfully created.' }
        format.json { render json: @graph, status: :created, location: @graph }
      else
        format.html { render action: "new" }
        format.json { render json: @graph.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @group = Group.where(id: params[:group_id]).first
    @graph = @group.graphs.find(params[:id])
    @graph.destroy

    respond_to do |format|
      format.html { redirect_to group_graphs_path(@group) }
      format.json { head :no_content }
    end
  end

  def image
    @group = Group.where(id: params[:group_id]).first
    @graph = @group.graphs.find(params[:id])
    send_file @graph.image_path, :disposition => "inline"
  end

  def thumb
    @group = Group.where(id: params[:group_id]).first
    @graph = @group.graphs.find(params[:id])
    send_file @graph.thumb_path, :disposition => "inline"
  end

  def build
    @group = Group.where(id: params[:group_id]).first
    @graph = @group.graphs.find(params[:id])
    @graph.async_graph_image_process unless @graph.disabled # Queue the graph processing

    respond_to do |format|
      if @graph.disabled
        format.html { redirect_to group_graphs_path(@group), notice: 'Graph is disabled, not re-built.' }
      else
        format.html { redirect_to group_graphs_path(@group), notice: 'Graph was successfully re-built.' }
      end
      format.json { render json: @graph, status: :created, location: @graph }
    end
  end
end