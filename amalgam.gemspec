$:.push File.expand_path("../lib", __FILE__)
$:.push File.expand_path("../simple_nested_set/lib", __FILE__)
# Maintain your gem's version:
require "amalgam/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "amalgam"
  s.version     = Amalgam::VERSION
  s.authors     = ["amalgam team"]
  s.email       = ["andrew@xtunes.cn"]
  s.homepage    = "http://github.com/amalgam/amalgam"
  s.summary     = "Amalgam is a gem for cms building"
  s.description = "CMS based on Mercury Editor"

  s.files = Dir["{app,config,db,lib,vendor,script}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 3.2.12"
  s.add_dependency "haml"
  s.add_dependency "mercury-rails", "~> 0.8.0"
  s.add_dependency "modernizr-rails"
  s.add_dependency "remotipart", '~> 1.0'
  s.add_dependency "jquery-ui-rails"
  s.add_dependency 'anjlab-bootstrap-rails', '~> 2.3'
  s.add_dependency 'nested_set', "~> 1.7.0"
  s.add_dependency 'stringex', '~> 1.5.1'
  #s.add_dependency 'carrierwave', "~> 0.6.2"
  #s.add_dependency 'mini_magick'
  s.add_dependency 'acts_as_list'
  s.add_dependency 'kaminari'
  s.add_dependency 'globalize3'
  s.add_dependency 'nokogiri', '~> 1.3'

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
  s.add_development_dependency "factory_girl_rails", "~> 4.0"
  s.add_development_dependency 'database_cleaner', '~> 0.9.1'
end
