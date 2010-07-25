require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb'))


describe Megaleech::GoogleReader::FeedEntry do
  before do
    doc =Nokogiri::XML(fixture('sample_starred.xml'))
    @entry_data = doc.at_xpath("//xmlns:entry")
    @feed_entry = Megaleech::GoogleReader::FeedEntry.new(@entry_data)
  end

  it '#data should return raw data' do
    @feed_entry.data.should == @entry_data
  end

  it '#source should return source title' do
    @feed_entry.source.should == "TVTorrents.com"
  end

  it '#enclosure should return the enclosure link' do
    @feed_entry.enclosure.should == "http://torrent.tvtorrents.com/FetchTorrentServlet?info_hash=def0123456789abcdef0123456789abcdef0123&digest=abcdef0123467898abcdef0123467898abcdef012&hash=0123456789abcdef0123456789abcdef01234567"
  end

  it "#id should return original id" do
    @feed_entry.id.should == "http://torrent.tvtorrents.com/FetchTorrentServlet?info_hash=def0123456789abcdef0123456789abcdef0123&digest=abcdef0123467898abcdef0123467898abcdef012&hash=0123456789abcdef0123456789abcdef01234567"
  end

  it "#title should return title" do
    @feed_entry.title.should == "Cops - 21x35 - Coast to Coast"
  end

  it "#summary should return summary" do
    @feed_entry.summary.should == "Show Name:Cops; Show Title: Coast to Coast; Season: 21; Episode: 35; Filename: cops.s21e35.hdtv.xvid-2hd.avi;"
  end

  it "should not blow up if the entry is missing elements" do
    bad_xml = <<-badxml
<feed xmlns:idx="urn:atom-extension:indexing" xmlns:gr="http://www.google.com/schemas/reader/atom/"
      xmlns:media="http://search.yahoo.com/mrss/" xmlns="http://www.w3.org/2005/Atom" idx:index="no">
<entry></entry></feed>
    badxml
    doc = Nokogiri::XML(bad_xml)
    entry_data = doc.at_xpath("//xmlns:entry")
    feed_entry = Megaleech::GoogleReader::FeedEntry.new(entry_data)
    feed_entry.summary.should == nil
    feed_entry.id.should == nil
    feed_entry.title.should == nil
    feed_entry.enclosure.should == nil
    feed_entry.source.should == nil
  end
end