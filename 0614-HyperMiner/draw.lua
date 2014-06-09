-- Some drawing routines for the UI

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