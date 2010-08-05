module Megaleech
  require "sequel"
  class Torrent < Sequel::Model
    QUEUED = "queued"
    SEEDING = "seeding"
    subset(:queued, :status => QUEUED)
  end
end