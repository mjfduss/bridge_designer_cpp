Gem::Specification.new do |spec|
  spec.name        = 'WPBDC'
  spec.version     = '2016.1.3'
  spec.date        = '2016-01-01'
  spec.summary     = "Judge functions of the Engineering Encounters Bridge Design Contest"
  spec.description = "Container for C code extension that implements the West Point Bridge Contest Judge."
  spec.authors     = ["Gene Ressler"]
  spec.email       = 'gene.ressler@gmail.com'
  spec.homepage    = 'http://rubygems.org/gems/wpbdc_judge'
  spec.license     = 'GPL-3'

  spec.files       = Dir.glob('lib/**/*.rb') + Dir.glob('ext/**/*.{c,h,rb}')
  spec.extensions  = ['ext/WPBDC/extconf.rb']
end
