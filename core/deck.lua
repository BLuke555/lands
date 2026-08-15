-- FIXME: to split between areas types
-- TODO: a NewFieldCard() etc...
function UpdateArea(entity)
	for i, card in ipairs(Cards[entity]) do
		if Rects[card] == nil then
			Rects[card] = {}
			Rects[card].width = Sprites[Names[card]]:getWidth()
			Rects[card].height = Sprites[Names[card]]:getHeight()
			Rects[card].origin_x = Sprites[Names[card]]:getWidth()/2
			Rects[card].origin_y = Sprites[Names[card]]:getHeight()/2
			Rendering[card] = Rendering[entity]
		end

		Rects[card].y = Rects[entity].y + Rects[entity].height/2
		Rects[card].x = Rects[entity].x + i*(Padding[entity] + Sprites[Names[card]]:getWidth())
	end
end


function GetAreaNameFromIdx(entity)
	local name = Names[entity]
	local fields = {}
	local area_name = ''

	for field in name:gmatch('[^_%s]+') do
		fields[#fields+1] = field
	end

	-- this loop serves if the modder happen to use '_' in the field name
	for index, value in ipairs(fields) do
		if index < #fields then
			area_name = area_name .. value
		end
	end

	return area_name
end

function GetAreaPlayerFromIdx(entity)
	local name = Names[entity]
	local fields = {}

	for field in name:gmatch('[^_%s]+') do
		fields[#fields+1] = field
	end

	return fields[#fields]
end

--[[
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
]]

function LoadArea(entity, file)
	local area = Cards[entity]

  while not #area == 0 do
		table.remove(area)
  end

  for card_name in love.filesystem.lines(file) do
		if not Sprites[card_name] then
			Sprites[card_name] = love.graphics.newImage('formats/lands/cards/' .. card_name .. '.png' )
		end

		local entity_idx = NewEntity()
		Names[entity_idx] = card_name
		Areas[entity_idx] = entity
		if Types[entity] == 'deck' then
			Rects[entity_idx] = nil
		else
			-- TODO: implement
		end
		Types[entity_idx] = 'card'

		Rendering[entity_idx] = 'face_up'
		if Rendering[entity] ~= nil and Rendering[entity] == 'face_down' then
			Rendering[entity_idx] = Rendering[entity] or 'face_up'
		end

		table.insert(area, entity_idx)
  end
end


function ShuffleArea(entity)
	local area = Cards[entity]
	if #area <= 1 then return end

	for i = #area, 1, -1 do
		local j = math.random(i)
		area[i], area[j] = area[j], area[i]
	end
end


-- NOTE: DO NOT CALL THIS FUNCTION DIRECTLY, ALWAYS USE MoveCards()
local function move_deck_to_deck(from, to, old_index, new_index, num_cards_to_move)
	local cards_to_move = {}

	for i = 1, num_cards_to_move, 1 do
		cards_to_move[i] = table.remove(from.cards, old_index)
	end

	for i = #to.cards, new_index, -1 do
		to.cards[num_cards_to_move + i] = to.cards[i]
	end

	for i = 1, #cards_to_move, 1 do
		to.cards[new_index + i] = cards_to_move[i]
	end
end

-- NOTE: DO NOT CALL THIS FUNCTION DIRECTLY, ALWAYS USE MoveCards()
local function move_deck_to_play(from, to, old_index, new_index, num_cards_to_move)
	for i = 1, num_cards_to_move, 1 do
		local idx = #Cards + 1
		Cards[idx] = table.remove(from.cards, old_index)
		Cards[idx].area = to
		Cards[idx].position = new_index+i
	end
end

-- NOTE: DO NOT CALL THIS FUNCTION DIRECTLY, ALWAYS USE MoveCards()
local function move_play_to_deck(from, to, old_index, new_index, num_cards_to_move)
	for i = #to.cards, new_index, -1 do
		to.cards[num_cards_to_move + i] = to.cards[i]
	end

	for i = 1, num_cards_to_move, 1 do
		for j = 1, #Cards, 1 do
			if Cards[j].area == from and Cards[j].position == old_index then
				to.cards[new_index + i] = table.remove(Cards, j)
				break
			end
		end
	end
end

-- NOTE: DO NOT CALL THIS FUNCTION DIRECTLY, ALWAYS USE MoveCards()
local function move_play_to_play(from, to, old_index, new_index, num_cards_to_move)
	for _, card in ipairs(Cards) do
		if card.position >= new_index then
			card.position = card.position + num_cards_to_move
		end
	end

	for i = 0, num_cards_to_move - 1, 1 do
		for _,card in ipairs(Cards) do
			if card.area == from and card.position == old_index then
				card.area = to
				card.position = new_index + i
				break
			end
		end
	end
end

function MoveCards(from, to, old_index, new_index, cards_num)
	if from == to and old_index == new_index then return 0 end
	if from == to and old_index < new_index then new_index = new_index - 1 end

	local num_cards_to_move = math.min(cards_num, #from.cards)
	print('moving ' .. num_cards_to_move .. ' cards from ' .. from.type .. ' to ' .. to.type)

	if from.type == 'deck' then
		if to.type == 'deck' then
			move_deck_to_deck(from, to, old_index, new_index, num_cards_to_move)
		else
			move_deck_to_play(from, to, old_index, new_index, num_cards_to_move)
		end
	else
		if to.type == 'deck' then
			move_play_to_deck(from, to, old_index, new_index, num_cards_to_move)
		else
			move_play_to_play(from, to, old_index, new_index, num_cards_to_move)
		end
	end

	return cards_moved
end

function MoveCard(card_entity, to_entity)
	local from_entity = Areas[card_entity]

	for index, card in ipairs(Cards[from_entity]) do
		if card == card_entity then
			table.remove(Cards[from_entity], index)
			break
		end
	end

	table.insert(Cards[to_entity], card_entity)
	Areas[card_entity] = to_entity

	if Types[from_entity] ~= 'deck' then UpdateArea(from_entity) end
	if Types[to_entity] ~= 'deck' then UpdateArea(to_entity) end
end

