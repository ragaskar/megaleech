module Megaleech
  module PTM
    class PTM::Tv < PTM::Base

      def destination
        "tv/#{show_name}/Season #{show_season}/"
      end

      def touch_path
        "tv/#{show_name}"
      end

      protected

      def show_name
        scene_parser.title
      end

      def show_season
        scene_parser.season
      end

      def scene_parser
        @parser ||= SceneTvParser.new(@entry.title)
      end

    end
  end
end