return {
	['DRAW'] = function ()
		local library = Idx.library[Game.current_player]
		local hand = Idx.hand[Game.current_player]

		for _=1, arg[1] do
			MoveCard(library[#library], hand)
		end
	end,

	['REVIVE'] = function ()
		local graveyard = Idx.graveyard[Game.current_player]
		local hand = Idx.hand[Game.current_player]

		for _=1, arg[1] do
			MoveCard(graveyard[#graveyard], hand)
		end
	end,

	['DESTROY'] = function ()
		-- TODO: implement GetOpponentIdx()
		local opponent_idx = GetOpponentIdx()
		local battlefield = Idx.battlefield[opponent_idx]
		local graveyard = Idx.graveyard[opponent_idx]

		-- TODO : implement PeekArea()
		-- it display the cards in the area like this mbut face up
		-- [https://mtg-arena.work/wp-content/uploads/2022/12/TREEFOLK-BLACKGREEN-ALCHEMY-MTG-Arena.jpg]
		-- it returns the selected entity
		-- NOTE: it must be specified how many card must been choose
		local chosen_card = PeekArea(battlefield, 1, false)
		MoveCard(chosen_card[1], graveyard)
	end,

	['NEGATE'] = function ()
		 --TODO: implement this
	end
}
