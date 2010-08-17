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

  it '#source_link should return source link' do
    @feed_entry.source_link.should == "http://www.tvtorrents.com"
    end

  it '#source_hash should return hashed source id' do
    @feed_entry.source_hash.should == Digest::MD5.hexdigest("tag:google.com,2005:reader/feed/http://www.tvtorrents.com/RssServlet?digest=abcdef0123467898abcdef0123467898abcdef012&hash=0123456789abcdef0123456789abcdef01234567")
  end

  it '#source_id should return source id' do
    @feed_entry.source_id.should == "tag:google.com,2005:reader/feed/http://www.tvtorrents.com/RssServlet?digest=abcdef0123467898abcdef0123467898abcdef012&hash=0123456789abcdef0123456789abcdef01234567"
  end

  it '#enclosure should return the enclosure link' do
    @feed_entry.enclosure.should == "http://torrent.tvtorrents.com/FetchTorrentServlet?info_hash=def0123456789abcdef0123456789abcdef0123&digest=abcdef0123467898abcdef0123467898abcdef012&hash=0123456789abcdef0123456789abcdef01234567"
  end

  describe "#id" do
    it "#should return original id if it exists" do
      @feed_entry.id.should == "http://torrent.tvtorrents.com/FetchTorrentServlet?info_hash=def0123456789abcdef0123456789abcdef0123&digest=abcdef0123467898abcdef0123467898abcdef012&hash=0123456789abcdef0123456789abcdef01234567"
    end

    it "#should use google id if id is missing" do
      doc = Nokogiri::XML(fixture('sample_ptm.xml'))
      entry_data = doc.at_xpath("//xmlns:entry")
      feed_entry = Megaleech::GoogleReader::FeedEntry.new(entry_data)
      feed_entry.id.should == "tag:google.com,2005:reader/item/0fd01e637b9ed61d"
    end
  end

  it "#title should return title" do
    @feed_entry.title.should == "Cops - 21x35 - Coast to Coast"
  end

  it "#updated should return updated time" do
    @feed_entry.updated.should == Time.parse("2010-08-06T15:21:39Z")
  end

  it "#summary should return summary" do
    @feed_entry.summary.should == "Show Name:Cops: (Indi); Show Title: Coast to Coast; Season: 21; Episode: 35; Filename: cops.s21e35.hdtv.xvid-2hd.avi;"
  end

  it "#alternate should return the main alternate link" do
    @feed_entry.alternate.should == "http://torrent.tvtorrents.com/FetchTorrentServlet?info_hash=alt_hash&digest=abcdef0123467898abcdef0123467898abcdef012&hash=0123456789abcdef0123456789abcdef01234567"
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