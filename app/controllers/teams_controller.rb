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
      redirect_to :controller => :members, :action => :new
    else
      captain.delete
      @team.delete
      render 'new'
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

end
