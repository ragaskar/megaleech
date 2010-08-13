module Megaleech
  module PTM
    class PTM::Movies < PTM::Base

      def destination
        "movies/#{@entry.title}/"
      end

    end
  end
end