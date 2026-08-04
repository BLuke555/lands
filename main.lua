require('core.board')
require('core.deck')
require('core.config')


Game = {}
Board = {}
Cards = {}
Sprites = {}



function love.load()
	math.randomseed(os.time())
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
		local graveyard = Board.graveyard[player_id]
		local hand = Board.hand[player_id]

		LoadDeck(library.cards, 'formats/lands/decks/deck.txt')
		ShuffleDeck(library.cards)
		MoveCards(library, hand, 1, #hand.cards, Game.initial_hand_size)
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

	-- draw boards elements
	for _,value in pairs(Board) do
		for player_id = 1, Game.players, 1 do
			local area = value[player_id]

			love.graphics.setColor(1, 1, 1)
			if area.border == 'line' then
				love.graphics.rectangle("line", area.rect.x, area.rect.y, area.rect.w, area.rect.h)
			end

			if area.type == 'deck' then
				if #area.cards == 0 then
					love.graphics.rectangle("line", area.rect.x, area.rect.y, area.rect.w, area.rect.h)
				elseif area.visibility == 'face_up' then
					local last_card = area.cards[#area.cards]
					love.graphics.draw(Sprites[last_card.name], area.rect.x, area.rect.y, 0, 1, 1, 0, 0)
				elseif area.visibility == 'face_down' then
					love.graphics.draw(Sprites['back'], area.rect.x, area.rect.y, 0, 1, 1, 0, 0)
				end
			end
		end
	end

	-- draw cards in game 
	for idx, card in ipairs(Cards) do
		print(idx)
		card.rect = {
			x = card.area.rect.x + (card.position - 1 + card.area.padding)*(Sprites['back']:getWidth()),
			y = card.area.rect.y + card.area.padding,
		}
		love.graphics.draw(Sprites[card.name], card.rect.x, card.rect.y, 0, 1, 1, 0, 0)
	end
end
