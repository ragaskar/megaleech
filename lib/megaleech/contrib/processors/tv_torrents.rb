module Megaleech
  class TvTorrents < Megaleech::Processor

    def destination
      "tv/#{show_name}/Season #{show_season}/"
    end

    def touch_path
      "tv/#{show_name}"
    end

    protected

    def show_name
      @entry.summary[/Show Name:([^;]*)/, 1].strip
    end

    def show_season
      @entry.summary[/Season:([^;]*)/, 1].strip
    end

  end
end