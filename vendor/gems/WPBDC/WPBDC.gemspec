Gem::Specification.new do |spec|
  spec.name        = 'WPBDC'
  spec.version     = '2013.1.1'
  spec.date        = '2012-11-28'
  spec.summary     = "Judge functions of the West Point Bridge Design Contest"
  spec.description = "Container for C code extension that implements the West Point Bridge Contest Judge."
  spec.authors     = ["Gene Ressler"]
  spec.email       = 'gene.ressler@gmail.com'
  spec.homepage    = 'http://rubygems.org/gems/wpbdc_judge'

  spec.files       = Dir.glob('lib/**/*.rb') + Dir.glob('ext/**/*.{c,h,rb}')
  spec.extensions  = ['ext/WPBDC/extconf.rb']
  spec.executables = ['WPBDC']
end
