require 'open3'

class MainController < ApplicationController
  def open_url_page
    render "open"
  end
  
  def open_url_action
    url_to_open = params[:url_to_open]
    #out = `DISPLAY=:0.0 chromium #{url_to_open} &`
    #out, err, stat = Open3.capture3("DISPLAY=:0.0 chromium #{url_to_open} &")
    #new_pid = spawn("DISPLAY=:0.0 chromium #{url_to_open}")
    #Process.detach(new_pid)
    #puts "-------- #{$pid}"#
   
    # Kill the existing yt processes if alraedy exist
    #kill_process_and_children($pid) if $pid
    
    #Open3.popen3("yt /#{url_to_open}, 1") do |stdin, stdout, stderr, wait_thr|
    #  pid = wait_thr.pid # pid of the started process.
    #  exit_status = wait_thr.value # Process::Status object returned.
    #end
    #

    kill_process()
    $pgid = spawn_pgroup_detached("yt /#{url_to_open}, 1")
    puts "PGID: ------- #{$pgid}"

    render "open"
  end

  def close
    kill_process()
    redirect_to action: "open_url_page"
  end

  private

  def kill_process()
    if $pgid
      puts "--- Killing #{$pgid}"
      Process.kill("KILL", $pgid)
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
