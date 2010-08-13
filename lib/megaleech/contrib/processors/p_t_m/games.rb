module Megaleech
  module PTM
    class PTM::Games < PTM::Base

      def destination
        "games/#{@entry.title}/"
      end

    end
  end
end