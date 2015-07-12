class Admin::BulkNoticesController < Admin::ApplicationController

  # A little class to let us load the params hash.
  # TODO Could do this in the main menu to simplify much code
  class Request
    attr_accessor :message_body_id, :local_contest_id, :test_email, :reminder_email

    def initialize(params = {})
      params.each { |k,v| instance_variable_set("@#{k}", v) unless v.nil? }
    end
  end

  # Fake classes work around Delayed job's requirement that ActiveRecord
  # args to delayed methods be saved.
  class FakeMember
    attr_accessor :first_name
    def initialize(first_name)
      self.first_name = first_name
    end
  end

  class FakeTeam
    attr_accessor :name, :email, :members
    def initialize(name, email, *members)
      self.name = name
      self.email = email
      self.members = members
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
            team = FakeTeam.new('Test Team', @request.test_email, FakeMember.new('Jane'))
            BulkNotice.delay.to_team(team, msg)
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
        end
      end
    end
    render :action => :edit
  end

  private

  def send_to(teams, msg)
    n = 0
    teams.find_each do |team|
      # BulkNotice.delay.to_team(team, msg)
      logger.debug("Sending to #{team.name}")
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
