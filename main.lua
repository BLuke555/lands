require('core.board')
require('core.deck')

local mouse_pressed = false

-- Load some default values for our rectangle.
function love.load()
	math.randomseed( os.time() )

	LoadDeck(Player.deck.cards, 'formats/lands/deck.txt')
	ShuffleDeck(Player.deck.cards)
	MoveCards(Player.deck.cards, Player.hand.cards, 1, #Player.hand.cards, 5)

	print('OPPONENT')
	LoadDeck(Opponent.deck.cards, 'formats/lands/deck.txt')
	print('deck loaded')
	ShuffleDeck(Opponent.deck.cards)
	print('deck shuffled')
	MoveCards(Opponent.deck.cards, Opponent.hand.cards, 1, #Opponent.hand.cards, 5)
	print('drawn 5 cards')

	Back = love.graphics.newImage('formats/lands/cards/back.png')
end


-- Increase the size of the rectangle every frame.
function love.update(dt)
	if love.mouse.isDown(1) then
		if not mouse_pressed then
			mouse_pressed = true

			for i = 1, #Player.hand.cards, 1 do
				print(i)
				local card = {
					x = Player.hand.pos.x + Player.hand.cards[i].image:getWidth()/2 + (i-1)*(Player.hand.cards[i].image:getWidth() + 5),
					y = Player.hand.pos.y + Player.hand.cards[i].image:getHeight()/2,
					width = Player.hand.cards[i].image:getWidth(),
					height = Player.hand.cards[i].image:getHeight(),
					scale = 1,
				}
				local mouse_pos = {
					x = love.mouse.getX(),
					y = love.mouse.getY()
				}

				if (mouse_pos.x > card.x - card.width/2 and mouse_pos.x < card.x + card.height/2 and mouse_pos.y > card.y - card.height/2 and mouse_pos.y < card.y + card.height/2) then
					MoveCards(Player.hand.cards, Player.battlefield.cards, i, #Player.battlefield.cards, 1)
					break
				end
			end
		end
	else
		mouse_pressed = false
	end
end


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

		love.graphics.draw( Back, card.x, card.y )
	end

	-- printing player cards
	for i = 1, #Player.hand.cards, 1 do
		local card = {
			x = Player.hand.pos.x + Player.hand.cards[i].image:getWidth()/2 + (i-1)*(Player.hand.cards[i].image:getWidth() + 5),
			y = Player.hand.pos.y + Player.hand.cards[i].image:getHeight()/2,
			width = Player.hand.cards[i].image:getWidth(),
			height = Player.hand.cards[i].image:getHeight(),
			scale = 1,
		}
		local mouse_pos = {
			x = love.mouse.getX(),
			y = love.mouse.getY()
		}

		if (mouse_pos.x > card.x - card.width/2 and mouse_pos.x < card.x + card.height/2 and mouse_pos.y > card.y - card.height/2 and mouse_pos.y < card.y + card.height/2) then
			card.scale = 1.2
		end

		love.graphics.draw( Player.hand.cards[i].image, card.x, card.y, 0, card.scale, card.scale, card.width/2, card.height/2)
	end

	for i = 1, #Player.battlefield.cards, 1 do
		local card = {
			x = Player.battlefield.pos.x + Player.battlefield.cards[i].image:getWidth()/2 + (i-1)*(Player.battlefield.cards[i].image:getWidth() + 5),
			y = Player.battlefield.pos.y + Player.battlefield.cards[i].image:getHeight()/2 + 10,
			width = Player.battlefield.cards[i].image:getWidth(),
			height = Player.battlefield.cards[i].image:getHeight(),
			scale = 1,
		}

		love.graphics.draw( Player.battlefield.cards[i].image, card.x, card.y, 0, card.scale, card.scale, card.width/2, card.height/2)
	end
end
