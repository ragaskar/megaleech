module FilesHelper
  FILESYSTEM_ESCAPABLE_CHARACTERS = ["(", ")"]
  
  def escape_for_filesystem(str)
    FILESYSTEM_ESCAPABLE_CHARACTERS.each { |c| str = str.gsub(c, "\\#{c}") }
    str
  end

  def escape_for_rsync(str)
    escape_for_filesystem(str).gsub(" ", "\\ ")
  end

  def output_and_execute(command)
    puts command
    system command
  end
end