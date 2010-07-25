class Megaleech
  class GoogleReader
    require 'net/https'
    require 'net/http'
    require 'uri'
    require 'cgi'
    require 'nokogiri'

    GOOGLE_URL = 'http://www.google.com'
    LOGIN_URL = 'https://www.google.com/accounts/ClientLogin'
    READER_URL = GOOGLE_URL + '/reader'
    STARRED_URL = GOOGLE_URL + '/atom/user/-/state/com.google/starred'

    def initialize(user, password)
      @user = user
      @password = password
      @sid = nil
    end

    def sid
      get_sid if @sid.nil?
      @sid
    end

    def starred(count = 0)
      results = []
      continuation = ''
      url = URI::HTTP.build({:host => "www.google.com",
                             :path => "/reader/atom/user/-/state/com.google/starred"})
      connection = Net::HTTP.new(url.host, url.port)
      until results.length > count
        header = {'Cookie' => "Name=SID;SID=#{sid};Domain=.google.com;Path=/;Expires=160000000000"}
        c_string = continuation.empty? ? '' : "?c=#{continuation}"
        response = connection.get(url.path + c_string, header)
        doc = Nokogiri::XML(response.body)
        if entries = doc.xpath("//xmlns:entry")
          entries.each do |entry|
            results << FeedEntry.new(entry)
          end
          continuation = doc.at_xpath('//gr:continuation').content
          break if continuation.nil? || continuation.strip.empty?
        end
      end
      results
    end

    def self.to_query_string(hash)
      hash = hash || {}
      hash.keys.inject('') do |query_string, key|
        query_string << '&' unless key == hash.keys.first
        query_string << "#{URI.encode(key.to_s)}=#{URI.encode(hash[key])}"
      end
    end

    private

    def get_sid
      data = {'Email' => @user,
              'Passwd' => @password,
              'service' => 'reader',
              'continue' => GoogleReader::GOOGLE_URL
      }
      url = URI::HTTPS.build({:host => "www.google.com",
                              :path => "/accounts/ClientLogin"})
      connection = Net::HTTP.new(url.host, url.port)
      connection.use_ssl = true
      response = connection.post(url.path, GoogleReader.to_query_string(data))
      data = CGI.parse(response.body)

      raise Exception.new(data['Error'].first) if !data['Error'].empty?
      @sid = data['SID'].first
    end
  end
end