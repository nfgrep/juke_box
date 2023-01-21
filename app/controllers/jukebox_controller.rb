require 'open3'

require_relative("../lib/yt_search")
require_relative("../lib/video_player")

class JukeboxController < ApplicationController
  def index
    @volume = current_volume()
  end
  
  def play
    query_string = params[:query_string]
    search_and_play(query_string)
    redirect_to action: "index"
  end

  def enqueue()
    query_string = params[:query_string]
    PlayVideoJob.perform_later(query_string)
    redirect_to action: "index"
  end

  def kill()
    kill_all()
    redirect_to action: "index"
  end

  def set_vol()
    new_vol = params[:volume]
    set_volume(new_vol)
    redirect_to action: "index"
  end

  private

  def search_and_play(query)
    puts "Playing one-shot video..."
    url = YtSearch.search(query, 1).first["url"]
    pgid = VideoPlayer.play_async(url)
    Rails.cache.write(:oneshot_pgid, pgid)
  end

  def set_volume(vol)
    pid = Process.spawn("amixer sset Master #{vol}%")
    Process.detach(pid) # Assuming it exits here
  end

  def current_volume()
    out = `amixer sget Master`
    out.split("Left:").last.split("%").first.split("[").last.to_i
  end

  def kill_all()
    Thread.new do |thr|
      # Kill all processes that were enqueued
      kill_cached_pgroup(:queued_pgid)

      # Kill all processes that were started one-shot
      kill_cached_pgroup(:oneshot_pgid)
    end
  end

  def kill_cached_pgroup(cache_key)
      pgid = Rails.cache.read(cache_key)
      if pgid
        Process.kill("KILL", -pgid)
        Rails.cache.delete(cache_key)
      end
  end
end
