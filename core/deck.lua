local toml = require 'modules.tinytoml.tinytoml'



local function switch(param, case_table)
    local case = case_table[param]
    if case then return case() end
    local def = case_table['default']
    return def and def() or nil
end


local function file_exists(file)
  local f = love.filesystem.read(file)
  if f then end
  return f ~= nil
end


function ParseConfig(config_file)
	local config = toml.parse(config_file)

	local game = {
		phases = config.turn_phases,
		initial_hand_size = config.initial_hand_size,
		should_draw_first_turn = config.should_draw_first_turn,

		board = {
			players = {
			},
		},
	}

	for player_id = 1, config.players, 1 do
		local player = {
			areas = {}
		}
		local is_hand_at_the_bottom = false
		local max_field_size_x = 0
		local max_field_size_y = 0

		for key, value in pairs(config.area) do
			local cur_area = {
				rect = {
					x = 0,
					y = 0,
					w = 0,
					h = 0,
				},
				cards = {},
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
				end,

				['deck'] = function ()
					-- TODO: add configuration for deck type
				end
			})

			player.areas[key] = cur_area
			-- areas[kwy] = 
		end

		game.board.players[player_id] = player.areas
	end

	return game
end


function LoadDeck(deck, file)
  if not file_exists(file) then
		print('this deck do not exists')
		return {}
	end

  while not #deck == 0 do
		table.remove(deck[1])
  end

  for card_name in love.filesystem.lines(file) do
		local card = {
			name = card_name,
			image = love.graphics.newImage('formats/lands/cards/' .. card_name .. '.png' ),
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


-- FIXME: add a condition so that if you try to move more cards that you have it won't crash
function MoveCards(from, to, old_index, new_index, cards_num)
	if from == to and old_index == new_index then return end
	if from == to and old_index < new_index then new_index = new_index - 1 end

	local cards = {}

	for i = 1, cards_num, 1 do
		cards[i] = table.remove(from, old_index)
	end

	for i = #to, new_index, -1 do
		to[i + cards_num] = to[i]
	end

	for i = 1, #cards, 1 do
		to[new_index + i] = cards[i]
	end
end
