
class DashboardController < ApplicationController
  def index
  	@failures = Resque::Failure.all(0, Resque::Failure.count)
  	if @failures.is_a? Hash
  		@failures = [@failures]
  	end
  end
end
