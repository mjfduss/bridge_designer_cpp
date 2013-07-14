desc "Called by the Heroku scheduler to clean abandoned registrations."
task :clean_abandoned_registrations => :environment do
  now = Time.now
  puts "Cleaning abandoned registrations #{now}"
  # The time should be greater than then session expiration time.
  Team.destroy_all(['reg_completed IS NULL and updated_at < ?', 30.minutes.ago(now)])
end