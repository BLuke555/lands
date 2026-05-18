require('board')
require('deck')


-- Load some default values for our rectangle.
function love.load()
end

-- Increase the size of the rectangle every frame.
function love.update(dt)
end

-- Draw a coloured rectangle.
function love.draw()
	-- Draw battlefields
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle( "line", Player.battlefield.pos.x, Player.battlefield.pos.y, Player.battlefield.width, Player.battlefield.height )
	love.graphics.rectangle( "line", Opponent.battlefield.pos.x, Opponent.battlefield.pos.y, Opponent.battlefield.width, Opponent.battlefield.height )
	love.graphics.rectangle( "line", Player.graveyard.pos.x, Player.graveyard.pos.y, Player.graveyard.width, Player.graveyard.height )
	love.graphics.rectangle( "line", Opponent.graveyard.pos.x, Opponent.graveyard.pos.y, Opponent.graveyard.width, Opponent.graveyard.height )
	love.graphics.rectangle( "line", Player.deck.pos.x, Player.deck.pos.y, Player.deck.width, Player.deck.height )
	love.graphics.rectangle( "line", Opponent.deck.pos.x, Opponent.deck.pos.y, Opponent.deck.width, Opponent.deck.height )
end
