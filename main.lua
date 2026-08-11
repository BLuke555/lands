require('core.core')
require('core.deck')
require('core.config')

local ecs = require('core.ecs')


-- this struct contains all the general behaviour/data of
-- the entire game or match, like the life points, the turn
-- phases, the number of players...
Game = {}

-- those are the components of most of the game entities
-- if you do not want an entity to render you just do not
-- implement its rect component, do not use the rendering
-- component, that has 'face_up', 'face_down' and 'line'
-- type of values and tell the engine how it should render
-- the card/area
Names			= {}
Rects			= {}
Rendering = {}
Types			= {}
Sprites		= {}
Area			= {}

-- for easier access to specific areas and to give the Cards
-- compoent just to those entities I did this part separated
-- and struct style instead of array style, the id component
-- tell you which areas correspond to which entity
--
-- the strcture style would be Board.area[player_id]
-- cards are array of the indexes of the entities constained
-- in that area, the cards in the decks have just no rect
-- component
Board = {}
Cards = {}
Idx		= {}



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
			origin_x = Sprites['back']:getWidth()/2,
			origin_y = Sprites['back']:getHeight()/2,
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
		local rect = Rects[entity]
		local name = Names[entity]

		if Rects[entity] ~= nil then
			if Rendering[entity] == 'face_up' then
				love.graphics.draw(Sprites[name], rect.x, rect.y, rect.rotation, 1, 1, rect.origin_x, rect.origin_y)
			elseif Rendering[entity] == 'face_down' then
				love.graphics.draw(Sprites['back'], rect.x, rect.y, rect.rotation, 1, 1, rect.origin_x, rect.origin_y)
			elseif Rendering[entity] == 'line' then
				love.graphics.rectangle('line', rect.x, rect.y, rect.width, rect.height)
			end
		end
	end
end
