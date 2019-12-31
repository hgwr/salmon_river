namespace :load_wikipedia do
  desc 'A task for loading XML file from Wikipedia'
  task :xml, %w(filename max_num_reads) => :environment do |_, args|
    loader = WikipediaXmlLoader.new(args.filename, args.max_num_reads || 1000)
    loader.load
    Article.__elasticsearch__.create_index!
    Article.import
  end
end
