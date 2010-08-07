class TvTorrents
  require 'mechanize'

  def initialize(entry, torrent_file_download_path)
    @entry = entry
    @torrent_file_download_path = torrent_file_download_path
  end

  def download_torrent_file
    download(@entry.enclosure, @torrent_file_download_path)
  end

  def destination
    "tv/#{show_name}/Season #{show_season}/"
  end

  protected

  def show_name
    @entry.summary[/Show Name:([^;]*)/, 1].strip
  end

  def show_season
    @entry.summary[/Season:([^;]*)/, 1].strip
  end

  def download(source, save_path)
    file = agent.get(source)
    destination = File.join(save_path, file.filename)
    file.save_as destination
    destination
  end
  
  def agent
    @agent ||= Mechanize.new
  end

end