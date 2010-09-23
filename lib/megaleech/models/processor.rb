module Megaleech
  class Processor
    require 'mechanize'

    def initialize(entry, torrent_file_download_path)
      @entry = entry
      @torrent_file_download_path = torrent_file_download_path
    end

    def download_torrent_file
      download(@entry.enclosure, @torrent_file_download_path)
    end

    def touch_path
      nil
    end

    def destination
      nil
    end

    protected

    def download(source, save_path)
      file = agent.get(source)
      destination = File.join(save_path, file.filename)
      file.save_as destination
      destination
    end

    def agent
      @agent ||= Mechanize.new
    end


  end
end