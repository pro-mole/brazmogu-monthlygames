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
		love.graphics.setColor(255,255,255,255)
		love.graphics.circle("fill", 0, 0, navCanvas:getWidth()/2, 36)
	end
	
	navCanvas:clear()
	love.graphics.setCanvas(navCanvas)
	
	love.graphics.push()
	love.graphics.origin()
	love.graphics.translate(navCanvas:getWidth()/2, navCanvas:getHeight()/2)
	
	love.graphics.setStencil(wheelStencil)
	
	local radius = navCanvas:getWidth()/2
	
	love.graphics.setColor(0,32,0,255)
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
	love.graphics.setLineWidth(3)
	if refBody.influence_body then
		local I = refBody.influence_body
		local D = bodyDirection(refBody, I)
		local vm,vd = addVectors(refBody.v, refBody.dir, -I.v, I.dir)
		love.graphics.setColor(192,192,0,128)
		love.graphics.line(radius * 0.8 * math.cos(D), radius * 0.8 * math.sin(D), radius * math.cos(D), radius *  math.sin(D))
		love.graphics.setColor(0,0,192,128)
		love.graphics.line(radius * 0.6 * math.cos(vd), radius * 0.6 * math.sin(vd), radius * 0.8 * math.cos(vd), radius * 0.8 * math.sin(vd))
	end
	love.graphics.setColor(0,192,0,128)
	love.graphics.line(radius * 0.1 * math.cos(refBody.d), radius * 0.1 * math.sin(refBody.d), radius * 0.6 * math.cos(refBody.d), radius * 0.6 * math.sin(refBody.d))
	love.graphics.setLineWidth(line_w)
	
	love.graphics.setColor(255,255,255,255)
	love.graphics.circle("line", 0, 0, navCanvas:getWidth()/2-0.5, 36)
	
	love.graphics.setStencil()
	
	love.graphics.pop()
	love.graphics.setCanvas()
end

function drawRadar(rCanvas, centerBody, scale)
	function stencil()
		love.graphics.setColor(255,255,255,255)
		love.graphics.circle("fill", 0, 0, rCanvas:getWidth()/2, 36)
	end

	rCanvas:clear()
	love.graphics.setCanvas(rCanvas)
	
	love.graphics.push()
	love.graphics.origin()
	love.graphics.translate(rCanvas:getWidth()/2, rCanvas:getHeight()/2)
	
	love.graphics.setStencil(stencil)
	
	love.graphics.setColor(0,32,0,255)
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
			if B == centerBody.influence_body then
				love.graphics.setColor(255,255,255,128)
				love.graphics.circle("fill", math.cos(a)*r, math.sin(a)*r, math.max(B.class+1, B.size * scale)-1, 32)
			end
		end
	end
	
	love.graphics.setColor(255,255,255,255)
	love.graphics.circle("line", 0, 0, rCanvas:getWidth()/2-0.5, 36)
	
	love.graphics.setStencil()
	love.graphics.pop()
	love.graphics.setCanvas()
end

-- Draw the storage crates as a grid of mineral "boxes"
function drawStorage(x, y, probe)
	love.graphics.push()
	love.graphics.translate(x, y)

	local crate_size = 10

	for x = 0,7 do
		for y = 0,(Probe.max_storage_capacity/8)-1 do
			love.graphics.push()
			love.graphics.translate(x * (crate_size+4) , y * (crate_size+4))
			if (x*8 + y) < Probe.storage_capacity then
				love.graphics.setColor(32,64,32,255)
			else
				love.graphics.setColor(64,64,64,255)
			end
			love.graphics.rectangle("fill", 1, 1, crate_size+2, crate_size+2)
			if probe.drill_q > 0 and (x*8 + y) == #probe.storage then
				love.graphics.setColor(32,128,32,255)
				love.graphics.rectangle("fill", 1, 1, crate_size+2, (crate_size+2) * probe.drill_q)
			end
			if probe.storage[x*8 + y + 1] then
				love.graphics.setColor(255,255,255,255)
				love.graphics.printf(probe.storage[x*8 + y + 1], 2, 2, crate_size, "center")
			end
			love.graphics.pop()
		end
	end

	love.graphics.setColor(255,255,255,255)
	love.graphics.pop()
	
	return Probe.max_storage_capacity/8 * (crate_size+4), 8 * (crate_size+4)
end

-- Draw the storage tank as a vertical bar of liquids
function drawTank(x, y, w, h, probe)
	love.graphics.push()
	love.graphics.translate(x, y)

	local tank_height, tank_width = h, w

	love.graphics.setColor(128,128,128,255)
	love.graphics.rectangle("fill", 0, 0, tank_width, tank_height)
	love.graphics.setColor(64,64,64,255)
	love.graphics.rectangle("fill", 0, 0, tank_width, tank_height * (Probe.max_tank_capacity - probe.tank_capacity)/Probe.max_tank_capacity)
	
	love.graphics.setColor(32,32,32,255)
	love.graphics.line(0,0, 0,tank_height)
	love.graphics.line(tank_width,0, tank_width,tank_height)
	love.graphics.line(0,tank_height, tank_width,tank_height)

	love.graphics.setColor(255,255,255,255)
	love.graphics.pop()
	
	return w, h
end

-- Draw the vacuum chamber as a pie chart of gases
function drawVacuum(x, y, probe)
	love.graphics.push()
	love.graphics.translate(x, y)

	love.graphics.setColor(255,255,255,255)
	love.graphics.pop()
end