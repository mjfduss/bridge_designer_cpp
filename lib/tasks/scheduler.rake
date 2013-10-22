desc "Called by the Heroku scheduler to clean abandoned registrations."
task :clean_abandoned_registrations => :environment do
  now = Time.now
  puts "Cleaning abandoned registrations #{now}"
  # The time should be greater than then session expiration time.
  Team.where('reg_completed IS NULL AND updated_at < ?', 30.minutes.ago(now)).destroy_all
end