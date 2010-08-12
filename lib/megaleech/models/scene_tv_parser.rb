class SceneTvParser
  attr_reader :title, :season, :episode
  TV_REGEX = /(.*)\.[s|S]?([0-9]{1,2})[x|X|e|E]([0-9]{1,2})/

  def initialize(str)
    result = str.match(TV_REGEX)
    if (result)
      @title = result[1].gsub(".", " ")
      @season = result[2].to_i
      @episode = result[3].to_i
    else
      @title = str
      @season = 0
      @episode = 0
    end
  end
end

