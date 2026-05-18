ScreenWidth = love.graphics.getWidth()
ScreenHeight = love.graphics.getHeight()


Padding = 20
HandHeight = 64 + Padding/2

GraveyardWidht = 64
GraveyardHeight = (ScreenHeight/2 - Padding*3 - HandHeight)/2
BattleFieldWidth = ScreenWidth - GraveyardWidht - Padding*3
BattleFieldHeight = ScreenHeight/2 - Padding*2 - HandHeight


Player = {
	battlefield = {
		pos = { x = Padding, y = ScreenHeight/2 + Padding },
		width = BattleFieldWidth,
		height = BattleFieldHeight,
	},

	graveyard = {
		pos = { x = BattleFieldWidth + Padding*2, y = Padding*4 + HandHeight + BattleFieldHeight + GraveyardHeight },
		width = GraveyardWidht,
		height = GraveyardHeight,
	},

	deck = {
		pos = { x = BattleFieldWidth + Padding*2, y = Padding*3 + HandHeight + BattleFieldHeight },
		width = GraveyardWidht,
		height = GraveyardHeight,
	},
}


Opponent = {
	battlefield = {
		pos = { x = Padding, y = Padding + HandHeight},
		width = BattleFieldWidth,
		height = BattleFieldHeight,
	},

	graveyard = {
		pos = { x = BattleFieldWidth + Padding*2, y = Padding + HandHeight },
		width = GraveyardWidht,
		height = GraveyardHeight,
	},

	deck = {
		pos = { x = BattleFieldWidth + Padding*2, y = Padding*2 + HandHeight + GraveyardHeight },
		width = GraveyardWidht,
		height = GraveyardHeight,
	},
}
