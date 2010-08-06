module Megaleech
  class Config
    def initialize(path)
      @path = path
      @config = nil
    end

    def proxy_url
      config.params['proxy'] && config.params['proxy']['url']
    end

    def proxy_port
      config.params['proxy'] && config.params['proxy']['port']
    end

    def user
      config.params['google_reader']['user']
    end

    def password
      config.params['google_reader']['password']
    end

    def processor_class_name(source)
      config.params['torrent_processors'][source]
    end

    def download_directory
      return_path_if_present(config.params['torrents']['download_root_path'])
    end

    def rtorrent_socket
      config.params['rtorrent']['socket_path']
    end

    private
    def config
      @config ||= ParseConfig.new(@path)
    end

    def return_path_if_present(path)
      return path if File.exists?(path)
      raise "Unable to find path from config: #{path}"
    end

  end
end