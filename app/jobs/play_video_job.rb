require 'open3'

require_relative("../lib/yt_search")

class PlayVideoJob < ApplicationJob
  queue_as :default

  def perform(query)
    # Search for video, grab first result
    video = YtSearch.search(query, 1).first

    puts "Playing queued video with mpv..."
    url = video["url"] + "&vq=small"
    puts "URL of video: #{url}"

    pid = Process.spawn("yt-dlp -o - '#{url}' | mpv -", pgroup: true)
    puts "PGID of process: #{Process.getpgid(pid)}"
    Rails.cache.write(:pgid, Process.getpgid(pid))
    Process.wait(pid) 
  end
end
