module Megaleech
  module PTM
    class PTM::Books < PTM::Base

      def destination
        "books/#{@entry.title}/"
      end

    end
  end
end