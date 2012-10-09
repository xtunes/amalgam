namespace :amalgam  do
	desc "dump the pages"

	task :dump => :environment do
    attributes = ENV['attributes'] ? ENV['attributes'].split(',') : []
		hash = Amalgam::Tree::Exportable.export(attributes)
		File.open('db/pages.yml', 'w') {|f| f.write(hash.to_yaml) }
	end
end