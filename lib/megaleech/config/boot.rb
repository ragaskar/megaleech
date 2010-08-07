module Megaleech
  class << self
    def boot!
      Megaleech.const_set("LIB_PATH", File.expand_path(File.join(File.dirname(__FILE__), "..")))
      Megaleech.const_set("META_PATH", File.expand_path(ENV['MEGALEECH_PATH'] || File.join(ENV['HOME'], ".megaleech")))
      Megaleech.const_set("LOG_PATH", File.join(meta_path, "megaleech.log"))

      config_path = File.join(meta_path, ".megaleech.rc")
      if (!File.exists?(config_path))
        FileUtils.mkdir_p(meta_path)
        FileUtils.cp(File.join(lib_path, "/config/.megaleech.rc"), meta_path)
      end
      @config = Megaleech::Config.new(config_path)
      @classes = {}
      db_init!
    end

    def rtorrent
      @rtorrent ||= new_rtorrent
    end

    def google_reader
      @google_reader ||= new_google_reader
    end

    def download_directory
      @config.download_directory
    end

    def log_path
      Megaleech::LOG_PATH
    end

    def lib_path
      Megaleech::LIB_PATH
    end

    def meta_path
      Megaleech::META_PATH
    end

    def proxy_url
      @config.proxy_url
    end

    def proxy_port
      @config.proxy_port
    end

    def client_port
      @config.client_port
    end

    def client_user
      @config.client_user
    end

    def client_download_directory
      @config.client_download_directory
    end

    def processor_class_name(source)
      @classes[source] ||= if class_name = @config.processor_class_name(source)
        Kernel.const_get(class_name)
      end
    end

    private
    def db_init!
      db = Sequel.connect("sqlite://#{File.join(meta_path, "megaleech.db")}")
      unless db.table_exists?(:torrents)
        db.create_table :torrents do
          primary_key :id
          String :feed_id, :null => false
          String :destination, :text => true, :null => false
          String :status, :null => false, :default => "queued"
          String :info_hash, :null => false
          DateTime :updated_at, :null => false
          DateTime :created_at, :null => false
        end
      end
    end

    def new_rtorrent
      path = @config.rtorrent_socket
      raise "Rtorrent socket not found at #{path}" unless File.exists?(path)
      Megaleech::Rtorrent.new(path)
    end

    def new_google_reader
      Megaleech::GoogleReader.new(@config.user, @config.password)
    end

  end

end







