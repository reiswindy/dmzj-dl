require "json"
require "http"
require "modest"
require "duktape/runtime"

class Dmzj::Manhua
  DMZJ      = "https://www.dmzj.com/info/%s.html"
  IMG_DMZJ  = "https://images.dmzj.com/%s"
  DMZJ_HOST = "images.dmzj.com"

  record Chapter, number : Int32, name : String, href : String do
    def info
      "#{number} - #{name}"
    end
  end

  @manhua_name : String
  @manhua_html : Myhtml::Parser

  def initialize(@manhua_name : String)
    @manhua_html = fetch_info_html
  end

  def chapters
    @manhua_html.css("div.zj_list_con:not(.tab-content-selected) ul.list_con_li a").map_with_index do |node, i|
      Chapter.new(i, node.attributes["title"], node.attributes["href"])
    end
  end

  def download(chapter : String)
    chapter_html = fetch_chapter_html(chapter.to_i)
    chapter_js = chapter_html.css("script:not([src])").first.inner_text

    rt = Duktape::Runtime.new
    pages = rt.eval("#{chapter_js}; pages;").as(String)
    pages = pages.gsub("\r\n", "|")

    pages_url = JSON.parse(pages)["page_url"].as_s.split("|")

    url = pages_url.first
    pages_url.each_with_index do |url, i|
      puts "Fetching page #{i + 1} from #{url}"
      filename = File.join([__DIR__, "#{i + 1}.jpg"])
      File.write(filename, fetch_image(sprintf(IMG_DMZJ, url), chapters[chapter.to_i].href))
    end
  end

  def fetch_info_html
    url = sprintf(DMZJ, @manhua_name)
    body = fetch_html(url)
    if body == "漫画不存在"
      raise "Manhua does not exist"
    end
    Myhtml::Parser.new(body)
  end

  def fetch_chapter_html(chapter : Int32)
    url = chapters[chapter.to_i].href
    body = fetch_html(url)
    Myhtml::Parser.new(body)
  end

  private def fetch_html(url)
    response = HTTP::Client.get(url)
    if response.status_code != 200
      raise "Failed to fetch html. Status Code: #{response.status_code}"
    end
    response.body
  end

  private def fetch_image(url, referer)
    headers = HTTP::Headers{
      "Host"    => DMZJ_HOST,
      "Referer" => referer,
    }
    response = HTTP::Client.get(url, headers)
    if response.status_code != 200
      raise "Failed to fetch image. Status Code: #{response.status_code}"
    end
    if response.headers["Content-Type"] != "image/jpeg"
      raise "Failed to fetch image. Content-Type was #{response.headers["Content-Type"]}"
    end
    response.body
  end
end

# bpanduro@bcp.com.pe
# nombres completos
# celular
