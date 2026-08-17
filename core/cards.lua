function ParseEffect(entity, effect)
	local delimiter_position = string.find(effect, ':')
	local conditions = string.sub(effect, 1, delimiter_position - 1)
	local resolution = string.sub(effect, delimiter_position + 1, string.len(effect))

	conditions = TrimEdgeChar(conditions, ' ')
	resolution = TrimEdgeChar(resolution, ' ')

	print('[EFFECT] effect: ' .. effect)
	print('[EFFECT] condition: ' .. conditions)
	print('[EFFECT] resolution: ' .. resolution)
	
	local str_array = {}
	for str in conditions:gmatch('[^ %s]+') do
		str_array[#str_array+1] = str
	end

	local event = table.remove(str_array, 1)

	-- parse conditions
	if event == 'INTERRUPT' then

	else
		conditions = {}
		if str_array ~= nil and #str_array >= 1 then
			for i = 1, #str_array, 2 do
				local field = TrimLeadingChar(str_array[i], '_')

				if field == 'card' and str_array[i + 1] == 'this' then
					conditions[field] = entity

				elseif field == 'from' or field == 'to' then
					conditions[field] = str_array[i+1]
				end
			end
		end

		for key, value in pairs(conditions) do
			print(key .. ' - ' .. value)
		end
	end

	ConnectToEvent(event, conditions, resolution)

	print(#str_array)
end


function NewCard(area, card_name, cards_struct)
	local entity_idx = NewEntity()
	local card_struct = cards_struct[card_name]
	local	effects = card_struct.effects

	if not Sprites[card_name] then
		Sprites[card_name] = love.graphics.newImage('formats/lands/cards/' .. card_name .. '.png' )
	end

	Names[entity_idx] = card_name
	Areas[entity_idx] = area
	Types[entity_idx] = 'card'
	Rendering[entity_idx] = Rendering[area] or 'face_up'
	Owner[entity_idx] = GetAreaPlayerFromIdx(area)

	if effects ~= nil then
		for i, effect in ipairs(effects) do
			print('[EFFECT] ' .. i .. ' - ' .. effect)
			ParseEffect(entity_idx, effect)
		end
	end

	if Types[area] == 'deck' then
		Rects[entity_idx] = nil

	else
		Rects[entity_idx] = {
			y = Rects[entity].y + Rects[area].height/2,
			x = Rects[entity].x + i*(Padding[area] + Sprites[Names[card_name]]:getWidth()),
			width			= Sprites[Names[card_name]]:getWidth(),
			height		= Sprites[Names[card_name]]:getHeight(),
			origin_x	= Sprites[Names[card_name]]:getWidth()/2,
			origin_y	= Sprites[Names[card_name]]:getHeight()/2,
		}
	end

	return entity_idx
end


function MoveCard(card_entity, to_entity)
	print(card_entity)
	local from_entity = Areas[card_entity]

	CallEvent('MOVE', card_entity, from_entity, to_entity)

	for index, card in ipairs(Cards[from_entity]) do
		if card == card_entity then
			table.remove(Cards[from_entity], index)
			break
		end
	end

	table.insert(Cards[to_entity], card_entity)
	--print(to_entity)
	Areas[card_entity] = to_entity
	print(Areas[card_entity])

	if Types[from_entity] ~= 'deck' then UpdateArea(from_entity) end
	if Types[to_entity] ~= 'deck' then UpdateArea(to_entity) end
	
	print(Areas[card_entity])
end

