require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb'))

describe Megaleech::DownloadsController do
  describe "#call" do
    before(:each) do
      Megaleech.stub!(:download_directory).and_return("/some/dl/dir")
      Megaleech::Torrent.delete
      @torrent = Mom.torrent(:status => Megaleech::Torrent::SEEDING,
                             :destination => "tv/Show (Indi)/Season 1",
                             :touch_path => "tv/Show (Indi)")
      @source = File.join(Megaleech.download_directory, @torrent.destination)
      @root_dest = "/root/(My) Television's Favorite Show/"
      @create_path = "/root/(My) Television's Favorite Show/tv/Show (Indi)/Season 1"
      @rsync_path = "/root/\\(My\\)\\ Television\\'s\\ Favorite\\ Show/tv/Show\\ \\(Indi\\)/Season\\ 1"
      @touch_path = "/root/(My) Television's Favorite Show/tv/Show (Indi)"
      @user = "some_user"
      @port = 1234
      @controller = Megaleech::DownloadsController.new(:port => @port, :user => @user, :destination => @root_dest)
      @controller.stub(:puts)


    end

    context "when there is a next download" do
      before(:each) do
        @controller.should_receive(:system).with("ssh -p 1234 some_user@localhost \"mkdir -p \\\"#{@create_path}\\\"\"").and_return(true)
        @controller.should_receive(:system).with("rsync -r --progress --partial --bwlimit 3000 --rsh=\"ssh -p #{@port}\" \"#{@source}\" #{@user}@localhost:\"#{@rsync_path}\"").and_return(true)
        @controller.should_receive(:system).with("ssh -p 1234 some_user@localhost \"touch \\\"#{@touch_path}\\\"\"").and_return(true)
      end

      it "should mark Torrent.next_download as downloading, then mark it finished once it reverse rsyncs it" do
        @controller.run
        @torrent.reload.status.should == Megaleech::Torrent::FINISHED
      end

      it "should touch a path if touch_path is set" do
        @torrent.stub(:touch_path).and_return(@touch_path)

        @controller.run
      end
    end

    it "should return if there is no next download" do
      Megaleech::Torrent.delete
      @controller.run
    end

    it "should not mark as finished if rsync errors" do
      @controller.should_receive(:system).with("ssh -p 1234 some_user@localhost \"mkdir -p \\\"#{@create_path}\\\"\"").and_return(true)
      @controller.should_receive(:system).with("rsync -r --progress --partial --bwlimit 3000 --rsh=\"ssh -p #{@port}\" \"#{@source}\" #{@user}@localhost:\"#{@rsync_path}\"").and_return(false)
      @controller.run
      @torrent.reload.status.should == Megaleech::Torrent::DOWNLOADING
    end


  end
end