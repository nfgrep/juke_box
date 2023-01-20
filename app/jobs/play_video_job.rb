require 'open3'

require_relative("../lib/yt_search")
require_relative("../lib/video_player")

class PlayVideoJob < ApplicationJob
  queue_as :default

  def perform(query)
    # Search for video, grab first result
    video = YtSearch.search(query, 1).first

    puts "Playing queued video with mpv..."
    url = video["url"] + "&vq=small"
    puts "URL of video: #{url}"

    pid = Process.spawn(VideoPlayer.cmd(url), pgroup: true)
    puts "PGID of process: #{Process.getpgid(pid)}"
    Rails.cache.write(:pgid, Process.getpgid(pid))
    Process.wait(pid) 
  end
end
