local function fileExists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end



function LoadDeck(deck, file)
  if not fileExists(file) then return {} end

  while not #deck == 0 do
		table.remove(deck[0])
  end

  for card in io.lines(file) do
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


function DrawCard(deck)
	return table.remove(deck, #deck)
end
