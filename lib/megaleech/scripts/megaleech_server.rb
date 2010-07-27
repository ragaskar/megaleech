require "megaleech"
controller = Megaleech::TorrentsController.new
loop do
  controller.run
  sleep(300)
end

