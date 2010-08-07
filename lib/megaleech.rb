require 'sequel'
require "fileutils"
require 'megaleech/contrib/parseconfig/parseconfig'
require 'megaleech/models/config'
require 'megaleech/config/boot'
Megaleech.boot!

require 'megaleech/contrib/rtorrent-scripts/scgi'
require 'megaleech/contrib/rtorrent-scripts/SCGIxml'


require 'megaleech/models/torrent'
require 'megaleech/models/rtorrent'
require 'megaleech/models/google_reader'
require 'megaleech/models/google_reader_feed_entry'

require 'megaleech/controllers/torrents_controller'
require 'megaleech/controllers/downloads_controller'

require 'megaleech/contrib/processors/tv_torrents.rb'
