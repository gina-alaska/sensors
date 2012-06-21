class ResquesController < ApplicationController
	def retry
  	@failures = Resque::Failure
  	@failures.requeue(params[:id])

    respond_to do |format|
        format.html { redirect_to dashboard_path, notice: 'Process Event requeued.' }
    end
	end

	def destroy
  	@failures = Resque::Failure

    if params[:id].nil?
    	@failures.count.times { |i| @failures.remove(i-1) }
    	#@failures.remove_queue("events")
    else
    	@failures.remove(params[:id])
    end

    respond_to do |format|
        format.html { redirect_to dashboard_path, notice: 'Process Event removed.' }
    end
	end

  def poll
    @failures = Resque::Failure.all(0, Resque::Failure.count)
    if @failures.is_a? Hash
      @failures = [@failures]
    end

    respond_to do |format|
        format.html { render :partial => "resque_fails", :locals => {:failures => @failures}, :template => false }
    end
  end
end