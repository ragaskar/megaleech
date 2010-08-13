module Megaleech
  module PTM
    class PTM::Apps < PTM::Base

      def destination
        "apps/#{@entry.title}/"
      end

    end
  end
end