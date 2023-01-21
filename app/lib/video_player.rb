require_relative("yt_search")

module VideoPlayer
    class << self
        # Detaches the process and returns the pgid
        def play_async(url)
            pid = spawn_for_url(url)
            Process.detach(pid)
            Process.getpgid(pid)
        end

        # Takes a block, passes the pgid to the block, then waits for the process
        def play_blocking(url)
            pid = spawn_for_url(url)
            yield Process.getpgid(pid)
            Process.wait(pid)
        end

        # Spawns process to play a video and returns the pid
        # Makes sure the all the processes for the video are in a pgroup
        def spawn_for_url(url)
            Process.spawn(cmd(url), pgroup: true)
        end

        def cmd(url)
            "yt-dlp -o - '#{url}' | mpv --fullscreen -"
        end
    end
end