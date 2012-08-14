class SessionsController < ApplicationController
 
  def new
    @ip = request.remote_ip
  end

end
