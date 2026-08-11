function UpdateArea(entity)
	for i, card in ipairs(Cards[entity]) do
		if Rects[card] == nil then
			Rects[card] = {}
			Rects[card].width = Sprites[Names[card]]:getWidth()
			Rects[card].heigth = Sprites[Names[card]]:getHeight()
			Rects[card].origin_x = Sprites[Names[card]]:getWidth()/2
			Rects[card].origin_y = Sprites[Names[card]]:getHeight()/2
			Rendering[card] = Rendering[entity]
		end

		Rects[card].y = Rects[entity].y
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

	return num_cards_to_move
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
	Areas[card_entity] = Idx[to_entity]

	if Types[from_entity] ~= 'deck' then UpdateArea(from_entity) end
	if Types[to_entity] ~= 'deck' then UpdateArea(to_entity) end
end

