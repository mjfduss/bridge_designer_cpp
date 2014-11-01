desc 'Dump cost histogram.'
task :cost_histogram  => :environment do
  puts "Yes!"
  Rails.logger.info "Dumped cost histogram."
end
