io.stdout:setvbuf("no")

function love.conf(t)
	t.identity = "ppdz"
	t.version = "11.1"

	t.window.title = "Pixel Pop Defense Zone"
	t.window.icon = "assets/icon/ppdz.png"
	
	t.window.height = 640
	t.window.width = 640
end
