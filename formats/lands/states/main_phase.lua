return {
	enter = function ()
	end,

	update = function ()
		if Game.turn_player == 2 then -- test: opponent passes the turn
			print("Opponent passed the turn.")
			State.transition("DrawPhase")
		end
		
		if love.mouse.isDown(1) then
			if not Game.mouse_pressed then
				Game.mouse_pressed = true

				for _, entity in ipairs(Entities) do					
					if Rects[entity] ~= nil and Types[entity] == "card" and IsMouseOver(Rects[entity]) then
						print(Types[entity])
						print(Areas[entity])
						MoveCard(entity, Idx.battlefield[1])
						State.transition("DrawPhase")
						break
					end
				end
			end
		else
			Game.selected_entity = nil
			Game.mouse_pressed = false
		end
	end,

	exit = function ()
	end
}
