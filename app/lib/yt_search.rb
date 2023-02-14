require('net/http')
require('json')
require('cgi')

module YtSearch
  BASE_URL = "https://www.youtube.com"
  class << self
    def search(query, max_results = nil)
      encoded_query = CGI.escape(query)
      url = "#{BASE_URL}/results?search_query=#{encoded_query}"
      response = Net::HTTP.get(URI(url))
      #while !response.include?("ytInitialData")
      #  response = Net::HTTP.get(URI(url))
      #end
      results = parse_html(response)
      if max_results.nil? && results.length > max_results
        return results[0...max_results]
      else
        return results
      end
    end

    def parse_html(response)
      results = []
      start = response.index("ytInitialData") + "ytInitialData".length + 3
      ending = response.index("};", start)
      json_str = response[start..ending]
      data = JSON.parse(json_str)

      data.dig("contents", "twoColumnSearchResultsRenderer", "primaryContents", "sectionListRenderer", "contents").each do |contents|
        videos = contents.dig("itemSectionRenderer", "contents")
        next if videos.nil?
        videos.each do |video|
          res = {}
          if video.keys.include?("videoRenderer")
          video_data = video.fetch("videoRenderer", {})
          res["id"] = video_data.fetch("videoId", nil)
          res["thumbnails"] = video_data.fetch("thumbnail", {}).fetch("thumbnails", [{}]).map { |thumb| thumb.fetch("url", nil) }
          res["title"] = video_data.fetch("title", {}).fetch("runs", [[{}]])[0].fetch("text", nil)
          res["long_desc"] = video_data.fetch("descriptionSnippet", {}).fetch("runs", [{}])[0].fetch("text", nil)
          res["channel"] = video_data.fetch("longBylineText", {}).fetch("runs", [[{}]])[0].fetch("text", nil)
          res["duration"] = video_data.fetch("lengthText", {}).fetch("simpleText", 0)
          res["views"] = video_data.fetch("viewCountText", {}).fetch("simpleText", 0)
          res["publish_time"] = video_data.fetch("publishedTimeText", {}).fetch("simpleText", 0)
          res["url_suffix"] = video_data.fetch("navigationEndpoint", {}).fetch("commandMetadata", {}).fetch("webCommandMetadata", {}).fetch("url", nil)
          res["url"] = URI.join(BASE_URL, res["url_suffix"]).to_s
          results.push(res)
          end
        end
      end

      results
    end
  end
end
