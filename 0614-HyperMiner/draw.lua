-- Some drawing routines for the UI

function screenshot()
	local screenCanvas = love.graphics.getCanvas()
	local screenData = screenCanvas:geImageData()
	screenData:encode("screenshot-"..os.date("%Y%m%d%H%M%S")..(".png"))
end

function drawMeter(x, y, width, height, bgColor, fgColor, totalVal, currentVal, direction)
	love.graphics.setColor(unpack(bgColor))
	love.graphics.rectangle("fill", x, y, width, height)
	
	love.graphics.setColor(unpack(fgColor))
	local direction = direction or "right"
	local relSize = currentVal/totalVal
	if direction == "right" then
		love.graphics.rectangle("fill", x+1, y+1, relSize*(width-2), height-2)
	elseif direction == "left" then
		love.graphics.rectangle("fill", x+1+(1-relSize)*(width-2), y+1, relSize*(width-2), height-2)
	elseif direction == "down" then
		love.graphics.rectangle("fill", x+1, y+1, width-2, relSize*(height-2))
	elseif direction == "up" then
		love.graphics.rectangle("fill", x+1, y+1+(1-relSize)*(height-2), width-2, relSize*(height-2))
	end
	
	love.graphics.setColor(255,255,255,255)
end

function drawRadar(rCanvas, centerBody, scale)
	function stencil()
		love.graphics.circle("fill", 0, 0, rCanvas:getWidth()/2, 36)
	end

	rCanvas:clear()
	love.graphics.setCanvas(rCanvas)
	
	love.graphics.push()
	love.graphics.translate(rCanvas:getWidth()/2, rCanvas:getHeight()/2)
	
	love.graphics.setStencil(stencil)
	
	love.graphics.setColor(0,64,0,128)
	love.graphics.circle("fill", 0, 0, rCanvas:getWidth()/2, 36)
	love.graphics.setColor(0,128,0,128)
	for i = 1,8 do
		love.graphics.circle("line",0, 0, i * rCanvas:getWidth()/16, 36)
	end
	for i = 1,16 do
		love.graphics.line(0, 0, rCanvas:getWidth()/2 * math.cos(math.pi * 2 * i/16), rCanvas:getWidth()/2 * math.sin(math.pi * 2 * i/16))
	end
	
	for i,B in ipairs(Physics.bodies) do
		local r, a = math.sqrt(squareBodyDistance(centerBody, B))*scale, bodyDirection(centerBody, B)
		love.graphics.setColor(unpack(radar_color[B.class+1]))
		love.graphics.circle("fill", math.cos(a)*r, math.sin(a)*r, B.class+1, 8)
	end
	
	love.graphics.setColor(255,255,255,192)
	love.graphics.circle("line", 0, 0, rCanvas:getWidth()/2-0.5, 36)
	
	love.graphics.setStencil()
	love.graphics.pop()
	love.graphics.setCanvas()
end