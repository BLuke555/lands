require('core.board')
require('core.deck')
require('core.config')

local ecs = require('core.ecs')


Game = {}
Names = {}
Rects = {}
Rendering = {}
Types = {}
Sprites = {}


function love.load()
	math.randomseed(os.time())
	Game.mouse_pressed = false

	-- configuring the board
	Sprites['back'] = love.graphics.newImage('formats/lands/cards/back.png')
	-- LoadConfig('./formats/lands/config.toml')
	
	for i = 1, 10, 1 do
		Entities[i] = i
		Rects[i] = {
			x = 100,
			y = 100,
			width = Sprites['back']:getWidth(),
			height = Sprites['back']:getHeight(),
			rotation = 0,
		}
		Rendering[i] = 'face_down'
	end

	--TODO: rember to use paper scissor rock who's the first player
	--to do that we could load some special deck and use the function to peek into
	--said deck to chose the card and then compeer
end

function love.update(dt)
	if love.mouse.isDown(1) then
		if not Game.mouse_pressed then
			Game.mouse_pressed = true

			for _, entity in ipairs(Entities) do
				if IsMouseOver(Rects[entity]) then
					Game.selected_entity = entity
					break
				end
			end
		elseif Game.selected_entity ~= nil then
			Rects[Game.selected_entity].x, Rects[Game.selected_entity].y = love.mouse.getPosition()
		end
	else
		Game.selected_entity = nil
		Game.mouse_pressed = false
	end
end

function love.draw()
	love.graphics.clear()

	for _, entity in ipairs(Entities) do
		if Rects[entity] ~= nil then
			if Rendering[entity] == 'face_up' then
				love.graphics.draw(Sprites[Names[entity]], Rects[entity].x, Rects[entity].y, Rects[entity].rotation, 0, 0)
			elseif Rendering[entity] == 'face_down' then
				love.graphics.draw(Sprites['back'], Rects[entity].x, Rects[entity].y, Rects[entity].rotation, 1, 1, 0, 0)
			elseif Rendering[entity] == 'line' then
				love.graphics.rectangle('line', Rects[entity].x, Rects[entity].y, Rects[entity].width, Rects[entity].height)
			end
		end
	end
end
