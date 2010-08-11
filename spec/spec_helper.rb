$: << File.expand_path(File.dirname(__FILE__) + "/../lib")
require 'rubygems'
require "spec"
ENV["MEGALEECH_PATH"] = File.expand_path(File.join(File.dirname(__FILE__), "..", ".megaleech"))
require "megaleech"

def fixture(filename)
  File.new(File.join(File.dirname(__FILE__), 'fixture', filename)).read
end

def fixture_path(filename)
  File.expand_path(File.join(File.dirname(__FILE__), 'fixture', filename))
end

def lib_path(filename)
  File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', filename))
end

def root_path(filename = nil)
  File.expand_path(File.join(File.dirname(__FILE__), '..', filename))
end

def mock_google_reader(user, password, response)
  auth = 'some-auth'
  fake_http = mock(Net::HTTP)
  MockHelpers.google_reader_login(user, password, auth, fake_http)
  MockHelpers.google_reader_starred(auth, response, fake_http)
  Net::HTTP.stub(:new => fake_http)
end

def mock_google_reader_login (user, password)
  auth = 'some-auth'
  fake_http = mock(Net::HTTP)
  MockHelpers.google_reader_login(user, password, auth, fake_http)
  Net::HTTP.stub(:new => fake_http)
  auth
end

def mock_google_reader_starred(sid, response)
  fake_http = mock(Net::HTTP)
  MockHelpers.google_reader_starred(sid, response, fake_http)
  Net::HTTP.stub(:new => fake_http)
end

def mock_parseconfig(path)
  parseconfig = ParseConfig.new(fixture_path('sample_rtorrent_config'))
  ParseConfig.should_receive(:new).with(path).and_return(parseconfig)
end

def mock_rtorrent(path, server)
  SCGIXMLClient.stub!(:new).with([path, '/RPC2']).and_return(server)
  Megaleech::Rtorrent.new(path)
end

class Mom
  @@feed_id = 0
  def self.torrent(options = {})
    @@feed_id = @@feed_id + 1
    options = {:feed_id => (@@feed_id),
               :status => Megaleech::Torrent::QUEUED,
               :destination => "Crazy : Punctuation!*#~;/Season 1",
               :info_hash => "some hash #{@@feed_id}",
               :filename => "Filename #{@@feed_id}"}.merge(options)
    Megaleech::Torrent.create(options)
  end
end

def mock_entry
  doc =Nokogiri::XML(fixture('sample_starred.xml'))
  Megaleech::GoogleReader::FeedEntry.new(doc.at_xpath("//xmlns:entry"))
end

class MockHelpers

  def self.google_reader_starred(auth, response, fake_http)
    fake_response = Spec::Mocks::Mock.new('response', :body=> response)
    fake_http.stub(:get) do |url, params|
      url.should =~ Regexp.new("/reader/atom/user/-/state/com.google/starred")
      params['Authorization'].should =~ Regexp.new(auth)
      fake_response
    end
  end

  def self.google_reader_login(user, password, auth, fake_http)
    fake_http.stub(:use_ssl=)
    fake_response = Spec::Mocks::Mock.new('response', :body=>"SID=some-string\nAuth=#{auth}")
    fake_http.stub(:post).with("/accounts/ClientLogin", Megaleech::GoogleReader.to_query_string(
      {'Email' => user,
       'Passwd' => password,
       'service' => 'reader',
       "source" => "Megaleech"
      })).and_return(fake_response)
  end

end