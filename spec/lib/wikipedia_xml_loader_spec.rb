require "rails_helper"

describe 'WikipediaXmlLoader' do
  describe 'load' do
    let!(:xml_file) { file_fixture('first-10000-lines-jawiki-20191220-pages-articles-multistream.xml') }
    let!(:loader) { WikipediaXmlLoader.new(xml_file) }

    it 'should load data' do
      expect(Article.count).to eq(0)
      loader.load
      expect(Article.count).to eq(36)
    end
  end
end
