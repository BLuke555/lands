require('core.board')
require('core.deck')
require('core.config')
require('core.matchstate')

Game = {}
Board = {}
Sprites = {}


function love.load()
	math.randomseed( os.time() )
	Game.mouse_pressed = false

	-- configuring the board
	Sprites['back'] = love.graphics.newImage('formats/lands/cards/back.png')
	LoadConfig('./formats/lands/config.toml')
	
	print(Board.hand[1].type)


	--TODO: rember to use paper scissor rock who's the first player
	--to do that we could load some special deck and use the function to peek into
	--said deck to chose the card and then compeer

	matchstate.init()
	
	--loading the deck and drawing the initial hand
	for player_id = 1, Game.players, 1 do
		local library = Board.library[player_id]
		local hand = Board.hand[player_id]

		LoadDeck(library.cards, 'formats/lands/decks/deck.txt')
		ShuffleDeck(library.cards)
		MoveCards(library.cards, hand.cards, 1, #hand.cards, Game.initial_hand_size)
	end

	matchstate.transition("DrawPhase")
end


function love.update(dt)
	if love.mouse.isDown(1) then
		if not Game.mouse_pressed then
			Game.mouse_pressed = true
			
			print(selectedCard)
			if selectedCard > 0 then
				MoveCards(Board['hand'][1].cards, Board['battlefield'][1].cards, selectedCard, #Board['battlefield'][1].cards, 1)
				
				matchstate.transition("DrawPhase")
			end
		end
	else
		Game.mouse_pressed = false
	end
end


function love.draw()
	love.graphics.clear()

	-- Draw areas lines
	love.graphics.setColor(1, 1, 1)
	for area_id, area in pairs(Board) do
		for player_id = 1, Game.players, 1 do
			if not(area[player_id].type == "hand") then
				local rect = area[player_id].rect
				love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h )
			end
		end
	end

	-- printing opponents cards
	for i = 1, #Opponent.hand.cards, 1 do
		local card = {
			x = Opponent.hand.pos.x + (i-1)*(Opponent.hand.cards[i].image:getWidth() + 5),
			y = Opponent.hand.pos.y
		}

		love.graphics.draw( Sprites['back'], card.x, card.y )
	end

	-- printing player cards
	for i = 1, #Board.hand[1].cards, 1 do
		local card = {
			x = Board.hand[1].rect.x + Board.hand[1].cards[i].sprite:getWidth()/2 + (i-1)*(Board.hand[1].cards[i].sprite:getWidth() + 5),
			y = Board.hand[1].rect.y + Board.hand[1].cards[i].sprite:getHeight()/2,
			width = Board.hand[1].cards[i].sprite:getWidth(),
			height = Board.hand[1].cards[i].sprite:getHeight(),
			scale = 1,
		}
		local mouse_pos = {
			x = love.mouse.getX(),
			y = love.mouse.getY()
		}

		if (mouse_pos.x > card.x - card.width/2
				and mouse_pos.x < card.x + card.width/2
				and mouse_pos.y > card.y - card.height/2
				and mouse_pos.y < card.y + card.height/2
			) then
			selectedCard = i -- Selects card if mouse is hovering over it
			card.scale = 1.2
		else
			if selectedCard == i then -- Deselects the card if mouse is no longer hovering over it
				selectedCard = 0
			end
		end

		love.graphics.draw(Board.hand[1].cards[i].sprite, card.x, card.y, 0, card.scale, card.scale, card.width/2, card.height/2)
	end

	for i = 1, #Board.battlefield[1].cards, 1 do
		local card = {
			x = Board.battlefield[1].rect.x + Board.battlefield[1].cards[i].sprite:getWidth()/2 + (i-1)*(Board.battlefield[1].cards[i].sprite:getWidth() + 10) + 10,
			y = Board.battlefield[1].rect.y + Board.battlefield[1].cards[i].sprite:getHeight()/2 + 10,
			width = Board.battlefield[1].cards[i].sprite:getWidth(),
			height = Board.battlefield[1].cards[i].sprite:getHeight(),
			scale = 1,
		}

		love.graphics.draw(Board.battlefield[1].cards[i].sprite, card.x, card.y, 0, card.scale, card.scale, card.width/2, card.height/2)
	end
end
