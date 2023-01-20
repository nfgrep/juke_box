require 'open3'

require_relative("../lib/yt_search")
require_relative("../lib/video_player")

class PlayVideoJob < ApplicationJob
  queue_as :default

  # HACK: because we want our jobs to be blocking/synchronous
  before_perform do |job|
    while Rails.cache.exist?(:pgid)
      sleep(10)
    end
  end

  def perform(query)
    # Search for video, grab first result
    video = YtSearch.search(query, 1).first

    puts "Playing queued video with mpv..."
    url = video["url"] #+ "&vq=small"
    puts "URL of video: #{url}"

    #`#{VideoPlayer.cmd(url)}`
    #out, err, stat = Open3.capture3(VideoPlayer.cmd(url), pgroup: true)
    #pid = stat.pid
    pid = Process.spawn(VideoPlayer.cmd(url), pgroup: true)
    #IO.popen(VideoPlayer.cmd(url)) do |io|

    puts "PGID of process: #{Process.getpgid(pid)}"
    Rails.cache.write(:pgid, Process.getpgid(pid))
    Process.wait(pid) 
    puts "-------- Finished playing, deleting pgid cache, releasing lock ---------"
    Rails.cache.delete(:pgid)
    
    #end
    
  end
end
