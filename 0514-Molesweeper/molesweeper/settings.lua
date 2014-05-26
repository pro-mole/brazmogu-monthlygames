-- Global settings and data module
font = {}
sound = {}
bgm = {}
backdrop = {}
spritesheet = {
	grid = love.graphics.newImage("assets/sprite/minefield.png")
}
sprite = {
	dirt = love.graphics.newQuad(0,0,16,16,64,64),
	underdirt = love.graphics.newQuad(16,0,16,16,64,64),
	mole = love.graphics.newQuad(0,16,16,16,64,64),
	mine = love.graphics.newQuad(16,16,16,16,64,64),
	flag = love.graphics.newQuad(32,16,16,16,64,64),
	coppermoss = love.graphics.newQuad(0,32,16,16,64,64),
	ironcap = love.graphics.newQuad(16,32,16,16,64,64),
	goldendrop = love.graphics.newQuad(32,32,16,16,64,64)
}
-- Ranges (to remember)
--- WIDTH: 9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39
--- HEIGHT: 9,11,13,15,17,19,21,23,25,27,29
--- MINES: 4,8,12,15,20,25,30,40
challenge = {
	begins = false,
	level = 1,
	level_settings = {
		{width=9 , height=9, start={5,9}, mines=4, coppermoss='NO', ironcap='NO', goldendrop='NO'}, -- Level 1
		{width=13 , height=13, start={7,13}, mines=8, coppermoss='NO', ironcap='NO', goldendrop='NO'}, -- Level 2
		{width=17 , height=17, start={9,17}, mines=8, coppermoss='NO', ironcap='NO', goldendrop='NO'}, -- Level 3
		{width=21 , height=21, start={11,21}, mines=12, coppermoss='NO', ironcap='NO', goldendrop='NO'}, -- Level 4
		{width=25 , height=25, start={13,25}, mines=12, coppermoss='NO', ironcap='NO', goldendrop='NO'}, -- Level 5
		{width=15 , height=15, start={8,15}, mines=12, coppermoss='YES', ironcap='NO', goldendrop='NO'}, -- Level 6
		{width=21 , height=21, start={11,21}, mines=20, coppermoss='YES', ironcap='NO', goldendrop='NO'}, -- Level 7
		{width=21 , height=15, start={11,15}, mines=20, coppermoss='NO', ironcap='YES', goldendrop='NO'}, -- Level 8
		{width=13 , height=23, start={7,23}, mines=25, coppermoss='NO', ironcap='YES', goldendrop='NO'}, -- Level 9
		{width=15 , height=15, start={8,15}, mines=20, coppermoss='YES', ironcap='YES', goldendrop='NO'}, -- Level 10
		{width=31 , height=25, start={16,25}, mines=25, coppermoss='NO', ironcap='NO', goldendrop='NO'}, -- Level 11
		{width=31 , height=25, start={16,25}, mines=20, coppermoss='YES', ironcap='YES', goldendrop='NO'}, -- Level 12
		{width=31 , height=27, start={16,27}, mines=25, coppermoss='NO', ironcap='NO', goldendrop='YES'}, -- Level 13
		{width=33 , height=27, start={17,27}, mines=30, coppermoss='NO', ironcap='NO', goldendrop='YES'}, -- Level 14
		{width=39 , height=29, start={20,29}, mines=40, coppermoss='NO', ironcap='NO', goldendrop='NO'}, -- Level 15
		{width=33 , height=25, start={17,25}, mines=40, coppermoss='YES', ironcap='NO', goldendrop='YES'}, -- Level 16
		{width=25 , height=27, start={13,27}, mines=40, coppermoss='YES', ironcap='YES', goldendrop='YES'}, -- Level 17
		{width=39 , height=15, start={20,15}, mines=40, coppermoss='YES', ironcap='YES', goldendrop='NO'}, -- Level 18
		{width=11 , height=29, start={6,29}, mines=40, coppermoss='YES', ironcap='YES', goldendrop='NO'}, -- Level 19
		{width=39 , height=29, start={20,29}, mines=40, coppermoss='YES', ironcap='YES', goldendrop='YES'} -- Level 20
	},
	cutscenes = {
	}
}
settings = {
	minefield = {
	width = 11,
	height = 11,
	start = {x = 8, y = 15},
	mines = 8,
	coppermoss = "NO",
	ironcap = "NO",
	goldendrop = "NO"
	},
	video = {
	fullscreen = "NO"
	},
	audio = {
	music = "ON",
	sound = "OFF"
	}
}

function loadSetting(identifier)
	local pointer = settings
	for token in string.gmatch(identifier, "[a-z]+") do
		pointer = pointer[token]
		if pointer == nil then
			return nil
		end
	end

	return pointer
end

function saveSetting(identifier, val)
	local pointer = nil
	local item = nil
	for token in string.gmatch(identifier, "[a-z]+") do
		if item == nil then
			pointer = settings
		else
			pointer = pointer[item]
		end

		item = token
		if pointer == nil then
			return
		end
	end

	pointer[item]=val
end

function load(slot)
	settings.minefield.height = loadSetting("minefield.height")
end

function save(slot)
end