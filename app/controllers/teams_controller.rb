class TeamsController < ApplicationController

  def index
  end

  def new
    @team = Team.new
    @team.captain = Member.new
  end

  def create
    @team = Team.new(params[:team])
    captain = Member.new(params[:team][:member])
    captain_ok = captain.save
    @team.captain = captain
    team_ok = @team.save
    if captain_ok && team_ok
      session[:id] = @team._id
      redirect_to :controller => :members, :action => :new
    else
      @team.errors.merge! captain.errors
      captain.delete
      @team.delete
      render 'new'
    end
  end

  def edit
    logger.debug "Team edit '#{params[:id]}' and '#{session[:id]}'"
    @team = Team.find(params[:id])
    render 'new'
  end

  def update
    @team = Team.new(params[:team])
    @team.set_name_key

  end

  def destroy
  end

end
