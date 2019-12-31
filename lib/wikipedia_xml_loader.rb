require 'nokogiri'

# Wikipedia XML Loader
class WikipediaXmlLoader
  class MaximumNumberHasBeenReached < StandardError; end

  attr_accessor :file, :max_num_reads

  def initialize(file, max_num_reads = 1_000)
    @file = file
    @max_num_reads = max_num_reads.to_i
    @handler = nil
  end

  def load
    num_articles = 0
    @handler = DocHandler.new do |article|
      raise MaximumNumberHasBeenReached if num_articles >= max_num_reads

      article = Article.new(title: article[:title], content: article[:text], revision_timestamp: article[:timestamp])
      article.content = Nokogiri::HTML(article.content).text.slice(1, 20_000)
      num_articles += 1 if article.save
    end
    parse
  end

  def parse
    parser = Nokogiri::XML::SAX::Parser.new(@handler)
    io = file.is_a?(IO) ? file : File.open(file)
    parser.parse(io)
  rescue MaximumNumberHasBeenReached
    io.close
  end

  # Wikipedia XML Document Handler
  class DocHandler < Nokogiri::XML::SAX::Document
    MONITORED_TAGS = %w(page title revision timestamp text).freeze
    BOOLEAN_VARIABLES = MONITORED_TAGS.map { |tag| 'in_' + tag }

    attr_accessor :current_article, *BOOLEAN_VARIABLES

    def initialize(&block)
      BOOLEAN_VARIABLES.each do |var_name|
        send(var_name.to_s + '=', false)
      end
      prepare_article
      @block = block
    end

    def prepare_article
      @current_article = { text: '', end_revision: false }
    end

    def start_element(name, _ = [])
      send("in_#{name}=", true) if MONITORED_TAGS.member?(name)
      prepare_article if name == 'page'
    end

    def characters(text)
      current_article[:title] = text if in_page && in_title
      current_article[:text] += text if in_revision && in_text && !@current_article[:end_revision]
    end

    def end_element(name)
      send("in_#{name}=", false) if MONITORED_TAGS.member?(name)
      @current_article[:end_revision] = true if name == 'revision'
      generate_article if name == 'page'
    end

    def generate_article
      current_article[:title].gsub!(/^Wikipedia: /, '')
      @block.call(current_article)
    end
  end
end
