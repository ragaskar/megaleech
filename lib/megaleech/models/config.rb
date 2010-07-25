class Megaleech
  class Config
    def initialize(path)
      @path = path
      @config = nil
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

    def torrent_file_download_directory
      config.params['torrents']['download_torrent_file_path']
    end

    def torrent_download_directory
      config.params['torrents']['download_root_path']
    end

    def rtorrent_socket
      config.params['rtorrent']['socket_path']
    end

    def database_file
      config.params['database']['database']
    end

    def config
      load_config if @config.nil?
      @config
    end

    def load_config
      @config = ParseConfig.new(@path)
    end
    
  end
end