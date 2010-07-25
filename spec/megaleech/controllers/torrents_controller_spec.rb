require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb'))

describe Megaleech::TorrentsController do

  before do
    path = lib_path('megaleech/config/.megaleech.rc')
    mock_parseconfig(path)
    starred_response = fixture('sample_starred_no_continuation.xml')
    mock_google_reader('username', 'password', starred_response)
    @controller = Megaleech::TorrentsController.new
    @rtorrent = Megaleech::Rtorrent.new("some_socket_path")
    mock_entries = mock("entries", :filter => mock("result", :count => 0))
    mock_entries.stub!(:insert)
    @controller.stub!(:entries).and_return(mock_entries)
    Megaleech::Rtorrent.stub(:new).and_return(@rtorrent)
    mechanize = Mechanize.new
    Mechanize.stub!(:new).and_return(mechanize)
    mock_mechanize_response = mock("response")
    mock_mechanize_response.stub!(:filename).and_return("some_file.torrent")
    mock_mechanize_response.stub!(:save_as)
    mechanize.stub!(:get).and_return(mock_mechanize_response)
  end

  it "#run should add new torrents to rtorrent with the correct path" do
    @rtorrent.should_receive(:download_torrent).with("/tmp/.torrent/some_file.torrent", "/home/user/torrents/tv/Cops/Season 21/")
    @rtorrent.should_receive(:download_torrent).with("/tmp/.torrent/some_file.torrent", "/home/user/torrents/tv/Miami Social/Season 1/")
    @controller.run
  end
end