$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "amalgam/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "amalgam"
  s.version     = Amalgam::VERSION
  s.authors     = ["amalgam team"]
  s.email       = ["andrew@xtunes.cn"]
  s.homepage    = "http://github.com/amalgam/amalgam"
  s.summary     = "TODO: Summary of Amalgam."
  s.description = "TODO: Description of Amalgam."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 3.2.8"
  s.add_dependency "haml-rails"
  s.add_dependency "mercury-rails", "~> 0.8.0"
  s.add_dependency "modernizr-rails"
  s.add_dependency "remotipart", '~> 1.0'
  s.add_dependency "jquery-ui-rails"
  s.add_dependency 'anjlab-bootstrap-rails', '~> 2.0.3'
  s.add_dependency 'nested_set', "~> 1.7.0"
  #s.add_dependency 'carrierwave', "~> 0.6.2"
  #s.add_dependency 'mini_magick'
  s.add_dependency 'acts_as_list'
  s.add_dependency 'kaminari'

  #TODO: 2.1之后是jquery1.8,但是现在mercury对1.8有兼容问题,2.0.3版本是1.7最后的版本，但是ajax:aborted:file事件无法触发，所以现在只能使用2.0.2版本
  s.add_dependency 'jquery-rails', '2.0.2'

  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "capybara"
  s.add_development_dependency 'rb-fsevent'
  s.add_development_dependency 'growl'
  s.add_development_dependency "guard-livereload"
  s.add_development_dependency "guard-bundler"
  s.add_development_dependency "guard-pow"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "guard-spork"
  s.add_development_dependency "launchy"
end
