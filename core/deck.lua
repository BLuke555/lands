function Switch(param, case_table)
    local case = case_table[param]
    if case then return case() end
    local def = case_table['default']
    return def and def() or nil
end


function LoadDeck(deck, file)
  while not #deck == 0 do
		table.remove(deck[1])
  end

  for card_name in love.filesystem.lines(file) do
		if not Sprites[card_name] then
			Sprites[card_name] = love.graphics.newImage('formats/lands/cards/' .. card_name .. '.png' )
		end

		local card = {
			name = card_name,
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


local function move_deck_to_deck(from, to, old_index, new_index, num_cards_to_move)
	local cards_to_move = {}

	for i = 1, num_cards_to_move, 1 do
		cards_to_move[i] = table.remove(from, old_index)
	end

	for i = #to.cards, new_index, -1 do
		to.cards[num_cards_to_move + i] = to.cards[i]
	end

	for i = 1, #cards_to_move, 1 do
		to.cards[new_index + i] = cards_to_move[i]
	end
end


local function move_deck_to_play(from, to, old_index, new_index, num_cards_to_move)
	for i = 1, num_cards_to_move, 1 do
		Cards[#Cards+1] = table.remove(from, old_index)
		Cards[#Cards+1].area = to
		Cards[#Cards+1].position = new_index+i
	end
end


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

	local num_cards_to_move = math.min(cards_num, #from)

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
