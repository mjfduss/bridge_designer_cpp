class ReminderRequestsController < ApplicationController

  skip_before_filter :require_valid_session, :check_schedule

  layout 'reminder_request'

  def new
    @reminder_request = ReminderRequest.new
    @reminder_request.tag = params[:tag] || '[none]'
  end

  def create
    # Note we're not checking the schedule here on the theory that if
    # someone really wants to give us an email address, we'll take it.
    @reminder_request = ReminderRequest.new(params[:reminder_request])
    @reminder_request.referer = request.referer || '[none]'
    @reminder_request.save
  end
end
