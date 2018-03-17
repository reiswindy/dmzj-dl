require "./dmzj/*"

# TODO: Write documentation for `Dmzj`
module Dmzj
  extend self

  def run(args)
    case command = args.shift?
    when "chapters"
      list_chapters(args)
    when "download"
      download_chapter(args)
    else
      show_help
    end
  end

  private def show_help
    puts <<-HELP_MSG
USAGE: dmzj <command> [arguments]

Commands:
  chapters    list available chapters from a given manhua
  download    download a chapter from given manhua
  help        show this message
HELP_MSG
  end

  private def show_help_chapters
    puts <<-HELP_MSG
USAGE: dmzj chapters <manhua>
HELP_MSG
  end

  private def show_help_download
    puts <<-HELP_MSG
USAGE: dmzj download <manhua> <chapter_index>
HELP_MSG
  end

  private def list_chapters(args)
    if manhua_name = args.shift?
      manhua = Dmzj::Manhua.new(manhua_name)
      manhua.chapters.each { |e| puts e.info }
    else
      show_help_chapters
    end
  end

  private def download_chapter(args)
    if manhua_name = args.shift?
      if chapter = args.shift?
        manhua = Dmzj::Manhua.new(manhua_name)
        manhua.download(chapter)
      else
        show_help_download
      end
    else
      show_help_download
    end
  end
end

Dmzj.run(ARGV)
