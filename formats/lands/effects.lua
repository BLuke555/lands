return {
	['DRAW'] = function ()
		for _=1, arg[1] do
			local library = Idx.library[Game.current_player]
			local hand = Idx.hand[Game.current_player]

			MoveCard(library[#library], hand)
		end
	end,

	['REVIVE'] = function ()
		for _=1, arg[1] do
			local graveyard = Idx.graveyard[Game.current_player]
			local hand = Idx.hand[Game.current_player]

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
		MoveCard(PeekArea(battlefield, 1), graveyard)
	end,
}
