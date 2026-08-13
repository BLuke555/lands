return {
	enter = function ()
	end,

	update = function ()
		if love.mouse.isDown(1) then
			if not Game.mouse_pressed then
				Game.mouse_pressed = true

				for _, entity in ipairs(Entities) do
					if Rects[entity] ~= nil and IsMouseOver(Rects[entity]) then
						MoveCard(entity, Idx.battlefield[1])
						matchstate.transition("DrawPhase")
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
