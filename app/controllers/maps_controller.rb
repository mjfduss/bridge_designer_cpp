class MapsController < ApplicationController

  skip_before_filter :require_valid_session, :check_schedule

  def show
    send_data Map.members_from_cache(params[:id], params[:refresh]), :type => 'image/png', :disposition => 'inline'
  end

end
