local toml = require 'modules.tinytoml.tinytoml'



local function switch(param, case_table)
    local case = case_table[param]
    if case then return case() end
    local def = case_table['default']
    return def and def() or nil
end


function LoadConfig(config_file)
	local config = toml.parse(config_file)

	Game.players = config.players
	Game.phases = config.turn_phases
	Game.initial_hand_size = config.initial_hand_size
	Game.should_draw_first_turn = config.should_draw_first_turn

	if config.initial_life_points then
		Game.initial_life_points = {}
		for i = 1, Game.players, 1 do
			Game.initial_life_points[i] = config.initial_life_points
		end
	end

	for player_id = 1, config.players, 1 do
		local is_hand_at_the_bottom = false

		local max_field_size_x = 0
		local max_field_size_y = 0
		local max_field_ratio_x = 0
		local max_field_ratio_y = 0

		local max_position_x = 0
		local max_position_y = 0
		local area_position = {}

		for key, value in pairs(config.area) do
			local cur_area = {
				cards = {},
				rect = { x = 0, y = 0, w = 0, h = 0 },
				rendering = value.rendering,
				padding = value.padding,
				visibility = false,
			}

			switch(value.type, {
				['hand'] = function ()
					switch(value.position, {
						['bottom'] = function()
							is_hand_at_the_bottom = true
							cur_area.rect.x = 0
							cur_area.rect.y = love.graphics.getHeight() - value.size
							cur_area.rect.w = love.graphics.getWidth()
							cur_area.rect.h = value.size
						end,
						['right'] = function()
							is_hand_at_the_bottom = false
							cur_area.rect.x = love.graphics.getWidth() - value.size
							cur_area.rect.y = 0
							cur_area.rect.w = value.size
							cur_area.rect.h = love.graphics.getHeight()
						end
					})

					-- player_id = 0 is always the current player, even in multiplayer
					if player_id ~= 0 then
						cur_area.visibility = value.player_visibility
					else
						cur_area.visibility = value.opponent_visibility
					end
				end,

				['field'] = function ()
					-- TODO: add configuration for field type
						max_position_x = math.max(max_position_x, value.position_x)
						max_position_y = math.max(max_position_y, value.position_y)

						max_field_ratio_x = max_field_ratio_x + value.ratio
						max_field_ratio_y = max_field_ratio_y + value.ratio

						if not area_position[value.position_x] then
							area_position[value.position_x] = {}
						end
						area_position[value.position_x][value.position_y] = cur_area
				end,

				['deck'] = function ()
					-- TODO: add configuration for deck type
						cur_area.rect.w, cur_area.rect.h = Sprites['back']:getDimensions()
						if value.width then
							cur_area.rect.w = value.width
						end
						if value.height then
							cur_area.rect.h = value.height
						end
						max_field_size_x = max_field_size_x - cur_area.rect.w
						max_field_size_y = max_field_size_y - cur_area.rect.h

						max_position_x = math.max(max_position_x, value.position_x)
						max_position_y = math.max(max_position_y, value.position_y)

						if not area_position[value.position_x] then
							area_position[value.position_x] = {}
						end
						area_position[value.position_x][value.position_y] = cur_area
				end
			})

			if not Board[key] then
				Board[key] = {}
			end
			Board[key][player_id] = cur_area
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
