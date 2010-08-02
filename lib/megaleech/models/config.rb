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
      return_path_if_present(config.params['torrents']['download_torrent_file_path'])
    end

    def torrent_download_directory
      return_path_if_present(config.params['torrents']['download_root_path'])
    end

    def rtorrent_socket
      config.params['rtorrent']['socket_path']
    end

    def config
      @config ||= ParseConfig.new(@path)
    end

    private
    def return_path_if_present(path)
      return path if File.exists?(path)
      raise "Unable to find path from config: #{path}"
    end

  end
end