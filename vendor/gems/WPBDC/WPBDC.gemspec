Gem::Specification.new do |spec|
  spec.name        = 'WPBDC'
  spec.version     = '2013.1.0'
  spec.date        = '2012-09-30'
  spec.summary     = "Judge functions of the West Point Bridge Design Contest"
  spec.description = "Module container for C code extension."
  spec.authors     = ["Gene Ressler"]
  spec.email       = 'gene.ressler@gmail.com'
  spec.homepage    = 'http://rubygems.org/gems/wpbdc_judge'

  spec.files       = Dir.glob('lib/**/*.rb') + Dir.glob('ext/**/*.{c,h,rb}')
  spec.extensions  = ['ext/WPBDC/extconf.rb']
  spec.executables = ['WPBDC']
end
