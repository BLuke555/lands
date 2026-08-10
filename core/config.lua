local toml = require('modules.tinytoml.tinytoml')


local function gameConfig(config)
	print('[CONFIG] setting up global game variables')
	Game.players = config.players
	Game.phases = config.turn_phases
	Game.initial_hand_size = config.initial_hand_size
	Game.should_draw_first_turn = config.should_draw_first_turn

	if config.initial_life_points then
		Game.initial_life_points = {}
		Game.lif_points = {}
		for i = 1, Game.players, 1 do
			Game.initial_life_points[i] = config.initial_life_points
			Game.lif_points = Game.initial_life_points
		end
	end
end


function LoadConfig(config_file)
	print('[CONFIG] loading configuration file')
	local config = toml.parse(config_file)
	print('[CONFIG] configuration file loaded correctly')

	gameConfig(config)

	print('[CONFIG] setting up player(s)')
	-- FIXME: I think we might parse all this thing only once and having all of this repeating for all
	-- palyers dunno.
	-- we could also just store this information once for all the areas but... there is something that
	-- tell me that doing that every frame... I'm just not convinced
	--
	for player_id = 1, config.players or 2, 1 do
		print('[CONFIG] PLAYER ' .. player_id)
		local is_hand_at_the_bottom = false

		local max_field_size_x = love.graphics.getWidth() - 2*config.padding_screen_x
		local max_field_size_y = love.graphics.getHeight()/2 - 2*config.padding_screen_y
		local max_field_ratio_x = 0
		local max_field_ratio_y = 0

		local max_position_x = 0
		local max_position_y = 0
		local area_position = {}

		local areas = {}

		for key, value in pairs(config.area) do
			print('[CONFIG] parsing configuration for palyer ' .. player_id .. ' area ' .. key)
			LastEntity = LastEntity + 1
			local entity_idx = LastEntity

			local cur_area = {}
			Types[entity_idx] = value.type

			Switch(value.type, {
				['hand'] = function ()
					cur_area.padding = value.padding or 5

					-- player_id = 1 is always the current player, even in multiplayer
					if player_id == 1 then
						if Rects[entity_idx] == nil then
							Rects[entity_idx] = {}
						end

						Switch(value.position, {
							['bottom'] = function()
								print('[CONFIG] set hand to bottom')
								is_hand_at_the_bottom = true
								Rects[entity_idx].x = 0
								Rects[entity_idx].y = love.graphics.getHeight() - value.size
								Rects[entity_idx].w = love.graphics.getWidth()
								Rects[entity_idx].h = value.size
							end,
							['side'] = function()
								print('[CONFIG][CONFIG]  set hand to side')
								is_hand_at_the_bottom = false
								Rects[entity_idx].x = love.graphics.getWidth() - value.size
								Rects[entity_idx].y = 0
								Rects[entity_idx].w = value.size
								Rects[entity_idx].h = love.graphics.getHeight()
							end
						})
						cur_area.visibility = value.player_visibility
					else
						cur_area.visibility = value.opponent_visibility
					end
				end,

				['field'] = function ()
						cur_area.idx = entity_idx

						max_position_x = math.max(max_position_x, value.position_x)
						max_position_y = math.max(max_position_y, value.position_y)

						cur_area.width = value.width
						cur_area.height = value.height

						max_field_ratio_x = max_field_ratio_x + value.width
						max_field_ratio_y = max_field_ratio_y + value.height

						if not area_position[value.position_x] then
							area_position[value.position_x] = {}
						end
						area_position[value.position_x][value.position_y] = cur_area

						-- cur_area.padding = value.padding or 5
						Rendering[entity_idx] = value.border or 'none'
				end,

				['deck'] = function ()
					cur_area.idx = entity_idx

						cur_area.width = value.width or Sprites['back']:getWidth()
						cur_area.width = value.height or Sprites['back']:getHeight()

						max_position_x = math.max(max_position_x, value.position_x)
						max_position_y = math.max(max_position_y, value.position_y)


						-- make space for the actual deck if and only if we did not already made space for it
						if not area_position[value.position_x] then
							max_field_size_x = max_field_size_x - cur_area.width - config.padding_x
							area_position[value.position_x] = {}
						end
						area_position[value.position_x][value.position_y] = cur_area

						-- FIXME: this way you subtract the space for the deck even if the deck is not on the same space,
						-- for now it's good but only because we do not have deck above or below an actual area
						-- maybe we can use an array of max field y_position i do not know for now, also there might be a problem
						-- with having more fields one on top of another, dunno. For now let's just make shit done
						--
						-- if not area_position[value.position_x][value.position_y] then
						-- 	max_field_size_y = max_field_size_y - cur_area.rect.h - config.padding_y
						-- end

						Rendering[entity_idx] = value.visibility or 'none'
				end
			})
		end

		-- configuring the actual position of the areas
		local x_position = config.padding_screen_x
		for _, value in pairs(area_position) do
			local y_position = config.padding_screen_y
			local shift_position = 0
			for _, area in pairs(value) do
				print('[CONFIG] configuring palyer ' .. player_id .. ' position X: ' .. x_position ..', Y: ' .. y_position)
				print('[CONFIG] type: ' .. area.type)

				if Rects[entity_idx] then end

				if area.type == 'field' then
					area.rect.w = max_field_size_x / (max_field_ratio_x*area.width)
					area.rect.h = max_field_size_y / (max_field_ratio_y*area.height)
				end

				if player_id == 1 then
					area.rect.x = x_position
					area.rect.y = y_position + love.graphics.getHeight()/2
				elseif player_id == 2 then
					area.rect.x = love.graphics.getWidth() - x_position - area.rect.w
					area.rect.y = love.graphics.getHeight()/2 - y_position - area.rect.h
				end

				y_position = y_position + area.rect.h + config.padding_y
				shift_position = math.max(shift_position, area.rect.w)
			end

			x_position = x_position + shift_position + config.padding_x
		end
	end
end

