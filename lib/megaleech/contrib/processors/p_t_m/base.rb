module Megaleech
  module PTM
    class Base
      require 'mechanize'

      def initialize(entry, torrent_file_download_path)
        @entry = entry
        @torrent_file_download_path = torrent_file_download_path
      end

      def download_torrent_file
        download(@entry.alternate, @torrent_file_download_path)
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
end