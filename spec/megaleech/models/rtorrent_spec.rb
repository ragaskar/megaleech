require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb'))

describe Megaleech::Rtorrent do
  before do
    @socket = "/some/socket.path"
    @server = mock('some-server-object')
    SCGIXMLClient.should_receive(:new).with([@socket, '/RPC2']).and_return(@server)
    @rtorrent = Megaleech::Rtorrent.new(@socket)
  end

  describe "#download_torrent" do
    it "should make the correct calls to the rtorrent client to set up the torrent download" do
      torrent_file_path = "/some/file/path"
      destination = "/some/destination/file/path"
      mock_bencode_response = {"info" => {"some_torrent_data" => "foo"}}
      @server.should_receive(:call).with("load", torrent_file_path)
      BEncode.should_receive(:load_file).with(torrent_file_path).and_return(mock_bencode_response)
      @server.should_receive(:call).with("d.set_directory_base", Digest::SHA1.hexdigest(mock_bencode_response['info'].bencode), destination)
      @server.should_receive(:call).with("d.start", Digest::SHA1.hexdigest(mock_bencode_response['info'].bencode))
      FileUtils.should_receive(:mkdir_p).with(File.dirname(destination))
      @rtorrent.download_torrent(torrent_file_path, destination)
    end
  end

  describe "#completed_downloading" do
    it "should return true if the passed torrent has completed downloading" do
      torrent = Mom.torrent
      @server.should_receive(:call).with("download_list", "complete").and_return([torrent.info_hash])
      @rtorrent.has_completed_downloading?(torrent.info_hash).should == true
      end

    it "should return false if the passed torrent has completed downloading" do
      torrent = Mom.torrent
      @server.should_receive(:call).with("download_list", "complete").and_return([])
      @rtorrent.has_completed_downloading?(torrent.info_hash).should == false
    end
  end

  describe "#filename_for" do
    it "should return the filename" do
      torrent = Mom.torrent
      @server.should_receive(:call).with("d.get_base_filename", torrent.info_hash).and_return("filename")
      @rtorrent.filename_for(torrent.info_hash).should == "filename"
    end
  end
end