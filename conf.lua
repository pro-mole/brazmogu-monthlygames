io.stdout:setvbuf("no")

function love.conf(t)
	t.identity = "ppdz"
	t.version = "0.9.0"

	t.window.title = "Pixel Pop Defense Zone - 0.3 Alpha Version"
	t.window.icon = "assets/icon/ppdz.png"
	
	t.window.height = 640
	t.window.width = 640
end