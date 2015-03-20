class Admin::BulkNoticesController < Admin::ApplicationController

  # A little class to let us load the params hash.
  # TODO Could do this in the main menu to simplify much code
  class Request
    attr_accessor :message_body_id, :local_contest_id, :test_email, :reminder_email

    def initialize(params = {})
      params.each { |k,v| instance_variable_set("@#{k}", v) unless v.nil? }
    end
  end

  def edit
    @request = Request.new
  end

  def update
    @request = Request.new(params[:request])
    if params.nonblank? :clear_reminder_requests
      ReminderRequest.destroy_all
      flash.now[:alert] = 'All reminder requests have been deleted.'
    elsif params.nonblank? :add_reminder
      reminder_request = ReminderRequest.new(:email => @request.reminder_email,
                                             :tag => 'Administrator')
      reminder_request.referer = request.referer || '[none]'
      if reminder_request.save
        flash.now[:alert] = "Added '#{@request.reminder_email}' to reminder requests."
      else
        flash.now[:alert] = "Save failed. Something wrong with address '#{@request.reminder_email}'."
      end
    else
      if @request.message_body_id.blank?
        flash.now[:alert] = 'No document was selected.'
      else
        msg = HtmlDocument.find(@request.message_body_id)
        if params.nonblank? :to_test_email
          if @request.test_email =~ Team::VALID_EMAIL_ADDRESS
            team = Team.new(:name => 'Test Team', :email => @request.test_email)
            team.members << Member.new(:first_name => 'Jane')
            # Delayed job does not work with this skeleton team.
            BulkNotice.to_team(team, msg).deliver
            flash.now[:alert] = "Test email was sent to #{team.email}."
          else
            flash.now[:alert] = 'Test email address is invalid.'
          end
        elsif params.nonblank? :to_reminder_requestors
          send_to_reminder_requestors(msg)
        elsif params.nonblank? :to_local_contest
          if @request.local_contest_id.blank?
            flash.now[:alert] = 'No local contest was selected.'
          else
            send_to(LocalContest.find(@request.local_contest_id.to_i).teams, msg)
          end
        elsif params.nonblank? :to_semi_finalists
          send_to(Team.where(:status => '2'), msg)
        elsif params.nonblank? :to_all
          send_to(Team, msg)
        end
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

  def send_to_reminder_requestors(msg)
    n = 0
    ReminderRequest.find_each do |request|
      BulkNotice.delay.to_any_address(request.email, msg)
      n += 1
    end
    flash.now[:alert] = "Sent #{pluralize(n, 'email message')}."
  end
end

