class Megaleech
  class TorrentsController
    require "sequel"

    def initialize(path = nil)
      @classes = {}
      path ||= File.join(FileUtils.pwd, ".megaleech")
      @megaleech_path = path
    end

    def run
      starred = google_reader.starred
      starred.each { |s| process_entry(s) }
    end

    private

    def entries
      return @entries if @entries
      db = Sequel.sqlite(db_path)
      unless db.table_exists?(:entries)
        db.create_table :entries do
          primary_key :id
          String :feed_id
        end
      end
      @entries = db[:entries]
    end

    def process_entry(feed_entry)
      begin
        return if entries.filter(:feed_id => feed_entry.id).count > 0
        return unless klass = source_processor_class(feed_entry.source)
        processor = klass.new(feed_entry, megaleech_path, config.torrent_download_directory)
        torrent_filepath = processor.download_torrent_file
        rtorrent.download_torrent(torrent_filepath, processor.destination)
        entries.insert(:feed_id => feed_entry.id)
      rescue StandardError => e
        File.open(log_path, "a") { |f|
          f.write("Failed to process #{feed_entry.title}\n")
          f.write("#{e.message}\n")
          f.write("#{e.backtrace.join("\n")}\n\n")
        }
      end
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
      @google_reader ||= Megaleech::GoogleReader.new(config.user, config.password)
    end

    def config
      @config ||= Megaleech::Config.new(config_path)
    end

    def log_path
      File.join(megaleech_path, "megaleech.log")
    end

    def db_path
      File.join(megaleech_path, "megaleech.db")
    end

    def megaleech_path
      @megaleech_path
    end

    def config_path
      File.join(megaleech_path, ".megaleech.rc")
    end

  end
end