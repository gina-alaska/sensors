class StatusController < ApplicationController
  def poll
    @status = Statu.latest(12)

    respond_to do |format|
        format.html { render :partial => "system_status", :locals => {:status => @status}, :layout => false }
    end
  end

  def group_poll
    @group = Group.where( id: params[:group_id] ).first
    @status = @group.current_messages

    respond_to do |format|
        format.html { render :partial => "system_status", :locals => {:status => @status}, :layout => false }
    end
  end
  
end
