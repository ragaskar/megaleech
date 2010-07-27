class Megaleech
  class TorrentsController
    require "sequel"

    def initialize
      @classes = {}
    end

    def run
      starred = google_reader.starred
      starred.each { |s| process_entry(s) }
    end

    private

    def entries
      return @entries if @entries
      db = Sequel.sqlite(config.database_file)
      unless db.table_exists?(:entries)
        db.create_table :entries do
          primary_key :id
          String :feed_id
        end
      end
      @entries = db[:entries]
    end

    def process_entry(feed_entry)
      return if entries.filter(:feed_id => feed_entry.id).count > 0
      return unless klass = source_processor_class(feed_entry.source)
      processor = klass.new(feed_entry, config.torrent_file_download_directory, config.torrent_download_directory)
      torrent_filepath = processor.download_torrent_file
      rtorrent.download_torrent(torrent_filepath, processor.destination)
      entries.insert(:feed_id => feed_entry.id)
    end

    def source_processor_class(source)
      @classes[source] ||= if class_name = config.processor_class_name(source)
        Kernel.const_get(class_name)
      end
    end

    def rtorrent
      @rtorrent ||= Megaleech::Rtorrent.new(config.rtorrent_socket)
    end

    def google_reader
      p config.user
      p config.password
      @google_reader ||= Megaleech::GoogleReader.new(config.user, config.password)
    end

    def config
      @config ||= Megaleech::Config.new(config_path)
    end

    def config_path
      #ENV['HOME']/.megaleech.rc OR
      File.expand_path("./.megaleech.rc")
#      File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', '.megaleech.rc'))
    end

  end
end