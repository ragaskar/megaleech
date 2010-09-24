require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper.rb'))

describe Megaleech::BTN do

  before(:each) do
    doc =Nokogiri::XML(fixture('sample_btn.xml'))
    @entry = Megaleech::GoogleReader::FeedEntry.new(doc.at_xpath("//xmlns:entry"))
    @destination_path = "/some/path"
    @btn = Megaleech::BTN.new(@entry, @destination_path)
  end

  describe "#download_torrent_file" do
    it "should download a file from the source to the destination path" do
      mechanize = Mechanize.new
      Mechanize.should_receive(:new).and_return(mechanize)
      mock_mechanize_response = mock("response")
      mock_mechanize_response.should_receive(:filename).and_return("some_file.torrent")
      mock_mechanize_response.should_receive(:save_as).with("#{@destination_path}/some_file.torrent")
      mechanize.should_receive(:get).with(@entry.alternate).and_return(mock_mechanize_response)
      result = @btn.download_torrent_file
      result.should == "#{@destination_path}/some_file.torrent"
    end
  end

  describe "#destination" do
    it "should return the correct destination path" do
      @btn.destination.should == "tv/America's Got Talent/Season 5/"
    end

    it "should default to season 0 when the summary is not standard" do
      @entry.stub!(:summary).and_return("48.Hours.Mystery-Justice.in.the.Heartland.PDTV.XviD-YT")
      @btn.destination.should == "tv/America's Got Talent/Season 0/"      
    end
  end

  describe "#touch_path" do
    it "should return the correct touch_path" do
      @btn.touch_path.should == "tv/America's Got Talent"
    end
  end
end