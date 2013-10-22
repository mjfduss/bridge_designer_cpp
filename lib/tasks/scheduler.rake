desc "Called by the Heroku scheduler to clean abandoned registrations."
task :clean_abandoned_registrations => :environment do
  now = Time.now
  Rails.logger.info "Cleaning abandoned registrations #{now}"
  # The time should be greater than then session expiration time.
  team_count = Team.where('(reg_completed IS NULL) AND (updated_at < ?)', 30.minutes.ago(now)).count
  Rails.logger.info "Would have cleaned #{team_count} teams."
end