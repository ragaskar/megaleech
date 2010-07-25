$: << File.expand_path(File.dirname(__FILE__) + "/../lib")
require 'rubygems'
require File.expand_path(File.join(File.dirname(__FILE__), '..', '/lib/megaleech'))

def fixture(filename)
  File.new(File.join(File.dirname(__FILE__), 'fixture', filename)).read
end

def fixture_path(filename)
  File.expand_path(File.join(File.dirname(__FILE__), 'fixture', filename))
end

def lib_path(filename)
  File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', filename))
end

def mock_google_reader(user, password, response)
  sid = 'some-sid'
  fake_http = mock(Net::HTTP)
  MockHelpers.google_reader_login(user, password, sid, fake_http)
  MockHelpers.google_reader_starred(sid, response, fake_http)
  Net::HTTP.stub(:new => fake_http)
end

def mock_google_reader_login (user, password)
  sid = 'some-sid'
  fake_http = mock(Net::HTTP)
  MockHelpers.google_reader_login(user, password, sid, fake_http)
  Net::HTTP.stub(:new => fake_http)
  sid
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

def mock_entry
  doc =Nokogiri::XML(fixture('sample_starred.xml'))
  Megaleech::GoogleReader::FeedEntry.new(doc.at_xpath("//xmlns:entry"))
end

class MockHelpers

  def self.google_reader_starred(sid, response, fake_http)
    fake_response = Spec::Mocks::Mock.new('response', :body=> response)
    fake_http.should_receive(:get) do |url, params|
      url.should =~ Regexp.new("/reader/atom/user/-/state/com.google/starred")
      params['Cookie'].should =~ Regexp.new(sid)
      fake_response
    end.at_least(:once)
  end

  def self.google_reader_login(user, password, sid, fake_http)
    fake_http.should_receive(:use_ssl=)
    fake_response = Spec::Mocks::Mock.new('response', :body=>"SID=#{sid}")
    fake_http.should_receive(:post).with("/accounts/ClientLogin", Megaleech::GoogleReader.to_query_string(
      {'Email' => user,
       'Passwd' => password,
       'service' => 'reader',
       'continue' => Megaleech::GoogleReader::GOOGLE_URL
      })).and_return(fake_response)
  end

end