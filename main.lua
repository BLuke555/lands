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
		local hand = Board.hand[player_id]

		LoadDeck(library.cards, 'formats/lands/decks/deck.txt')
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

	for area_id,area in pairs(Board) do
		for player_id = 1, Game.players, 1 do

			love.graphics.setColor(1, 1, 1)
			if area[player_id].border == 'line' then
				local area_rect = area[player_id].rect
				love.graphics.rectangle("line", area_rect.x, area_rect.y, area_rect.w, area_rect.h)
			end

			for _, card in pairs(Cards) do
				love.graphics.draw(Sprites[card.name].sprite, card.rect.x, card.rect.y, card.angle, card.rect.scale, card.rect.scale, card.rect.w/2, card.rect.h/2)
			end
		end
	end
end
