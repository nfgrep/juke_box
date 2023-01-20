require 'open3'

require_relative("../lib/yt_search")

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

  def stop
    kill_pgroup()
    redirect_to action: "index"
  end

  def set_vol()
    new_vol = params[:volume]
    set_volume(new_vol)
    redirect_to action: "index"
  end

  private

  def search_and_play(query)
    # Search for video, grab first result
    video = YtSearch.search(query, 1).first

    puts "Playing one-shot video with mpv..."
    url = video["url"] + "&vq=small"
    puts "URL of video: #{url}"
    pid = Process.spawn("yt-dlp -o - '#{url}' | mpv -", pgroup: true)
    Rails.cache.write(:pgid, Process.getpgid(pid))
    Process.detach(pid)
  end

  def set_volume(vol)
    pid = Process.spawn("amixer sset Master #{vol}%")
    Process.detach(pid) # Assuming it exits here
  end

  def current_volume()
    out = `amixer sget Master`
    out.split("Left:").last.split("%").first.split("[").last.to_i
  end

  def kill_pgroup()
    pid = Process.fork
    if pid.nil? then
      # in child
      pgid = Rails.cache.read(:pgid)
      if pgid
        Process.kill("KILL", -pgid)
      end
      Process.exit!(true)
    else
      # parent
      Process.detach(pid)
    end
  end
end
