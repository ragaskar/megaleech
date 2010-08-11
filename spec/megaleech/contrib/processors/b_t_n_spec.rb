require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper.rb'))

describe BTN do

  before(:each) do
    doc =Nokogiri::XML(fixture('sample_btn.xml'))
    @entry = Megaleech::GoogleReader::FeedEntry.new(doc.at_xpath("//xmlns:entry"))
    @destination_path = "/some/path"
    @btn = BTN.new(@entry, @destination_path)
  end

  describe "#download_torrent_file" do
    it "should download a file from the source to the destination path" do
      mechanize = Mechanize.new
      Mechanize.should_receive(:new).and_return(mechanize)
      mock_mechanize_response = mock("response")
      mock_mechanize_response.should_receive(:filename).and_return("some_file.torrent")
      mock_mechanize_response.should_receive(:save_as).with("#{@destination_path}/some_file.torrent")
      mechanize.should_receive(:get).with(@entry.enclosure).and_return(mock_mechanize_response)
      result = @btn.download_torrent_file
      result.should == "#{@destination_path}/some_file.torrent"
    end
  end

  describe "#destination" do
    it "should return the correct destination path" do
      @btn.destination.should == "tv/America's Got Talent/Season 5/"
    end
  end
end