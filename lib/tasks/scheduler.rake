desc 'Called by the Heroku scheduler to clean abandoned registrations.'
task :clean_abandoned_registrations => :environment do
  now = Time.now
  # The time should be greater than then session expiration time.
  destroyed = Team.where('(reg_completed IS NULL) AND (updated_at < ?)', 30.minutes.ago(now)).destroy_all
  Rails.logger.info "Cleaned #{destroyed.length} teams as of #{now}."
end

desc 'Called by the Heroku scheduler to update local scoreboards.'
task :update_local_scoreboards => :environment do
  n = 0
  LocalContest.pluck(:code).each do |code|
    LocalScoreboard.update_for_code(code)
    n += 1
  end
  Rails.logger.info "Updated #{n} local scoreboards."
end
