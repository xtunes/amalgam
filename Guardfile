guard 'livereload' do
  watch(%r{spec/dummy/app/views/.+\.(erb|haml|slim)})
  watch(%r{spec/dummy/app/helpers/.+\.rb})
  watch(%r{spec/dummy/public/.+\.(css|js|html)})
  watch(%r{spec/dummy/config/locales/.+\.yml})
  # Rails Assets Pipeline
  watch(%r{spec/dummy/(app|vendor)/assets/\w+/(.+\.(css|js|html)).*})  { |m| "/assets/#{m[2]}" }
end

guard 'bundler' do
  watch('Gemfile')
  watch(/^.+\.gemspec/)
end

guard 'pow' do
  watch('.powrc')
  watch('.powenv')
  watch('.rvmrc')
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('config/application.rb')
  watch('config/environment.rb')
  watch(%r{^config/environments/.*\.rb$})
  watch(%r{^config/initializers/.*\.rb$})
end
guard 'spork', :cucumber_env => { 'RAILS_ENV' => 'test' }, :rspec_env => { 'RAILS_ENV' => 'test' } do
  watch('spec/dummy/config/application.rb')
  watch('spec/dummy/config/environment.rb')
  watch('spec/dummy/config/environments/test.rb')
  watch(%r{^spec/dummy/config/initializers/.+\.rb$})
  watch('amalgam.gemspec')
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('spec/spec_helper.rb') { :rspec }
  watch(%r{features/support/}) { :cucumber }
end

guard 'rspec', :cli => "--color --drb", :version => 2 do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { "spec" }
  watch('spec/spec_helper.rb')  { "spec" }

  # Rails example
  watch(%r{^spec/dummy/app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^spec/dummy/app/(.*)(\.erb|\.haml)$})                 { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r{^spec/dummy/app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
  watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
  watch('spec/dummy/config/routes.rb')                           { "spec/routing" }
  watch('spec/dummy/spec/dummy/app/controllers/application_controller.rb')  { "spec/controllers" }

  # Capybara request specs
  watch(%r{^spec/dummy/spec/dummy/app/views/(.+)/.*\.(erb|haml)$})          { |m| "spec/requests/#{m[1]}_spec.rb" }

  # Turnip features and steps
  watch(%r{^spec/acceptance/(.+)\.feature$})
  watch(%r{^spec/acceptance/steps/(.+)_steps\.rb$})   { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'spec/acceptance' }
end