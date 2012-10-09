namespace :amalgam  do
  desc "load the pages"

  task :load => :environment do
    if(ENV['force'] == 'true')
      force = true
    else
      force = false
    end
    attributes = ENV['attributes'] ? ENV['attributes'].split(',') : []
    Amalgam::Tree::Importable.import(IO.read('db/pages.yml')||IO.read('db/pages.yml'),force, attributes)
  end
end