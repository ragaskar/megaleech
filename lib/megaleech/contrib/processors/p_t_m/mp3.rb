module Megaleech
  module PTM
    class PTM::Mp3 < PTM::Base

      def destination
        "mp3/#{@entry.title}/"
      end

    end
  end
end