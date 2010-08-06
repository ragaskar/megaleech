module Megaleech
  class GoogleReader
    require 'net/https'
    require 'net/http'
    require 'uri'
    require 'cgi'
    require 'nokogiri'

    GOOGLE_URL = 'www.google.com'

    def initialize(user, password)
      @user = user
      @password = password
      @auth = nil
    end

    def starred(count = 0)
      results = []
      continuation = ''
      url = URI::HTTP.build({:host => google_url,
                             :path => "/reader/atom/user/-/state/com.google/starred"})
      connection = Net::HTTP.new(url.host, Megaleech.proxy_port || url.port)
      until results.length > count
        header = {"Authorization" => "GoogleLogin auth=#{auth}"}
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

    def google_url
      Megaleech.proxy_url || GOOGLE_URL
    end

    def auth
      return @auth unless @auth.nil?
      data = {'Email' => @user,
              'Passwd' => @password,
              'service' => 'reader',
              "source" => "Megaleech"
      }
      url = URI::HTTPS.build({:host => google_url,
                              :path => "/accounts/ClientLogin"})
      connection = Net::HTTP.new(url.host, Megaleech.proxy_port || url.port)
      connection.use_ssl = true unless Megaleech.proxy_port
      response = connection.post(url.path, GoogleReader.to_query_string(data))
      data = parse_auth_vars(response.body)
      @auth = data['Auth']
    end

    def parse_auth_vars(text)
      text.split("\n").each.inject({}) do |data, pair|
        key_and_value = pair.split("=")
        data[key_and_value[0]] = key_and_value[1]
        data
      end
    end

  end
end