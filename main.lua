require('core.core')
require('core.config')
require('core.deck')
require('core.ecs')


-- this struct contains all the general behaviour/data of
-- the entire game or match, like the life points, the turn
-- phases, the number of players...
Game		= {}
Sprites	= {}

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
Areas			= {} -- this contains the index of to the areas the card is in
Cards			= {} -- this contains an arrray of indexes of the cards contained in this area
Padding		= {}


-- To get the index of the entity rappresenting the area 
-- the strcture style would be Idx.area[player_id]
-- cards are array of the indexes of the entities constained
-- in that area, the cards in the decks have just no rect
-- component
Idx		= {}


function love.load()
	math.randomseed(os.time())
	Game.mouse_pressed = false

	-- TODO: implement this type of behaviour
	-- -- configuring the board
	-- if Game.theme == nil then Game.theme = 'default' end
	-- Sprites['back'] = love.graphics.newImage('theme/' .. Game.theme .. '/cards/back.png') or love.graphics.newImage('theme/default/cards/back.png')
	-- Sprites['back_tmb'] = love.graphics.newImage('theme/' .. Game.theme .. '/cards/back_tmb.png') or love.graphics.newImage('theme/default/cards/back_tmb.png')

	Sprites['back'] = love.graphics.newImage('formats/lands/cards/back.png')

	LoadConfig('formats/lands/config.toml')
	for i=1, Game.players do
		local library = Idx.library[i]
		LoadArea(library, 'formats/lands/decks/deck.txt')
		ShuffleArea(library)
		for _=1, 5 do
			MoveCard(Cards[library][#Cards[library]], Idx.hand[i])
		end
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
					-- Game.selected_entity = entity
					print(Names[entity])
					break
				end
			end

		elseif Game.selected_entity ~= nil then
			-- Rects[Game.selected_entity].x, Rects[Game.selected_entity].y = love.mouse.getPosition()
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

		if rect ~= nil then
			if Types[entity] == 'deck' and #Cards[entity] == 0 then
				love.graphics.rectangle('line', rect.x, rect.y, rect.width, rect.height)

			elseif Rendering[entity] == 'face_up' then
				if Types[entity] == 'card' then
					love.graphics.draw(Sprites[name], rect.x, rect.y, rect.rotation, 1, 1, rect.origin_x, rect.origin_y)
				end

			elseif Rendering[entity] == 'face_down' and Types[entity] ~= 'hand' then
				love.graphics.draw(Sprites['back'], rect.x, rect.y, rect.rotation, 1, 1, rect.origin_x, rect.origin_y)

			elseif Rendering[entity] == 'line' then
				love.graphics.rectangle('line', rect.x, rect.y, rect.width, rect.height)
			end
		end

	end
end
