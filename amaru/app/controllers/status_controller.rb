class StatusController < ApplicationController
  def poll
    @platform = Platform.where( slug: params[:id] ).first
    @status = @platform.status.all.desc(:start_time)

    respond_to do |format|
        format.html { render :partial => "system_status", :locals => {:status => @status}, :template => false }
    end
  end
end
