class Admin::BulkNoticesController < Admin::ApplicationController

  # A little class to let us use form_for in the template.
  # TODO Could do this in the main menu to simplify much code
  class Request
    attr_accessor :message_body_id, :local_contest_id

    def initialize(params = {})
      params.each { |k,v| instance_variable_set("@#{k}", v) unless v.nil? }
    end
  end

  def edit
    @request = Request.new
  end

  def update
    @request = Request.new(params[:request])
    if @request.message_body_id.blank?
      flash.now[:alert] = 'No document was selected.'
    else
      msg = HtmlDocument.find(@request.message_body_id.to_i)
      if !params[:to_local_contest].blank?
        if @request.local_contest_id.blank?
          flash.now[:alert] = 'No local contest was selected.'
        else
          send_to(LocalContest.find(@request.local_contest_id.to_i).teams, msg)
        end
      elsif !params[:to_semi_finalists].blank?
        send_to(Team.where(:status => '2'), msg)
      elsif !params[to_all]
        send_to(Team.all, msg)
      end
    end
    render :action => :edit
  end

  private

  def send_to(teams, msg)
    n = 0
    teams.find_each do |team|
      BulkNotice.delay.to_team(team, msg)
      n += 1
    end
    flash.now[:alert] = "Sent #{pluralize(n, 'email message')}."
  end

end
