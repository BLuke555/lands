local toml = require('modules.tinytoml.tinytoml')


local max_field_size_x = 0
local max_field_size_y = 0
local max_field_ratio_x = 0
local max_field_ratio_y = 0

local max_position_x = 0
local max_position_y = 0
local area_position = {}


local function configGame(config)
	print('[CONFIG] setting up global game variables')
	Game.players = config.players
	Game.phases = config.turn_phases
	Game.initial_hand_size = config.initial_hand_size
	Game.should_draw_first_turn = config.should_draw_first_turn

	if config.initial_life_points then
		Game.initial_life_points = {}
		Game.life_points = {}
		for i = 1, Game.players, 1 do
			Game.initial_life_points[i] = config.initial_life_points
			Game.life_points = Game.initial_life_points
		end
	end
end


local function configHand(player_id, entity, value)
	local cur_area = {}
	cur_area.idx = entity

	if Rects[entity] == nil then
		Rects[entity] = {}
	end

	-- player_id = 1 is always the current player, even in multiplayer
	if player_id == 1 then

		Switch(value.position, {
			['bottom'] = function()
				print('[CONFIG] set hand to bottom')
				Game.is_hand_at_the_bottom = true
				Rects[entity].x = 0
				Rects[entity].y = love.graphics.getHeight() - value.size
				Rects[entity].width = love.graphics.getWidth()
				Rects[entity].height = value.size
			end,

			['side'] = function()
				print('[CONFIG][CONFIG]  set hand to side')
				Game.is_hand_at_the_bottom = false
				Rects[entity].x = love.graphics.getWidth() - value.size
				Rects[entity].y = 0
				Rects[entity].width = value.size
				Rects[entity].height = love.graphics.getHeight()
			end,

			['default'] = function ()
				Game.is_hand_at_the_bottom = true
				Rects[entity].x = 0
				Rects[entity].y = love.graphics.getHeight() - value.size
				Rects[entity].width = love.graphics.getWidth()
				Rects[entity].height = value.size
			end
		})
		Rendering[entity] = value.player_visibility

	else
		Rects[entity].x = 0
		Rects[entity].y = 0
		Rects[entity].width = love.graphics.getWidth()
		Rects[entity].height = value.size

		Rendering[entity] = value.opponent_visibility
	end

	return cur_area
end


local function configField(entity, value)
	local cur_area = {}
	cur_area.idx = entity

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
	Rendering[entity] = value.border or 'line'
end


local function configDeck(entity, value, config)
	local cur_area = {}
	cur_area.idx = entity

	Rects[entity].width = value.width or Sprites['back']:getWidth()
	Rects[entity].height = value.height or Sprites['back']:getHeight()

	max_position_x = math.max(max_position_x, value.position_x)
	max_position_y = math.max(max_position_y, value.position_y)

	-- make space for the actual deck if and only if we did not already made space for it
	if not area_position[value.position_x] then
		max_field_size_x = max_field_size_x - Rects[entity].width - config.padding_x
		area_position[value.position_x] = {}
	end
	area_position[value.position_x][value.position_y] = cur_area

	Rendering[entity] = value.visibility or 'none'
end


local function configBoard(player_id, config)
	-- preconfiguring variables to loop left to right, top to bottom
	local x_position = config.padding_screen_x
	for _, value in pairs(area_position) do
		local y_position = config.padding_screen_y
		local shift_position = 0

		for _, area in pairs(value) do
			local entity = area.idx

			print('[CONFIG] configuring player ' .. player_id .. ' position X: ' .. x_position ..', Y: ' .. y_position)
			print('[CONFIG] type: ' .. Types[entity])

			if Types[entity] == 'field' then
				Rects[entity].width = max_field_size_x / (max_field_ratio_x*area.width)
				Rects[entity].height = max_field_size_y / (max_field_ratio_y*area.height)
			end

			if player_id == 1 then
				Rects[entity].x = x_position
				Rects[entity].y = y_position + love.graphics.getHeight()/2
			elseif player_id == 2 then
				Rects[entity].x = love.graphics.getWidth() - x_position - Rects[entity].width
				Rects[entity].y = love.graphics.getHeight()/2 - y_position - Rects[entity].height
			end

			y_position = y_position + Rects[entity].height + config.padding_y
			shift_position = math.max(shift_position, Rects[entity].width)
		end

		x_position = x_position + shift_position + config.padding_x
	end
end

function LoadConfig(config_file)
	print('[CONFIG] loading configuration file')
	local config = toml.parse(config_file)
	print('[CONFIG] configuration file loaded correctly')

	configGame(config)

	print('[CONFIG] setting up player(s)')

	-- FIXME: I think we might parse all this thing only once and having all of this repeating for all
	-- palyers dunno.
	-- we could also just store this information once for all the areas but... there is something that
	-- tell me that doing that every frame... I'm just not convinced
	-- 
	-- NOTE: better still, implement an asymmetrical behaviour for the areas
	-- if not we could at least make it so you can write asymmetrical type of configuration 

	for player_id = 1, config.players or 2, 1 do
		print('[CONFIG] PLAYER ' .. player_id)

		max_field_size_x = love.graphics.getWidth() - 2*config.padding_screen_x
		max_field_size_y = love.graphics.getHeight()/2 - 2*config.padding_screen_y
		max_field_ratio_x = 0
		max_field_ratio_y = 0

		max_position_x = 0
		max_position_y = 0
		area_position = {}

		for key, value in pairs(config.area) do
			print('[CONFIG] parsing configuration for player ' .. player_id .. ' area ' .. key)
			local entity = NewEntity()

			if not Idx[key] then Idx[key] = {} end
			Idx[key][player_id] = entity
			Cards[entity] = {}
			Padding[entity] = value.padding or 5
			Types[entity] = value.type
			if not Rects[entity] then Rects[entity] = {} end
			Names[entity] = key .. '_' .. player_id

			Switch(value.type, {
				['hand'] = function ()
					configHand(player_id, entity, value)
				end,

				['field'] = function ()
					configField(entity, value)
				end,

				['deck'] = function ()
					configDeck(entity, value, config)
				end
			})
		end

		configBoard(player_id, config)
	end
end

