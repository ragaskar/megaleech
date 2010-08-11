module Megaleech
  require "sequel"
  class Torrent < Sequel::Model
    QUEUED = "queued"
    SEEDING = "seeding"
    DOWNLOADING = "downloading"
    FINISHED = "finished"

    ILLEGAL_CHARACTERS = [":", "?", "!", "#", "~", "*", ";"]

    subset(:queued, :status => QUEUED)
    subset(:seeding, :status => SEEDING)
    subset(:downloading, :status => DOWNLOADING)
    subset(:finished, :status => FINISHED)

    def set_destination_with_safe_escape(str)
      ILLEGAL_CHARACTERS.each { |c| str = str.gsub(c, "") }
      str = str.squeeze(" ").strip
      set_destination_without_safe_escape(str)
    end

    alias_method "set_destination_without_safe_escape", "destination="
    alias_method "destination=", "set_destination_with_safe_escape"

    class << self
      def next_download
        seeding.order(:updated_at).first
      end
    end


    def before_create
      self.created_at ||= Time.now
      super
    end

    def before_save
      self.updated_at = Time.now
      super
    end

  end
end