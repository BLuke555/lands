return {
	enter = function ()
	end,

	update = function ()
		if not(Game.turnNumber == 1 and Game.should_draw_first_turn) then
			local library = Idx.library[turnPlayer]
			local hand = Idx.hand[turnPlayer]
			MoveCard(Cards[library][#Cards[library]], hand)
		end

		matchstate.transition('MainPhase')
	end,

	exit = function ()
	end,
}
