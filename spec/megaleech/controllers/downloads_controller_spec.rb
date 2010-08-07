require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb'))

describe Megaleech::DownloadsController do
  describe "#call" do
    before(:each) do
      Megaleech.stub!(:download_directory).and_return("/some/dl/dir")
      Megaleech.stub!(:client_download_directory).and_return("/some/other/dl/dir")
      Megaleech.stub!(:client_port).and_return("some_port")
      Megaleech.stub!(:client_user).and_return("some_user")
      Megaleech::Torrent.delete
      @torrent = Mom.torrent(:status => Megaleech::Torrent::SEEDING)
      @source = File.join(Megaleech.download_directory, @torrent.destination)
      @destination = File.join(Megaleech.client_download_directory, @torrent.destination)
      @controller = Megaleech::DownloadsController.new
    end

    it "should mark Torrent.next_download as downloading, then mark it finished once it reverse rsyncs it" do
      @controller.should_receive(:system).with("ssh -p #{Megaleech.client_port} #{Megaleech.client_user}@localhost \"mkdir -p \\\"#{@destination}\\\"\"").and_return(true)
      @controller.should_receive(:system).with("rsync -r --bwlimit 3000 --partial --rsh=\"ssh -p #{Megaleech.client_port}\" \"#{@source}\" \"#{Megaleech.client_user}@localhost:#{@destination}\"").and_return(true)
      @controller.run
      @torrent.reload.status.should == Megaleech::Torrent::FINISHED
    end

    it "should return if there is no next download" do
      Megaleech::Torrent.delete
      @controller.run      
    end

    it "should not mark as finished if rsync errors" do
      @controller.should_receive(:system).with("ssh -p #{Megaleech.client_port} #{Megaleech.client_user}@localhost \"mkdir -p \\\"#{@destination}\\\"\"").and_return(true)
      @controller.should_receive(:system).with("rsync -r --bwlimit 3000 --partial --rsh=\"ssh -p #{Megaleech.client_port}\" \"#{@source}\" \"#{Megaleech.client_user}@localhost:#{@destination}\"").and_return(false)
      @controller.run
      @torrent.reload.status.should_not == Megaleech::Torrent::FINISHED
    end
  end
end