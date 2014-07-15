require("draw")
require("grid")

game_grid = {}

Players = {
	{
		id = "neutral",
		name = "None",
		color = {64,64,64,255},
		active = false, -- Active if the player is in the game
		AI = true, -- AI true for CPU player
	},
	{
		id = "left",
		name = "Nature",
		color = {0,128,0,255},
		active = true,
		AI = false
	},
	{
		id = "right",
		name = "Industry",
		color = {128,128,128,255},
		active = true,
		AI = false
	},
	{
		id = "up",
		name = "Outsider",
		color = {128,0,128,255},
		active = false,
		AI = false
	},
	{
		id = "down",
		name = "Virus",
		color = {0,128,128,255},
		active = false,
		AI = false
	},
	current = "neutral",
	active = {},
	next = function(self)
		local c = 0
		for i,P in ipairs(self.active) do
			if P == self.current then
				c = i
			end
		end

		if c == #self.active or c == 0 then
			self.current = self.active[1]
		else
			self.current = self.active[c+1]
		end

		return self.current
	end
}
setmetatable(Players, {
	__index = function(t, k)
		if not rawget(t, k) then
			for i,P in ipairs(t) do
				if P.id == k then
					return P
				end
			end
			return nil
		else
			return rawget(t, k)
		end
	end
})

-- Map data stored in tables, later we load the minimap for them into the tables :P
Maps = {
	{"map1.map"},
	current = 1
}

turn = {
	player = "neutral",
	pieces = 0
}

endgame = false

require("screen/main")
require("screen/index")

function love.load()
	love.graphics.setFont(font.standard)

	screens:push(screen_menu)
end

function love.update(dt)
	screens:update(dt)
end

function love.keypressed(key, isrepeat)
	screens:keypressed(key, isrepeat)
	
	if key == "escape" then
		screens:push(screen_quit)
	end
end

function love.mousepressed(x, y, button)
	screens:mousepressed(x, y, button)
end

function love.draw()
	screens:draw()
end