class DashboardController < ApplicationController
  skip_before_filter :require_login
  
  def index
    @status = Statu.latest(12)
    @num_groups = Group.count
    @num_platforms = Platform.count
    @num_events = Event.count
    @num_graphs = Graph.count
    @num_alerts = Alert.count

  	@failures = Resque::Failure.all(0, Resque::Failure.count)
  	if @failures.is_a? Hash
  		@failures = [@failures]
  	end
  end
end
