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
    begin
      Team.transaction do
        captain.save!
        @team.captain = captain
        @team.save!
      end
      redirect_to :controller => :members, :action => :new
    rescue ActiveRecord::RecordInvalid
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
