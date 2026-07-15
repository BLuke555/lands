require('core.board')
require('core.deck')


Game = {}
Board = {}
Sprites = {}


function love.load()
	math.randomseed( os.time() )
	Game.mouse_pressed = false

	-- configuring the board
	Sprites['back'] = love.graphics.newImage('formats/lands/cards/back.png')
	LoadConfig('./formats/lands/config.toml')


	--TODO: rember to use paper scissor rock who's the first player
	--to do that we could load some special deck and use the function to peek into
	--said deck to chose the card and then compeer

	--loading the deck and drawing the initial hand
	for player_id = 1, Game.players, 1 do
		local library = Board.library[player_id]
		local hand = Board.hand[player_id]

		LoadDeck(library.cards, 'formats/lands/deck.txt')
		ShuffleDeck(library.cards)
		MoveCards(library.cards, hand.cards, 1, #hand.cards, Game.initial_hand_size)
	end
end


function love.update(dt)
	if love.mouse.isDown(1) then
		if not Game.mouse_pressed then
			Game.mouse_pressed = true

			local mouse_pos = { x = love.mouse.getX(), y = love.mouse.getY() }

			for card_id, card in pairs(Board['hand'][1].cards) do
				if (mouse_pos.x > card.x - card.width/2 and
							mouse_pos.x < card.x + card.height/2 and
							mouse_pos.y > card.y - card.height/2 and
							mouse_pos.y < card.y + card.height/2) then
					MoveCards(Board['hand'][1].cards, Board['battlefield'][1].cards, card_id, #Board['battlefield'][1].cards, 1)
					break
				end
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
	for area_id,area in pairs(Board) do
		for player_id = 1, Game.players, 1 do
			print('reandering ' .. area_id .. ' of player ' .. player_id)
			local rect = area[player_id].rect
			love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h )
		end
	end

	-- -- printing opponents cards
	-- for i = 1, #Opponent.hand.cards, 1 do
	-- 	local card = {
	-- 		x = Opponent.hand.pos.x + (i-1)*(Opponent.hand.cards[i].image:getWidth() + 5),
	-- 		y = Opponent.hand.pos.y
	-- 	}

	-- 	love.graphics.draw( Game.sprites['back'], card.x, card.y )
	-- end

	-- -- printing player cards
	-- for i = 1, #Player.hand.cards, 1 do
	-- 	local card = {
	-- 		x = Player.hand.pos.x + Player.hand.cards[i].image:getWidth()/2 + (i-1)*(Player.hand.cards[i].image:getWidth() + 5),
	-- 		y = Player.hand.pos.y + Player.hand.cards[i].image:getHeight()/2,
	-- 		width = Player.hand.cards[i].image:getWidth(),
	-- 		height = Player.hand.cards[i].image:getHeight(),
	-- 		scale = 1,
	-- 	}
	-- 	local mouse_pos = {
	-- 		x = love.mouse.getX(),
	-- 		y = love.mouse.getY()
	-- 	}

	-- 	if (mouse_pos.x > card.x - card.width/2 and mouse_pos.x < card.x + card.height/2 and mouse_pos.y > card.y - card.height/2 and mouse_pos.y < card.y + card.height/2) then
	-- 		card.scale = 1.2
	-- 	end

	-- 	love.graphics.draw( Player.hand.cards[i].image, card.x, card.y, 0, card.scale, card.scale, card.width/2, card.height/2)
	-- end

	-- for i = 1, #Player.battlefield.cards, 1 do
	-- 	local card = {
	-- 		x = Player.battlefield.pos.x + Player.battlefield.cards[i].image:getWidth()/2 + (i-1)*(Player.battlefield.cards[i].image:getWidth() + 5),
	-- 		y = Player.battlefield.pos.y + Player.battlefield.cards[i].image:getHeight()/2 + 10,
	-- 		width = Player.battlefield.cards[i].image:getWidth(),
	-- 		height = Player.battlefield.cards[i].image:getHeight(),
	-- 		scale = 1,
	-- 	}

	-- 	love.graphics.draw( Player.battlefield.cards[i].image, card.x, card.y, 0, card.scale, card.scale, card.width/2, card.height/2)
	-- end
end








