require 'core.core'
require 'core.config'
require 'core.deck'
require 'core.cards'
require 'core.ecs'
require 'core.events'


-- this struct contains all the general behaviour/data of
-- the entire game or match, like the life points, the turn
-- phases, the number of players...
Game			= {}
Sprites		= {}
State			= require 'core.matchstate'


-- those are the components of most of the game entities
-- if you do not want an entity to render you just do not
-- implement its rect component, do not use the rendering
-- component, that has 'face_up', 'face_down' and 'line'
-- type of values and tell the engine how it should render
-- the card/area
Names			= {}
Rects			= {}
Rendering	= {}
Types			= {}
Areas			= {} -- this contains the index of to the areas the card is in
Cards			= {} -- this contains an arrray of indexes of the cards contained in this area
Padding		= {}
Owner			= {}


-- To get the index of the entity rappresenting the area 
-- the strcture style would be Idx.area[player_id]
-- cards are array of the indexes of the entities constained
-- in that area, the cards in the decks have just no rect
-- component
Idx				= {}

function love.load()
	math.randomseed( os.time() )
	Game.mouse_pressed = false

	-- TODO: implement this type of behaviour
	-- -- configuring the board
	-- if Game.theme == nil then Game.theme = 'default' end
	-- Sprites['back'] = love.graphics.newImage('theme/' .. Game.theme .. '/cards/back.png') or love.graphics.newImage('theme/default/cards/back.png')
	-- Sprites['back_tmb'] = love.graphics.newImage('theme/' .. Game.theme .. '/cards/back_tmb.png') or love.graphics.newImage('theme/default/cards/back_tmb.png')

	Sprites['back'] = love.graphics.newImage('formats/lands/cards/back.png')

	LoadConfig('formats/lands/config.toml')

	State.Match.enter()
	--loading the deck and drawing the initial hand
	for i=1, Game.players do
		local library = Idx.library[i]
		local hand = Idx.hand[i]

		LoadArea(library, 'formats/lands/decks/deck.txt')
		ShuffleArea(library)
		for _=1, 5 do
			MoveCard(Cards[library][#Cards[library]], hand)
		end

		print(tostring(Game.turnNumber).." "..tostring(Game.turnPlayer))
	end

	--TODO: rember to use paper scissor rock who's the first player
	--to do that we could load some special deck and use the function to peek into
	--said deck to chose the card and then compeer

end


function love.update(dt)
	State.update(dt)
end

function love.mousepressed(x, y, button, istouch, pressed)
	State.mousepressed(x, y, button, istouch, pressed)
end

function love.draw()
	State.Match.draw()
end
