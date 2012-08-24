
class DashboardController < ApplicationController
  def index
    @status = Statu.latest(12)

  	@failures = Resque::Failure.all(0, Resque::Failure.count)
  	if @failures.is_a? Hash
  		@failures = [@failures]
  	end
  end
end
