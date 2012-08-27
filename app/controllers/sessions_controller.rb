class SessionsController < ApplicationController
 
  def new
    session.clear
  end

end
