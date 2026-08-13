return {
	enter = function ()
		print("Draw Phase entered.")
		Game.turnNumber = Game.turnNumber + 1
		if Game.turnPlayer < Game.players then
			Game.turnPlayer = Game.turnPlayer + 1
		else
			Game.turnPlayer = 1
		end
	end,

	update = function ()
		if not(Game.turnNumber == 1 and Game.should_draw_first_turn) then
			print(tostring(Game.turnNumber).." "..tostring(Game.turnPlayer))
			local library = Idx.library[Game.turnPlayer]
			local hand = Idx.hand[Game.turnPlayer]
			MoveCard(Cards[library][#Cards[library]], hand)
		end

		State.transition('MainPhase')
	end,

	exit = function ()
		print("Draw Phase exited.")
	end,
}
