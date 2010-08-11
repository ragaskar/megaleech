module Megaleech
  class DownloadsController
    include FilesHelper
    def initialize(options = {})
      @port = options[:port]
      @user = options[:user]
      @download_root = options[:destination]
    end

    def run
      torrent = Megaleech::Torrent.next_download
      return unless torrent
      torrent.status = Megaleech::Torrent::DOWNLOADING
      torrent.save
      source = File.join(Megaleech.download_directory, torrent.destination)
      destination = File.join(@download_root, torrent.destination)
      output_and_execute("ssh -p #{@port} #{@user}@localhost \"mkdir -p \\\"#{escape_for_filesystem(destination)}\\\"\"")
      result = output_and_execute("rsync -r --progress --partial --bwlimit 3000 --rsh=\"ssh -p #{@port}\" \"#{source}\" \"#{@user}@localhost:#{escape_for_rsync(destination)}\"")
      if (result)
        torrent.status = Megaleech::Torrent::FINISHED
        torrent.save
      end
    end

  end
end