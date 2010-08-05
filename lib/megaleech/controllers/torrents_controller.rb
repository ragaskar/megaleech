module Megaleech
  class TorrentsController

    def run
      Megaleech::Torrent.queued.each do |torrent|
        if Megaleech.rtorrent.has_completed_downloading?(torrent)
          torrent.update(:status => Megaleech::Torrent::SEEDING)
        end
      end
      starred = Megaleech.google_reader.starred
      starred.each { |s| process_entry(s) }
    end

    private

    def process_entry(feed_entry)
      begin
        return if Megaleech::Torrent.filter(:feed_id => feed_entry.id).count > 0
        return unless klass = Megaleech.processor_class_name(feed_entry.source)
        processor = klass.new(feed_entry, Megaleech.meta_path, Megaleech.download_directory)
        torrent_filepath = processor.download_torrent_file
        info_hash = Megaleech.rtorrent.download_torrent(torrent_filepath, processor.destination)
        Megaleech::Torrent.create(:feed_id => feed_entry.id,
                                  :location => processor.destination,
                                  :status => Megaleech::Torrent::QUEUED,
                                  :info_hash => info_hash)
      rescue StandardError => e
        File.open(Megaleech.log_path, "a") { |f|
          f.write("Failed to process #{feed_entry.title}\n")
          f.write("#{e.message}\n")
          f.write("#{e.backtrace.join("\n")}\n\n")
        }
      end
    end

  end
end