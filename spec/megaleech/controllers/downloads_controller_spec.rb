require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb'))

describe Megaleech::DownloadsController do
  describe "#call" do
    before(:each) do
      Megaleech.stub!(:download_directory).and_return("/some/dl/dir")
      Megaleech::Torrent.delete
      @torrent = Mom.torrent(:status => Megaleech::Torrent::SEEDING, :destination => "Show (Indi)/Season 1")
      @source = File.join(Megaleech.download_directory, @torrent.destination)
      @root_dest = "/root/(My) Television/"
      @user = "some_user"
      @port = 1234
      @controller = Megaleech::DownloadsController.new(:port => @port, :user => @user, :destination => @root_dest)
      @controller.stub(:puts)
    end

    it "should mark Torrent.next_download as downloading, then mark it finished once it reverse rsyncs it" do
      @controller.should_receive(:system).with("ssh -p 1234 some_user@localhost \"mkdir -p \\\"/root/\\(My\\) Television/Show \\(Indi\\)/Season 1\\\"\"").and_return(true)
      @controller.should_receive(:system).with("rsync -r --progress --partial --bwlimit 3000 --rsh=\"ssh -p #{@port}\" \"#{@source}\" \"#{@user}@localhost:/root/\\(My\\)\\ Television/Show\\ \\(Indi\\)/Season\\ 1\"").and_return(true)
      @controller.run
      @torrent.reload.status.should == Megaleech::Torrent::FINISHED
    end

    it "should return if there is no next download" do
      Megaleech::Torrent.delete
      @controller.run
    end

    it "should not mark as finished if rsync errors" do
      @controller.should_receive(:system).with("ssh -p 1234 some_user@localhost \"mkdir -p \\\"/root/\\(My\\) Television/Show \\(Indi\\)/Season 1\\\"\"").and_return(true)
      @controller.should_receive(:system).with("rsync -r --progress --partial --bwlimit 3000 --rsh=\"ssh -p #{@port}\" \"#{@source}\" \"#{@user}@localhost:/root/\\(My\\)\\ Television/Show\\ \\(Indi\\)/Season\\ 1\"").and_return(false)
      @controller.run
      @torrent.reload.status.should == Megaleech::Torrent::DOWNLOADING
    end
  end
end