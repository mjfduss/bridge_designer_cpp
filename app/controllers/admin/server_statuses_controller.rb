class Admin::ServerStatusesController < Admin::ApplicationController
  def edit
    @time = Time.now.strftime("%H:%M Eastern on %d-%m-%Y")
    @ip = request.remote_ip
  end

  def update
  end
end
