-- Help Screen
HelpScreen = {
	pages = {

	}
}

HelpScreen = setmetatable(HelpScreen, Screen)

function HelpScreen:load()
	self.page_num = 1
end

function HelpScreen:update(dt)
end

function HelpScreen:keypressed(k, isrepeat)
	if k == "left" then
		if self.page_num > 1 then
			self.page_num = self.page_num - 1
		end
	elseif k == "right" then
		if self.page_num < #self.pages then
			self.page_num = self.page_num + 1
		end
	end
end

function HelpScreen:draw()
	love.graphics.draw(pages[page_num], 0, 0)

	if self.page_num > 1 then
		-- Draw [Back] button
	end

	if self.page_num < #self.pages then
		-- Draw [Next] button
	end
end

function HelpScreen:quit()
end

return HelpScreen