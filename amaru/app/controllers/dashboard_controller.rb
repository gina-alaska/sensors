class DashboardController < ApplicationController
  skip_before_filter :require_login
  
  def index
#    if current_user
#      @current_organization = Organization.where(id: current_user.#current_org_id).first
#    end
    @status = Statu.latest(12)
    @num_groups = Group.count
    @num_platforms = Platform.count
    @num_events = Event.count
    @num_graphs = Graph.count
    @num_alerts = Alert.count

#  	@failures = Resque::Failure.all(0, Resque::Failure.count)
#  	if @failures.is_a? Hash
 # 		@failures = [@failures]
  #	end
  end
end
