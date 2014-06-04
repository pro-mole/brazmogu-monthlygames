-- Global settings and data module
font = {}
sound = {}
bgm = {
	main = love.audio.newSource("assets/bgm/NOT_SAFE.mp3", "stream")
}
backdrop = {
	dirtwall = love.graphics.newImage("assets/gfx/dirt_bg.png"),
	printer = love.graphics.newImage("assets/gfx/paper_bg.png"),

	mole = love.graphics.newImage("assets/gfx/themole.png"),
	face = love.graphics.newImage("assets/gfx/moleface.png"),
	coppermoss = love.graphics.newImage("assets/gfx/moss.png"),
	ironcap = love.graphics.newImage("assets/gfx/shrooms.png"),
	goldendrop = love.graphics.newImage("assets/gfx/flower.png")
}
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
		{width=9 , height=9, start={5,9}, mines=4, coppermoss='NO', ironcap='NO', goldendrop='NO', -- Level 1
		maxNeighbors = 1, forceNeighbors = 1,
		briefing = [[This is a training mission on controlled conditions. Your objective is to mark all the places where a mine could be buried. To succeed, you must mark all of them correctly.
		
		Remember your basic instructions:
		
		- You can move freely through the ground[Arrows]. Watch out to not set off any mines.

		- You can mark the patches adjacent to your position on 4 directions[AWSD].

		- Check the radar on the top of your HUD. The middle square is your position. The number on each square is the value of magnetic disturbance. It indicates the number of mines adjacent to the position.

		- You cannot know the magnetic disturbance in places you haven't visited, but you will keep all the data you've gathered in the memory.

		- When you're done, send the report back to the control center[ENTER].]], illustration = {{backdrop.mole, 158, 294}}},
		{width=13 , height=13, start={7,13}, mines=8, coppermoss='NO', ironcap='NO', goldendrop='NO', -- Level 2
		maxNeighbors = 4, forceNeighbors = 2,
		briefing = [[Good job! Here is another one. This time you may find the field a little more cluttered than before. Explore carefully and use your brain to deduct where the mine must be.]]},
		{width=17 , height=17, start={9,17}, mines=8, coppermoss='NO', ironcap='NO', goldendrop='NO',  -- Level 3
		maxNeighbors = 8, forceNeighbors = 3,
		briefing = [[This is your last training mission. We have set up a field that may help you develop your deduction skills and by now you may have developed a strategy to finding these mines in an efficient way instead of wandering around.]]},
		{width=21 , height=21, start={11,21}, mines=12, coppermoss='NO', ironcap='NO', goldendrop='NO', -- Level 4
		maxNeighbors = 3, forceNeighbors = 1,
		briefing = [[Congratulations! The tests are over, now it's the real deal. Your job is to lead our troops safely through the enemy lines and their treacherous minefields. From now on things will get tougher, but you can count on the skills you have learned during training help you.
		
		In any case, here are some important reminders:
		
		- There's no need to hurry. It's better to take your time than to ram into a mine thoughtlessly.

		- In doubt, check the spots where you know a mine CANNOT be.

		- It also may help to uncover ground to be sure the spot you suspect is the one where the mine must be.]]},
		{width=25 , height=25, start={13,25}, mines=12, coppermoss='NO', ironcap='NO', goldendrop='NO', -- Level 5
		maxNeighbors = 4, forceNeighbors = 3,
		briefing = [[I hope you're getting used to this, because this will be how things are for a while. There's not much variation among minefields, so at least we can trust your job will be well executed from start to end. Keep on going, and remember: no need to hurry, be as careful as you need to.]]},
		{width=15 , height=15, start={8,15}, mines=12, coppermoss='YES', ironcap='NO', goldendrop='NO', -- Level 6
		maxNeighbors = 4, forceNeighbors = 3,
		briefing = [[No need to panic, but I have bad news. The field science team has detected the presence of mutant plant life denominated "Coppermoss" on the field. It grows all around the mines and is known to cause some magnetic interference. This means the mines you detect now may not be mines after all!
		
		Keep calm, though, and remember these tips:
		
		- Coppermoss is found cluttered around mines, so if you find too many mines together, suspect your senses.

		- Coppermoss needs a humid environment to thrive. Keep an eye on the soil analysis on the top-right of your HUD when making your decision.]], illustration = {{backdrop.coppermoss, 46, 324}}},
		{width=21 , height=21, start={11,21}, mines=20, coppermoss='YES', ironcap='NO', goldendrop='NO', -- Level 7
		maxNeighbors = 6, forceNeighbors = 3,
		briefing = [[That was a close one. There's more coppermoss around, but I am sure you have learned to figure your way about them. You're a smart fellow, we made you that way. Go there and just remember to keep calm and no need to rush your judgment.
		
		It's most important that you can do your job than for the troops to proceed faster.]]},
		{width=21 , height=15, start={11,15}, mines=20, coppermoss='NO', ironcap='YES', goldendrop='NO', -- Level 8
		maxNeighbors = 4, forceNeighbors = 3,
		briefing = [[Good news: the coppermoss has subdued. It seems we won't be seeing much of it now.
		
		Bad news: the science team has found something else. Some kind of metallic fungi called "Ironcap", and it also has an affinity for those mines. Fortunately, we have some intel on their ecology as well:
		
		- Ironcap grows in long rows, so expect to find them in neat lines with the mines somewhere in the middle. Odd buggers.

		- Being a fungus, it's expected that the earth where ironcap grows is very fertile. Again, check the soil when trying to figure out what's mine and what's a shroom.]], illustration = {{backdrop.ironcap, 96, 294}}},
		{width=13 , height=23, start={7,23}, mines=25, coppermoss='NO', ironcap='YES', goldendrop='NO', -- Level 9
		maxNeighbors = 7, forceNeighbors = 3,
		briefing = [[Excellent! The fungus menace keeps on growing around these fields, so be prepared. Just do the same you did last time, and I'm sure you will be A-OK.]]},
		{width=15 , height=15, start={8,15}, mines=20, coppermoss='YES', ironcap='YES', goldendrop='NO', -- Level 10
		maxNeighbors = 8, forceNeighbors = 3,
		briefing = [[We have received reports of high interference in the fields. It's likely that the mines here have been attracting both moss and caps. For the sake of the mission, remember:
		
		- The things grow in recognizable patterns around mines, so not only they are a good warning, but also you can identify them with some good thinking.

		- Also, they alter the soil composition. Use that in your favor to figure out where the mines are hidden.]]},
		{width=31 , height=25, start={16,25}, mines=25, coppermoss='NO', ironcap='NO', goldendrop='NO', -- Level 11
		maxNeighbors = 6, forceNeighbors = 2,
		briefing = [[Mutant vegetation has started to lay off. Good. Not gonna lie, I wasn't very convinced by all the claims of ecologic disaster on the wake of the last war but... well, we're living it right now. If metallic plantlife isn't a sign of the end of times, I'm not sure what is.
		
		I'm sorry, it seems I've lost myself in rambling. Do go on. This should be a breather for you after all those moss and shroom shenanigans.]]},
		{width=31 , height=25, start={16,25}, mines=20, coppermoss='YES', ironcap='YES', goldendrop='NO', -- Level 12
		maxNeighbors = 8, forceNeighbors = 4,
		briefing = [[And here we are again: metal plants are back. Keep your calm and go on. I'm sure you can do it. If we keep on going, things surely can't get worse than this, right?]]},
		{width=31 , height=27, start={16,27}, mines=25, coppermoss='NO', ironcap='NO', goldendrop='YES', -- Level 13
		maxNeighbors = 6, forceNeighbors = 3,
		briefing = [[Well, me and my big mouth again: the science team reports new discoveries. Flowers, this time. These so-called "Goldendrops" are full of metal to the brim, and will turn your magnetic sensor crazy. Not only that, they don't seem to have any attachment to mines, so now things will probably be different.
		
		Here's what we know so far:
		
		- Goldendrops need some space to grow, so they won't be right around a mine or anything like that.

		- Moreover, these flowers aren't just feeding on bare earth, so you can bet the soil will be different nearby. Mind the soil analysis, as usual.]], illustration = {{backdrop.goldendrop, 218, 312}}},
		{width=33 , height=27, start={17,27}, mines=30, coppermoss='NO', ironcap='NO', goldendrop='YES', -- Level 14
		maxNeighbors = 8, forceNeighbors = 3,
		briefing = [[You did it, again, clever! Also, I'm now very happy that we didn't scrap the soil analysis drivers. We thought they'd be useless for our intended purpose, but someone had a hunch, and they were right. Gotta find that person and promote them right away.
		
		Pardon, rambling again. Go forth and do your thing again. And take your time to smell the flowers.]]},
		{width=39 , height=29, start={20,29}, mines=40, coppermoss='NO', ironcap='NO', goldendrop='NO', -- Level 15
		maxNeighbors = 8, forceNeighbors = 6,
		briefing = [[We have another calm on the radars. Of course, there are always mines to flag, but no intrusive plantlife or anything alike. That's a good sign.
		
		Then again, last time it was a bad sign. Can we find more metallic plants? Or even metallic animals?
		
		Okay, just focus on your job. You can do it. You have surely proven so.]]},
		{width=33 , height=25, start={17,25}, mines=40, coppermoss='YES', ironcap='NO', goldendrop='YES', -- Level 16
		maxNeighbors = 9, forceNeighbors = 1,
		briefing = [[No new freak species, at least, but now we have all of them combined. Life does find a way...]],
		illustration = {{backdrop.coppermoss, 318, 108},{backdrop.ironcap, 144, 372},{backdrop.goldendrop, 48, 92}}},
		{width=25 , height=27, start={13,27}, mines=40, coppermoss='YES', ironcap='YES', goldendrop='YES', -- Level 17
		maxNeighbors = 9, forceNeighbors = 1,
		briefing = [[All this vegetation on the minefields strike me odd. It's not like they would be born and thrive in a short time, so by the looks of it the enemy has already abandoned these minefields.
		
		Such is the heritage of petty war, I suppose. But if we succeed in this mission then we'll finally have one very good solution for this problem once and for all.
		
		Well, that is, if you choose to keep on working with us. I suppose they'll give you a choice after all you've been through with us.
		
		At least, you deserve one.]]},
		{width=39 , height=15, start={20,15}, mines=40, coppermoss='YES', ironcap='YES', goldendrop='NO', -- Level 18
		maxNeighbors = 9, forceNeighbors = 1,
		briefing = [[We're very close now. It's important to keep calm, though. Don't rush on your way back home. Keep calm and remember what we know:
		
		- Moss clutters around mines, caps are born in straigh lines. Flowers are scattered.

		- Check the soil and figure the pattern that reveals where the mine is.

		- Keep calm and think. It's more important that your job is done than you get back quicker.
		
		We're counting on you.]]},
		{width=11 , height=29, start={6,29}, mines=40, coppermoss='YES', ironcap='YES', goldendrop='NO', -- Level 19
		maxNeighbors = 9, forceNeighbors = 1,
		briefing = [[I don't even see the use of briefigs by this point. You know all you need to know about your job by now, don't you?
		
		Besides, you have been selected among the best in your litter, and there was all that intensive training. I wouldn't doubt by now you're smarter than a lot of human beings I work with.
		
		Let's not waste time then. Just remind you we send you all the hopes we have here.]]},
		{width=39 , height=29, start={20,29}, mines=40, coppermoss='YES', ironcap='YES', goldendrop='YES', -- Level 20
		maxNeighbors = 9, forceNeighbors = 1,
		briefing = [[This is it. The final stretch. The last test. The last sprint to the end of our mission.
		
		I definitely trust you, now. You've gone this far and you surely can do it. And you bet I'll be buggin the higher-ups for a medal.
		
		After all, you wouldn't be the first animal to be awarded a medal. The first mole, perhaps, but there's always a first right?
		
		Best of luck and, please, make me proud.]]},
		-- FINAL MESSAGE
		{briefing=[[We did it. We actually did it!

		Well, you did it. It was long, challengign way through here but you faced it all and gave your best and you did what you had to do. The mission is over.

		Now you can take a well-deserved rest. If anyone deserves a rest, that's definitely you. And who knows, maybe one day we'll be working together again. Word of your deeds will run fast, and this world is still filled with all sorts of nasty stuff that the wars left behind. Not to mention the stuff that grew in all wrong ways because of how horrible the world is after the war ravaged everything...

		No use worrying now, though. Have a good life. And thanks for all the help.]], illustration = {{backdrop.face, 178, 328}} } 
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
	goldendrop = "NO",
	maxNeighbors = 9,
	forceNeighbors = 1
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
	for token in string.gmatch(identifier, "[a-zA-Z]+") do
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
	for token in string.gmatch(identifier, "[a-zA-Z]+") do
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