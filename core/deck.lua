local function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end


function LoadDeck(deck, file)
  if not file_exists(file) then
		print('this deck do not exists')
		return {}
	end

  while not #deck == 0 do
		table.remove(deck[1])
  end

  for card_name in io.lines(file) do
		local card = {
			name = card_name,
			image = love.graphics.newImage('formats/lands/cards/' .. card_name .. '.png' )
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


function DrawCards(deck, hand, num)
	for i = 1, num, 1 do
		hand[#hand + 1] = table.remove(deck, #deck)
	end

	print('drawn ' .. num .. ' card(s) now the player has ' .. #hand .. ' cards')
end
