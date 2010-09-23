module FilesHelper
  SLASH_ESCAPABLE_CHARACTERS = ["(", ")", " "]

  def escape_for_rsync(str)
    SLASH_ESCAPABLE_CHARACTERS.each { |c| str = str.gsub(c, "\\#{c}") }
    str.gsub("'", "\\\\'")
  end

  def output_and_execute(command)
    puts command
    system command
  end
end