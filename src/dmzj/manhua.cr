require "file_utils"
require "json"
require "http"
require "uri"
require "modest"
require "duktape/runtime"

class Dmzj::Manhua
  DMZJ      = "https://www.dmzj.com"
  IMG_DMZJ  = "https://images.dmzj.com"
  DMZJ_HOST = "images.dmzj.com"

  record Chapter, number : Int32, name : String, href : String do
    def info
      "#{number} - #{name}"
    end
  end

  @manhua_name : String
  @manhua_html : Myhtml::Parser
  @chapters : Array(Chapter)?
  @information_client : HTTP::Client?
  @download_client : HTTP::Client?

  def initialize(@manhua_name : String)
    @manhua_html = fetch_info_html
  end

  def chapters
    @chapters ||= @manhua_html.css("div.zj_list_con:not(.tab-content-selected) ul.list_con_li a").map_with_index do |node, i|
      Chapter.new(i, node.attributes["title"], node.attributes["href"])
    end
  end

  def download(chapter : String, output_dir : String = __DIR__)
    FileUtils.mkdir_p(output_dir)

    chapter_html = fetch_chapter_html(chapter.to_i)
    chapter_js = chapter_html.css("script:not([src])").first.inner_text

    rt = Duktape::Runtime.new
    pages = rt.eval("#{chapter_js}; pages;").as(String)
    pages = pages.gsub("\r\n", "|")

    pages_url = JSON.parse(pages)["page_url"].as_s.split("|")
    pages_url.each_with_index do |image_url_path, i|
      puts "Fetching page #{i + 1} from #{image_url_path}"

      filename = File.join([output_dir, "#{i + 1}.jpg"])
      File.open(filename, "w") do |file_io|
        fetch_image(image_url_path, chapters[chapter.to_i].href) do |http_io, content_length|
          file_io << http_io.gets_to_end
        end
      end
    end
  end

  def fetch_info_html
    url_path = "/info/#{@manhua_name}.html"

    puts "Fetching information page..."

    body = fetch_html(url_path)
    if body == "漫画不存在"
      raise "Manhua does not exist"
    end
    Myhtml::Parser.new(body)
  end

  def fetch_chapter_html(chapter : Int32)
    url_path = URI.parse(chapters[chapter.to_i].href).path.to_s

    puts "Fetching chapter page..."

    body = fetch_html(url_path)
    Myhtml::Parser.new(body)
  end

  private def fetch_html(url_path)
    information_client.connect_timeout = 10.seconds
    information_client.read_timeout = 10.seconds

    response = information_client.get(url_path)
    if response.status_code != 200
      raise "Failed to fetch html. Status Code: #{response.status_code}"
    end
    response.body
  end

  private def fetch_image(image_url_path, referer)
    headers = HTTP::Headers{
      "Host"    => DMZJ_HOST,
      "Referer" => referer,
    }

    download_client.connect_timeout = 10.seconds
    download_client.read_timeout = 10.seconds
    download_client.get("/#{image_url_path}", headers) do |response|
      if response.status_code != 200
        raise "Failed to fetch image. Status Code: #{response.status_code}"
      end
      if response.headers["Content-Type"] != "image/jpeg"
        raise "Failed to fetch image. Content-Type was #{response.headers["Content-Type"]}"
      end
      yield response.body_io, response.headers["Content-Length"]
    end
  end

  private def information_client
    @information_client ||= HTTP::Client.new(URI.parse(DMZJ))
  end

  private def download_client
    @download_client ||= HTTP::Client.new(URI.parse(IMG_DMZJ))
  end
end
