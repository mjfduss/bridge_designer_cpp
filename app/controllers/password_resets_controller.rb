require 'securerandom'

class PasswordResetsController < ApplicationController

  # Disable check session because this is where we get one!
  skip_before_filter :require_valid_session

  def new
  end

  def create
    email = params[:email].strip.downcase
    teams = Team.where(['email = ? AND reg_completed IS NOT NULL', email])
    if teams.empty?
      flash.now[:alert] = "Sorry. There are no teams with email address '#{email}'."
      render 'new'
    else
      # Now make new ones.
      resets = teams.map do |team|
        reset = PasswordReset.find_or_initialize_by_team_id(team.id)
        reset.key = SecureRandom.hex(20)
        reset.save
        reset
      end
      PasswordResetNotification.delay.to_team(resets)
      flash[:alert] = "A password reset message has been sent to #{email} for #{pluralize teams.size, 'team'}."
      redirect_to :controller => :sessions, :action => :new
    end
  end
end
