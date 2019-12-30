require 'nokogiri'

# Wikipedia XML Loader
class WikipediaXmlLoader
  attr_accessor :filename, :max_num_reads

  def initialize(filename, max_num_reads = 1000)
    @filename = filename
    @max_num_reads = max_num_reads
  end

  def load
    num_articles = 0
    handler = DocHandler.new do |article|
      article = Article.new(title: article[:title], content: article[:text], revision_timestmp: article[:timestamp])
      num_articles += 1 if article.save
      break if num_articles > max_num_reads
    end
    parser = Nokogiri::XML::SAX::Parser.new(handler)
    parser.parse(File.open(filename))
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
      @current_article = {}
    end

    def start_element(name, _ = [])
      send("in_#{name}=", true) if MONITORED_TAGS.member?(name)
      prepare_article if name == 'page'
    end

    def characters(text)
      return unless current_article[:text].blank?

      current_article[:title] = text if in_page && in_title
      process_article(text) if in_revision && in_text
    end

    def process_article(text)
      text = text.strip
      return if text.blank?

      current_article[:text] = text
    end

    def end_element(name)
      send("in_#{name}=", false) if MONITORED_TAGS.member?(name)
      generate_article if name == 'page'
    end

    def generate_article
      current_article[:title].gsub!(/^Wikipedia: /, '')
      @block.call(current_article)
    end
  end
end
