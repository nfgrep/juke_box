require 'open3'

require_relative("../lib/yt_search")
require_relative("../lib/video_player")

class JukeboxController < ApplicationController
  def index
    @volume = current_volume()
  end

  def enqueue()
    query_string = params[:query_string]
    PlayVideoJob.perform_later(query_string) unless query_string.empty?
    redirect_to action: "index"
  end

  def stop()
    kill_all()
    redirect_to action: "index"
  end

  def set_vol()
    new_vol = params[:volume]
    set_volume(new_vol)
    redirect_to action: "index"
  end

  private

  def set_volume(vol)
    pid = Process.spawn("amixer sset #{mixer()} #{vol}%")
    Process.detach(pid) # Assuming it exits here
  end

  def current_volume()
    out = `amixer sget #{mixer()}`
    out.split("Left:").last.split("%").first.split("[").last.to_i
  end

  # TODO: move to a sound/volume module?
  def mixer()
    @current_mixer ||= determine_mixer()
  end

  def determine_mixer()
    # When executed via systemd, we get Headphone, otherwise we usually get Master
    out, err, stat = Open3.capture3("amixer", "sget", "Headphone")
    if stat.success?
      return "Headphone"
    end

    out, err, stat = Open3.capture3("amixer", "sget", "Master")
    if stat.success?
      return "Master"
    end

    abort("Couldn't find either Headphone or Master mixers")
  end

  def kill_all()
    Thread.new do |thr|
      # Kill all processes that were enqueued
      kill_cached_pgroup(:queued_pgid)
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
