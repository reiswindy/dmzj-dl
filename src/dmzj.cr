require "clim"
require "./dmzj/*"

# TODO: Write documentation for `Dmzj`
module Dmzj
  class App < Clim
    main_command do
      desc("Manhua downloading tool")
      usage("dmzj [command] [arguments]")
      version("Version #{Dmzj::VERSION}")
      run do |options, arguments|
        puts options.help
      end
      sub_command("chapters") do
        desc("List available chapters (chapter index, title and date)")
        usage("dmzj chapters <manhua>")
        run do |options, arguments|
          if manhua_name = arguments.shift?
            manhua = Dmzj::Manhua.new(manhua_name)
            manhua.chapters.each { |chapter| puts chapter.info }        
          else
            puts options.help
          end
        end
      end
      sub_command("download") do
        desc("Download a chapter")
        usage("dmzj download <manhua> <chapter_index>")
        option("-o DESTINATION", "--output-dir=DESTINATION", type: String, desc: "Destination folder", default: "#{__DIR__}")
        run do |options, arguments|
          manhua_name = arguments.shift?
          chapter_index = arguments.shift?
          if manhua_name && chapter_index
            manhua = Dmzj::Manhua.new(manhua_name)
            manhua.download(chapter_index, options.output_dir)
          else
            puts options.help
          end
        end
      end
    end
  end
end

Dmzj::App.start(ARGV)