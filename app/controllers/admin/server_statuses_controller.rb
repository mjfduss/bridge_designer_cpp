require 'rake'

class Admin::ServerStatusesController < Admin::ApplicationController

  VERIFICATION = 'irreversible'

  def edit
    @ip = request.remote_ip
  end

  def update
    ok = true;
    unless params[:verification].downcase.strip == VERIFICATION
      flash[:alert_verification] = "Verification is not correct. Type '#{VERIFICATION}' in the space provided."
      ok = false
    end
    admin = Administrator.find(session[:admin_id])
    unless admin && admin.authenticate(params[:password])
      flash[:alert_password] = 'Password is incorrect.  Please enter your administrator password.'
      ok = false
    end
    if ok
      flash[:alert] = 'Database would have been cleared if this feature were enabled.'
      logger.fatal "Database was cleared by admin #{admin.name}."
    else
      flash[:alert] = 'Database was not cleared.'
      logger.fatal "Database clear failed for admin #{admin.name}."
    end
    render 'edit'
  end

  def self.reset_all
    # Clear the unofficial standings database.
    REDIS::flushall

    # Clear relevant SQL tables.
    # Skipped:
    #   Administrator    accounts are still needed
    #   CkeditorAssets   pictures for rich HTML documents
    #   CkeditorContents rich HTML documents
    #   DelayedJobs      might confuse DJ
    #   Groups           could be handy for reuse
    #   HtmlDocuments    rich HTML document headers
    #   LocalContests    obviously still useful!
    #   ReminderRequests deleted elsewhere
    #   Schedule         obviously still useful
    #   Scoreboards      historical record is important
    #   SequenceNumber   just reset, don't clear

    Affiliation.delete_all
    Best.delete_all
    Design.delete_all
    Member.delete_all
    Parent.delete_all
    PasswordReset.delete_all
    SequenceNumber.reset :design
    Team.delete_all
    LocalScoreboard.delete_all

    # Reset the affiliation counter caches in each of the local contests.
    LocalContest.pluck(:id).each { |id| LocalContest.reset_counters(id, :affiliations) }
  end
end

