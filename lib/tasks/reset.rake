desc "Clean both the PostgreSQL and REDIS database."
task :clear_all => :environment do
  Admin::ServerStatusesController.reset_all
end
