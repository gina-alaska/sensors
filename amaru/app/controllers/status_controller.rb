class StatusController < ApplicationController
  def poll
    @group = Group.where( id: params[:group_id] ).first
    @status = Statu.latest

    respond_to do |format|
        format.html { render :partial => "system_status", :locals => {:status => @status}, :template => false }
    end
  end

  def group_poll
    @group = Group.where( id: params[:group_id] ).first
    @status = @group.current_messages

    respond_to do |format|
        format.html { render :partial => "system_status", :locals => {:status => @status}, :template => false }
    end
  end
  
end
