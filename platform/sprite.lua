-- Sprite control

Sprite = {
	width = 0,
	height = 0,
	sheet = nil, -- Spritesheet, preloaded
	quads = nil, -- List of quads for each frame
	timer = 0, -- Sprite animation controllers
	fps = 10,
	sprite_index = 0
}
Sprite.__index = Sprite

function Sprite.new(data)
	S = setmetatable({height = data.height, width = data.width}, Sprite)

	if data.sheet then
		S.sheet = data.sheet
		S.quads = nil
		for i,box in ipairs(data.quads) do
			local Q = love.graphics.newQuad(box[1], box[2], S.width, S.height, S.sheet:getWidth(), S.sheet:getHeight())
			table.insert(S.quads, Q)
		end
	end

	S.timer = 0
	S.fps = data.fps or 10
	S.sprite_index = 1

	table.insert(Engine.Sprites, S)
	return S
end

function Sprite:frames()
	return self.quads
end

function Sprite:update(dt)
	self.timer = self.timer + dt
	while self.timer > 1/self.fps do
		self.timer = self.timer - 1/self.fps
		if self.sprite_index >= #self.quads then
			self.sprite_index = 1
		else
			self.sprite_index = self.sprite_index + 1
		end
	end
end

function Sprite:draw(x,y)
	love.graphics.draw(self.sheet, self.quads[self.sprite_index], x, y)
end