module Megaleech
  require "sequel"
  class Torrent < Sequel::Model
    QUEUED = "queued"
    SEEDING = "seeding"
    DOWNLOADING = "downloading"
    FINISHED = "finished"
    subset(:queued, :status => QUEUED)
    subset(:seeding, :status => SEEDING)
    subset(:downloading, :status => DOWNLOADING)
    subset(:finished, :status => FINISHED)

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