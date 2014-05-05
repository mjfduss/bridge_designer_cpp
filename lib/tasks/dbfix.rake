desc 'Rebuild dependent database tables.'
task :db_rebuild => :environment do
  before, after = Best.rebuild
  Rails.logger.info "Created #{after} best records. Previously #{before}."
end
