
class DashboardController < ApplicationController
  def index
    @group = Group.page.all
    @platform = Platform.page.all
    @status = Statu.latest
    @events = Event.page.all

  	@failures = Resque::Failure.all(0, Resque::Failure.count)
  	if @failures.is_a? Hash
  		@failures = [@failures]
  	end
  end
end
