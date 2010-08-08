module Megaleech
  class DownloadsController
    def initialize(options = {})
      @port = options[:port]
      @user = options[:user]
      @download_root = options[:destination]
    end
    def run
      torrent = Megaleech::Torrent.next_download
      return unless torrent
      source = File.join(Megaleech.download_directory, torrent.destination)
      destination = File.join(@download_root, torrent.destination)
      system "ssh -p #{@port} #{@user}@localhost \"mkdir -p \\\"#{destination}\\\"\""
      result = system "rsync -r --bwlimit 3000 --partial --rsh=\"ssh -p #{@port}\" \"#{source}\" \"#{@user}@localhost:#{destination.gsub(" ", "\\ ")}\""
      if (result)
        torrent.status = Megaleech::Torrent::FINISHED
        torrent.save
      end
    end
  end
end