return {
	enter = function ()
		Game.turnPlayer = 2 -- 2 (opponent) for test
		Game.turnNumber = 1
		Game.currentState = "DrawPhase" -- name of the current state

		--State.DrawPhase = DrawPhase
		--State.MainPhase = MainPhase

		State.transition(Game.currentState)
	end,

	update = function (dt)
		--State.Match[Game.currentState].update(dt)
		
		--Rects[entity].x = Rects[entity].x + dt --Interpolation (not implemented yet)
	end,

	exit = function ()
	end,

	draw = function ()
		love.graphics.clear()

		for _, entity in ipairs(Entities) do
			local rect = Rects[entity]
			local name = Names[entity]

			if rect ~= nil then
				if Types[entity] == 'deck' and #Cards[entity] == 0 then
					love.graphics.rectangle('line', rect.x, rect.y, rect.width, rect.height)

				elseif Rendering[entity] == 'face_up' then
					if Types[entity] == 'card' then
						love.graphics.draw(Sprites[name], rect.x, rect.y, rect.rotation, 1, 1, rect.origin_x, rect.origin_y)
					end

				elseif Rendering[entity] == 'face_down' and Types[entity] ~= 'hand' then
					love.graphics.draw(Sprites['back'], rect.x, rect.y, rect.rotation, 1, 1, rect.origin_x, rect.origin_y)

				elseif Rendering[entity] == 'line' then
					love.graphics.rectangle('line', rect.x, rect.y, rect.width, rect.height)
				end
			end

		end
	end
}
