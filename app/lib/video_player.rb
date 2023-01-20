module VideoPlayer
    class << self
        def cmd(url)
            "yt-dlp -o - '#{url}' | mpv --fullscreen -"
        end
    end
end