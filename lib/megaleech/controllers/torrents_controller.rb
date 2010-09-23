module Megaleech
  class TorrentsController
    def initialize
      @last_seen_time = nil
    end

    def run
      puts "\n\n"
      puts Time.now
      Megaleech::Torrent.queued.each do |torrent|
        if Megaleech.rtorrent.has_completed_downloading?(torrent.info_hash)
          puts "Now Seeding #{torrent.filename}"
          torrent.update(:status => Megaleech::Torrent::SEEDING)
        end
      end
      begin
        starred = Megaleech.google_reader.starred(:limit => 50)
        starred.each { |s| process_entry(s) }
      rescue
        puts "google connection error"
      end
    end

    private

    def process_entry(feed_entry)
      begin
        return if Megaleech::Torrent.filter(:feed_id => feed_entry.id).count > 0
        klass = Megaleech.processor_class_name(feed_entry.source) || Megaleech.processor_class_name(feed_entry.source_hash)
        unless klass
          puts "No class found for #{feed_entry.title}, source is #{feed_entry.source}, hash is #{feed_entry.source_hash}, source id is #{feed_entry.source_id}"
          return
        end
        puts "Adding #{feed_entry.title}"
        processor = klass.new(feed_entry, Megaleech.meta_path)
        torrent_filepath = processor.download_torrent_file
        info_hash = Megaleech.rtorrent.download_torrent(torrent_filepath, File.join(Megaleech.download_directory, Megaleech::Torrent.samba_safe_path(processor.destination)))

        hash = {:feed_id => feed_entry.id,
                :destination => processor.destination,
                :touch_path => processor.touch_path,
                :status => Megaleech::Torrent::QUEUED,
                :info_hash => info_hash,
                :filename => Megaleech.rtorrent.filename_for(info_hash)}
        Megaleech::Torrent.create(:feed_id => feed_entry.id,
                                  :destination => processor.destination,
                                  :touch_path => processor.touch_path,
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