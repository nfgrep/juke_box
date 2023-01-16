require 'open3'

class JukeboxController < ApplicationController
  def index
    #render "index"
  end
  
  def play
    query_string = params[:query_string]

    kill_process()
    $pgid = spawn_pgroup_detached("yt /#{query_string}, 1")
    puts "PGID: ------- #{$pgid}"

    redirect_to action: "index"
  end

  def stop
    kill_process()
    redirect_to action: "index"
  end

  private

  def kill_process()
    if $pgid
      puts "--- Killing #{$pgid}"
      Process.kill("KILL", -$pgid)
      $pgid = nil
    else
      #render plain: "No process to close"
      puts "--- No Process to close"
    end
  end

  def spawn_pgroup_detached(command)
    pid = Process.spawn(command, :pgroup=>true)
    pgid = Process.getpgid(pid)
    Process.detach(pgid)
    return pgid
  end

end
