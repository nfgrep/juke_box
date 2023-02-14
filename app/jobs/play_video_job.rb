require 'open3'

require_relative("../lib/yt_search")
require_relative("../lib/video_player")

class PlayVideoJob < ApplicationJob
  queue_as :default

  semaphore = Mutex.new

  around_perform do |job, block|
    semaphore.synchronize {
      block.call
    }
  end

  def perform(query)
    puts "Playing queued video..."
    url = YtSearch.search(query, 1).first["url"]
    url = "#{url}&vq=large"

    VideoPlayer.play_blocking(url) do |pgid|
      Rails.cache.write(:queued_pgid, pgid)
    end

    Rails.cache.delete(:queued_pgid) # This might cause issues?
  end
end
