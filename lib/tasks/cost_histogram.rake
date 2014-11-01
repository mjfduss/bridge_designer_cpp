desc 'Dump cost histogram.'
task :cost_histogram  => :environment do
  Design.cost_histogram
  Rails.logger.info "Dumped cost histogram."
end
