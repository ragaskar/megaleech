require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper.rb'))

describe Megaleech::TvTorrents do

  before(:each) do
    @entry = mock_entry
    @destination_path = "/some/path"
    @tv_torrents = Megaleech::TvTorrents.new(@entry, @destination_path)
  end

  describe "#download_torrent_file" do
    it "should download a file from the source to the destination path" do
      mechanize = Mechanize.new
      Mechanize.should_receive(:new).and_return(mechanize)
      mock_mechanize_response = mock("response")
      mock_mechanize_response.should_receive(:filename).and_return("some_file.torrent")
      mock_mechanize_response.should_receive(:save_as).with("#{@destination_path}/some_file.torrent")
      mechanize.should_receive(:get).with(@entry.enclosure).and_return(mock_mechanize_response)
      result = @tv_torrents.download_torrent_file
      result.should == "#{@destination_path}/some_file.torrent"
    end
    end

  describe "#destination" do
    it "should return the correct destination path" do
      @tv_torrents.destination.should == "tv/Cops: (Indi)/Season 21/"
    end
  end

  describe "#touch_path" do
    it "should return the correct touch path" do
      @tv_torrents.touch_path.should == "tv/Cops: (Indi)"
    end
  end


end