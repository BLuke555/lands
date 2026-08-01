local toml = require 'modules.tinytoml.tinytoml'



local function switch(param, case_table)
    local case = case_table[param]
    if case then return case() end
    local def = case_table['default']
    return def and def() or nil
end


function LoadConfig(config_file)
	print('loading configuration file')
	local config = toml.parse(config_file)
	print('configuration file loaded correctly')

	print('setting up global game variables')
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

	print('sutting up player(s)')

	-- FIXME: I think we might parse all this thing only once and having all of this repeating for all
	-- palyers dunno.
	-- we could also just store this information once for all the areas but... there is something that
	-- tell me that doing that every frame... I'm just not convinced
	--
	for player_id = 1, config.players or 2, 1 do
		print('player ' .. player_id)
		local is_hand_at_the_bottom = false

		local max_field_size_x = love.graphics.getWidth() - 2*config.padding_screen_x
		local max_field_size_y = love.graphics.getHeight()/2 - 2*config.padding_screen_y
		local max_field_ratio_x = 0
		local max_field_ratio_y = 0

		local max_position_x = 0
		local max_position_y = 0
		local area_position = {}

		for key, value in pairs(config.area) do
			print('parsing configuration for palyer ' .. player_id .. ' area ' .. key)

			local cur_area = {
				cards = {},
				type = value.type,
				rect = { x = 0, y = 0, w = 0, h = 0 },
				visibility = false,
			}

			switch(cur_area.type, {
				['hand'] = function ()
					cur_area.padding = value.padding or 5

					-- player_id = 1 is always the current player, even in multiplayer
					if player_id ~= 1 then
						switch(value.position, {
							['bottom'] = function()
								print('set hand to bottom')
								is_hand_at_the_bottom = true
								cur_area.rect.x = 0
								cur_area.rect.y = love.graphics.getHeight() - value.size
								cur_area.rect.w = love.graphics.getWidth()
								cur_area.rect.h = value.size
							end,
							['side'] = function()
								print('set hand to side')
								is_hand_at_the_bottom = false
								cur_area.rect.x = love.graphics.getWidth() - value.size
								cur_area.rect.y = 0
								cur_area.rect.w = value.size
								cur_area.rect.h = love.graphics.getHeight()
							end
						})
						cur_area.visibility = value.player_visibility
					else
						cur_area.visibility = value.opponent_visibility
					end
				end,

				['field'] = function ()
					-- TODO: add configuration for field type
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

						cur_area.padding = value.padding or 5
						cur_area.border = value.border or 'none'
				end,

				['deck'] = function ()
					-- TODO: add configuration for deck type
						cur_area.rect.w = value.width or Sprites['back']:getWidth()
						cur_area.rect.h = value.height or Sprites['back']:getHeight()

						max_position_x = math.max(max_position_x, value.position_x)
						max_position_y = math.max(max_position_y, value.position_y)


						-- make space for the actual deck if and only if we did not already made space for it
						if not area_position[value.position_x] then
							max_field_size_x = max_field_size_x - cur_area.rect.w - config.padding_x
							area_position[value.position_x] = {}
						end

						-- FIXME: this way you subtract the space for the deck even if the deck is not on the same space,
						-- for now it's good but only because we do not have deck above or below an actual area
						-- maybe we can use an array of max field y_position i do not know for now, also there might be a problem
						-- with having more fields one on top of another, dunno. For now let's just make shit done
						--
						-- if not area_position[value.position_x][value.position_y] then
						-- 	max_field_size_y = max_field_size_y - cur_area.rect.h - config.padding_y
						-- end

						area_position[value.position_x][value.position_y] = cur_area

						cur_area.border = value.border or 'none'
				end
			})

			if not Board[key] then
				Board[key] = {}
			end
			Board[key][player_id] = cur_area
		end

		-- configuring the actual position of the areas
		local x_position = config.padding_screen_x
		for _, value in pairs(area_position) do
			local y_position = config.padding_screen_y
			local shift_position = 0
			for _, area in pairs(value) do
				print("configuring palyer " .. player_id .. " position x: " .. x_position ..", y: " .. y_position)
				print("type: " .. area.type)

				area.rect.x = x_position
				area.rect.y = y_position
				if area.type == 'field' then
					area.rect.w = max_field_size_x / (max_field_ratio_x*area.width)
					area.rect.h = max_field_size_y / (max_field_ratio_y*area.height)
				end
				y_position = y_position + area.rect.h + config.padding_y
				shift_position = math.max(shift_position, area.rect.w)
			end

			x_position = x_position + shift_position + config.padding_x
		end
	end
end


function LoadDeck(deck, file)
  while not #deck == 0 do
		table.remove(deck[1])
  end

  for card_name in love.filesystem.lines(file) do
		Sprites[card_name] = love.graphics.newImage('formats/lands/cards/' .. card_name .. '.png' )
		local card = {
			name = card_name,
			sprite = Sprites[card_name]
		}

		deck[#deck + 1] = card
  end
end


function ShuffleDeck(deck)
	if #deck == 0 or #deck == 1 then return end

	for i = #deck, 1, -1 do
		local j = math.random(i)
		deck[i], deck[j] = deck[j], deck[i]
	end
end


function MoveCards(from, to, old_index, new_index, cards_num)
	if from == to and old_index == new_index then return 0 end
	if from == to and old_index < new_index then new_index = new_index - 1 end

	local cards_moved = math.min(cards_num, #from)
	local cards = {}

	for i = 1, cards_moved, 1 do
		cards[i] = table.remove(from, old_index)
	end

	for i = #to, new_index, -1 do
		to[i + cards_num] = to[i]
	end

	for i = 1, #cards, 1 do
		to[new_index + i] = cards[i]
	end

	return cards_moved
end
