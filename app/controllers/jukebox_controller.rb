require 'open3'

class JukeboxController < ApplicationController
  def index
    #render "index"
  end
  
  def play
    query_string = params[:query_string]

    kill_process()
    spawn_pgroup_detached("yt /#{query_string}, 1")

    redirect_to action: "index"
  end

  def stop
    kill_process()
    redirect_to action: "index"
  end

  def vol_up
    new_vol = current_volume() + 5
    set_volume(new_vol)
    redirect_to action: "index"
  end

  def vol_down
    new_vol = current_volume - 5
    set_volume(new_vol)
    redirect_to action: "index"
  end

  private

  def set_volume(vol)
    `amixer sset Master #{vol}%`
  end

  def current_volume()
    out = `amixer sget Master`
    out.split("Left:").last.split("%").first.split("[").last.to_i
  end

  def kill_process()
    pgid = Rails.cache.read(:pgid)
    puts "---- Got from cache: #{pgid}"
    if pgid
      puts "--- Killing #{pgid}"
      Process.kill("KILL", -pgid)
      Rails.cache.delete(:pgid)
    else
      #render plain: "No process to close"
      puts "--- No Process to close"
    end
  end

  def spawn_pgroup_detached(command)
    pid = Process.spawn(command, :pgroup=>true)
    pgid = Process.getpgid(pid)
    Process.detach(pgid)
    puts "---- Writing to cache: #{pgid}"
    Rails.cache.write(:pgid, pgid)
  end

end
