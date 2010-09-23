module Megaleech
  module PTM
    class Base < Megaleech::Processor
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