module Megaleech
  class TorrentsController
    require "digest/md5"
    def initialize
      @last_seen_time = nil
    end

    def run
      puts Time.now
      Megaleech::Torrent.queued.each do |torrent|
        if Megaleech.rtorrent.has_completed_downloading?(torrent.info_hash)
          puts "Now Seeding #{torrent.filename}"
          torrent.update(:status => Megaleech::Torrent::SEEDING)
        end
      end
      starred = Megaleech.google_reader.starred(:limit => 50)
      starred.each { |s| process_entry(s) }
    end

    private

    def process_entry(feed_entry)
      begin
        return if Megaleech::Torrent.filter(:feed_id => feed_entry.id).count > 0
        return unless klass = Megaleech.processor_class_name(feed_entry.source) || Megaleech.processor_class_name(Digest::MD5.hexdigest(feed_entry.source_id)) 
        puts "Adding #{feed_entry.title}"
        processor = klass.new(feed_entry, Megaleech.meta_path)
        torrent_filepath = processor.download_torrent_file
        info_hash = Megaleech.rtorrent.download_torrent(torrent_filepath, File.join(Megaleech.download_directory, processor.destination))
        Megaleech::Torrent.create(:feed_id => feed_entry.id,
                                  :destination => processor.destination,
                                  :status => Megaleech::Torrent::QUEUED,
                                  :info_hash => info_hash,
                                  :filename => Megaleech.rtorrent.filename_for(info_hash))
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