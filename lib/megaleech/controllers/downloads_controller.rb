module Megaleech
  class DownloadsController
    def run
      torrent = Megaleech::Torrent.next_download
      return unless torrent
      source = File.join(Megaleech.download_directory, torrent.destination)
      destination = File.join(Megaleech.client_download_directory, torrent.destination)
      system "ssh -p #{Megaleech.client_port} #{Megaleech.client_user}@localhost \"mkdir -p \\\"#{destination}\\\"\""
      result = system "rsync -r --bwlimit 3000 --partial --rsh=\"ssh -p #{Megaleech.client_port}\" \"#{source}\" \"#{Megaleech.client_user}@localhost:#{destination.gsub(" ", "\\ ")}\""
      if (result)
        torrent.status = Megaleech::Torrent::FINISHED
        torrent.save
      end
    end
  end
end