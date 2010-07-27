p File.expand_path(File.dirname(__FILE__) + "/../../lib")
$: << File.expand_path(File.dirname(__FILE__) + "/../../lib")
require "rubygems"
require "bundler"
Bundler.setup
require "megaleech"
controller = Megaleech::TorrentsController.new
loop do
  controller.run
  sleep(300)
end