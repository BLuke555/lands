require('core.board')
require('core.deck')


-- Load some default values for our rectangle.
function love.load()
	math.randomseed( os.time() )

	LoadDeck(Player.deck.cards, 'formats/lands/deck.txt')
	ShuffleDeck(Player.deck.cards)
	DrawCards(Player.deck.cards, Player.hand.cards, 5)

	LoadDeck(Opponent.deck.cards, 'formats/lands/deck.txt')
	ShuffleDeck(Opponent.deck.cards)
	DrawCards(Opponent.deck.cards, Opponent.hand.cards, 5)

	back = love.graphics.newImage('formats/lands/cards/back.png')
end


-- Increase the size of the rectangle every frame.
function love.update(dt)
end


-- Draw a coloured rectangle.
function love.draw()
	love.graphics.clear()

	-- Draw battlefields
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle( "line", Player.battlefield.pos.x, Player.battlefield.pos.y, Player.battlefield.width, Player.battlefield.height )
	love.graphics.rectangle( "line", Opponent.battlefield.pos.x, Opponent.battlefield.pos.y, Opponent.battlefield.width, Opponent.battlefield.height )
	love.graphics.rectangle( "line", Player.graveyard.pos.x, Player.graveyard.pos.y, Player.graveyard.width, Player.graveyard.height )
	love.graphics.rectangle( "line", Opponent.graveyard.pos.x, Opponent.graveyard.pos.y, Opponent.graveyard.width, Opponent.graveyard.height )
	love.graphics.rectangle( "line", Player.deck.pos.x, Player.deck.pos.y, Player.deck.width, Player.deck.height )
	love.graphics.rectangle( "line", Opponent.deck.pos.x, Opponent.deck.pos.y, Opponent.deck.width, Opponent.deck.height )

	-- printing opponents cards
	for i = 1, #Opponent.hand.cards, 1 do
		local card = {
			x = Opponent.hand.pos.x + (i-1)*(Opponent.hand.cards[i].image:getWidth() + 5),
			y = Opponent.hand.pos.y
		}

		love.graphics.draw( back, card.x, card.y )
	end

	-- printing player cards
	for i = 1, #Player.hand.cards, 1 do
		local card = {
			x = Player.hand.pos.x + (i-1)*(Player.hand.cards[i].image:getWidth() + 5),
			y = Player.hand.pos.y
		}

		love.graphics.draw( Player.hand.cards[i].image, card.x, card.y )
	end
end
