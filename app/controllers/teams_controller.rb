class TeamsController < ApplicationController

  def index
  end

  def new
    @team = Team.new
    @team.captain = Member.new
  end

  def create 
    team_saved = false;
    captain = Member.new(params[:team][:member])
    if captain.save
      team = Team.new(params[:team])
      team.captain = captain
      team_saved = team.save;
    end
    if team_saved
      redirect_to :controller => :members, :action => :new;
    else
      captain.delete
      render 'new'
    end
#    begin
#      Team.transaction do
#        @team.captain.save!
#        @team.save!
#      end
#      render new_member_path
#    rescue ActiveRecord::RecordInvalid
#      render 'new'
#    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

end
