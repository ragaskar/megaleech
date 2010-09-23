module Megaleech
  class BTN < Megaleech::Processor

    def download_torrent_file
      download(@entry.alternate, @torrent_file_download_path)
    end

    def destination
      "tv/#{show_name}/Season #{show_season}/"
    end

    def touch_path
      "tv/#{show_name}"
    end

    protected

    def show_name
      @entry.title.split('-').first.strip
    end

    def show_season
      (@entry.summary[/Season:([^Episode]*)/, 1] || "0").strip
    end

  end
end