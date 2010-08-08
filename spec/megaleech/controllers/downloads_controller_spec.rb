require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb'))

describe Megaleech::DownloadsController do
  describe "#call" do
    before(:each) do
      Megaleech.stub!(:download_directory).and_return("/some/dl/dir")
      Megaleech::Torrent.delete
      @torrent = Mom.torrent(:status => Megaleech::Torrent::SEEDING)
      @source = File.join(Megaleech.download_directory, @torrent.destination)
      @root_dest = "/root/dir/"
      @destination = File.join(@root_dest, @torrent.destination)
      @user = "some_user"
      @port = 1234
      @controller = Megaleech::DownloadsController.new(:port => @port, :user => @user, :destination => @root_dest)
    end

    it "should mark Torrent.next_download as downloading, then mark it finished once it reverse rsyncs it" do
      @controller.should_receive(:system).with("ssh -p 1234 some_user@localhost \"mkdir -p \\\"#{@destination}\\\"\"").and_return(true)
      @controller.should_receive(:system).with("rsync -r --bwlimit 3000 --partial --rsh=\"ssh -p #{@port}\" \"#{@source}\" \"#{@user}@localhost:#{@destination}\"").and_return(true)
      @controller.run
      @torrent.reload.status.should == Megaleech::Torrent::FINISHED
    end

    it "should return if there is no next download" do
      Megaleech::Torrent.delete
      @controller.run
    end

    it "should not mark as finished if rsync errors" do
      @controller.should_receive(:system).with("ssh -p 1234 some_user@localhost \"mkdir -p \\\"#{@destination}\\\"\"").and_return(true)
      @controller.should_receive(:system).with("rsync -r --bwlimit 3000 --partial --rsh=\"ssh -p #{@port}\" \"#{@source}\" \"#{@user}@localhost:#{@destination}\"").and_return(false)
      @controller.run
      @torrent.reload.status.should_not == Megaleech::Torrent::FINISHED
    end
  end
end