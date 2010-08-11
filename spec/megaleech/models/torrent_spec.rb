require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb'))

describe Megaleech::Torrent do
  describe "#next_download" do
    it "should return the oldest downloaded torrent" do
      Megaleech::Torrent.delete
      july_1 = Time.parse("July 01, 2010")
      july_2 = Time.parse("July 02, 2010")
      torrent_1 = Mom.torrent(:status => Megaleech::Torrent::SEEDING)
      torrent_2 = Mom.torrent(:status => Megaleech::Torrent::SEEDING)
      Megaleech::Torrent.filter(:info_hash => torrent_1.info_hash).update(:updated_at => july_2)
      Megaleech::Torrent.filter(:info_hash => torrent_2.info_hash).update(:updated_at => july_1)
      torrent_1.reload.updated_at > torrent_2.reload.updated_at
      Megaleech::Torrent.next_download.should == torrent_2
    end
  end

  describe "#destination=" do
    it "should remove illegal characters from the destination" do
      torrent = Megaleech::Torrent.new(:destination => "  Some Badly    Escaped: ? ! # ~ ( Filename ) ")
      torrent.destination.should == "Some Badly Escaped ( Filename )"
    end
  end

  describe "#info_hash=" do
    it "should uppercase values" do
      torrent = Megaleech::Torrent.new(:info_hash => "lowercase")
      torrent.info_hash.should == "LOWERCASE"
    end
  end

end
