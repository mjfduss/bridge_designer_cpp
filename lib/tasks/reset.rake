desc "Clean both the PostgreSQL and REDIS database."
task :clear_all => :environment do
  REDIS::flushall
  Affiliation.delete_all
  Best.delete_all
  Design.delete_all
  Member.delete_all
  PasswordReset.delete_all
  SequenceNumber.reset :design
  Team.delete_all
end
