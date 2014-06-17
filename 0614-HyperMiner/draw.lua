-- Some drawing routines for the UI

function screenshot()
	local screenCanvas = love.graphics.getCanvas()
	local screenData = screenCanvas:geImageData()
	screenData:encode("screenshot-"..os.date("%Y%m%d%H%M%S")..(".png"))
end

function drawMeter(x, y, long, thick, bgColor, fgColor, totalVal, currentVal, direction)
	local direction = direction or "right"
	local relSize = currentVal/totalVal

	love.graphics.push()
	love.graphics.translate(x, y)
 
	if direction == "right" then
		love.graphics.rotate(0)
	elseif direction == "left" then
		love.graphics.rotate(math.pi/2)
	elseif direction == "down" then
		love.graphics.rotate(math.pi)
	elseif direction == "up" then
		love.graphics.rotate(3*math.pi/2)
	end

	love.graphics.setColor(unpack(bgColor))
	love.graphics.rectangle("fill", -long/2, -thick/2, long, thick)

	love.graphics.setColor(unpack(fgColor))
	love.graphics.rectangle("fill", -long/2 + 1, -thick/2 + 1, (long-2)* relSize, thick-2)
	
	love.graphics.pop()
	love.graphics.setColor(255,255,255,255)
end

function drawSegMeter(x, y, long, thick, bgColor, fgColor, totalVal, currentVal, direction, segments)
	local direction = direction or "right"
	local segments = segments or 10
	local segSize = long/segments

	love.graphics.push()
	love.graphics.translate(x, y)
 
	if direction == "right" then
		love.graphics.rotate(0)
	elseif direction == "left" then
		love.graphics.rotate(math.pi/2)
	elseif direction == "down" then
		love.graphics.rotate(math.pi)
	elseif direction == "up" then
		love.graphics.rotate(3*math.pi/2)
	end

	love.graphics.setColor(unpack(bgColor))
	love.graphics.rectangle("fill", -long/2, -thick/2, long, thick)

	local parts = math.ceil(currentVal / totalVal * segments)
	love.graphics.setColor(unpack(fgColor))
	for i = 0,parts-1 do
		love.graphics.rectangle("fill", -long/2 + segSize*i + 1, -thick/2 + 1, segSize-2, thick-2)
	end

	love.graphics.pop()
	love.graphics.setColor(255,255,255,255)
end

function drawNavWheel(navCanvas, refBody)
	function wheelStencil()
		love.graphics.circle("fill", 0, 0, navCanvas:getWidth()/2, 36)
	end
	
	navCanvas:clear()
	love.graphics.setCanvas(navCanvas)
	
	love.graphics.push()
	love.graphics.translate(navCanvas:getWidth()/2, navCanvas:getHeight()/2)
	
	love.graphics.setStencil(wheelStencil)
	
	local radius = navCanvas:getWidth()/2
	
	love.graphics.setColor(0,64,0,192)
	love.graphics.circle("fill", 0, 0, radius, 36)
	
	love.graphics.setColor(0,128,0,128)
	for i = 0,71 do
		local c,s = math.cos(math.rad(i*5)), math.sin(math.rad(i*5))
		if i % 9 == 0 then
			love.graphics.line(radius * 0.8 * c, radius * 0.8 * s, radius * c, radius * s)
		else
			love.graphics.line(radius * 0.9 * c, radius * 0.9 * s, radius * c, radius * s)
		end
	end
	
	local line_w = love.graphics.getLineWidth()
	love.graphics.setLineWidth(4)
	if refBody.influence_body then
		local D = bodyDirection(refBody, refBody.influence_body)
		love.graphics.setColor(192,192,0,128)
		love.graphics.line(radius * 0.1 * math.cos(D), radius * 0.1 * math.sin(D), radius * 0.6 * math.cos(D), radius * 0.6 * math.sin(D))
	end
	love.graphics.setColor(0,192,0,128)
	love.graphics.line(radius * 0.1 * math.cos(refBody.d), radius * 0.1 * math.sin(refBody.d), radius * 0.6 * math.cos(refBody.d), radius * 0.6 * math.sin(refBody.d))
	love.graphics.setLineWidth(line_w)
	
	love.graphics.setColor(255,255,255,192)
	love.graphics.circle("line", 0, 0, navCanvas:getWidth()/2-0.5, 36)
	
	love.graphics.setStencil()
	
	love.graphics.pop()
	love.graphics.setCanvas()
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
	
	love.graphics.setColor(0,64,0,192)
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
		if r <= (rCanvas:getWidth()/2)^2 then
			love.graphics.setColor(unpack(radar_color[B.class+1]))
			love.graphics.circle("fill", math.cos(a)*r, math.sin(a)*r, math.max(B.class+1, B.size * scale), 32)
		end
	end
	
	love.graphics.setColor(255,255,255,192)
	love.graphics.circle("line", 0, 0, rCanvas:getWidth()/2-0.5, 36)
	
	love.graphics.setStencil()
	love.graphics.pop()
	love.graphics.setCanvas()
end