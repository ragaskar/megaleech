require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb'))

describe Megaleech::TorrentsController do

  before do
    starred_response = fixture('sample_starred_no_continuation.xml')
    mock_google_reader('username', 'password', starred_response)
    @controller = Megaleech::TorrentsController.new
    @rtorrent = Megaleech::Rtorrent.new("some_socket_path")
    Megaleech.stub(:rtorrent).and_return(@rtorrent)
    @download_path = "/some/download/path"
    @meta_path = "/some/meta/path"
    Megaleech.stub!(:download_directory).and_return(@download_path)
    Megaleech.stub!(:meta_path).and_return(@meta_path)

    mechanize = Mechanize.new
    Mechanize.stub!(:new).and_return(mechanize)
    mock_mechanize_response = mock("response")
    mock_mechanize_response.stub!(:filename).and_return("some_file.torrent")
    mock_mechanize_response.stub!(:save_as)
    mechanize.stub!(:get).and_return(mock_mechanize_response)

    Megaleech::Torrent.delete
  end

  describe "#run" do

    it "should add new torrents to rtorrent with the correct path and save torrent records" do
      @rtorrent.should_receive(:download_torrent).
        with("#{@meta_path}/some_file.torrent", "#{@download_path}/tv/Cops/Season 21/").
        and_return("some_info_hash1")
      @rtorrent.should_receive(:download_torrent).
        with("#{@meta_path}/some_file.torrent", "#{@download_path}/tv/Miami Social/Season 1/").
        and_return("some_info_hash2")
      @controller.run
      Megaleech::Torrent.count.should == 2
      cops_torrent = Megaleech::Torrent.filter(:info_hash => "some_info_hash1").first
      cops_torrent.status.should == Megaleech::Torrent::QUEUED
    end

    it "should not attempt to queue existing torrents" do
      @rtorrent.stub(:has_completed_downloading?).and_return(false)
      torrent = queued_torrent
      @rtorrent.should_not_receive(:download_torrent).
        with("#{@meta_path}/some_file.torrent", "#{@download_path}/tv/Cops/Season 21/")
      @rtorrent.should_receive(:download_torrent).
        with("#{@meta_path}/some_file.torrent", "#{@download_path}/tv/Miami Social/Season 1/").
        and_return("some_info_hash2")
      Megaleech::Torrent.count.should == 1
      @controller.run
      Megaleech::Torrent.count.should == 2
    end

    it "should update the status of torrents that have finished downloading" do
      torrent = queued_torrent
      @rtorrent.stub(:download_torrent)
      @rtorrent.should_receive(:has_completed_downloading?).with(torrent).and_return(true)
      @controller.run
      torrent.reload.status.should == Megaleech::Torrent::SEEDING
    end

    it "should not add old entries" do
      @controller.run
      Megaleech::Torrent.delete
      Megaleech::Torrent.count.should == 0
      @rtorrent.should_not_receive(:download_torrent)      
      @controller.run
      Megaleech::Torrent.count.should == 0
    end

    describe "reaping" do
      describe "should reap downloaded files" do
        it "which have a ratio >= SEED_TO"
        it "which have a date older than >= SEED_FOR"
      end
      describe "should not reap downloaded files" do
        it "which do not have a ratio >= SEED_TO"
        it "which do not have a date older than >= SEED_FOR"
      end
    end
  end

end