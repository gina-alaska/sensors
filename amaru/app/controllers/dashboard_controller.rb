
class DashboardController < ApplicationController
  def index
    @group = Group.all
  	@failures = Resque::Failure.all(0, Resque::Failure.count)
  	if @failures.is_a? Hash
  		@failures = [@failures]
  	end
  end
end
