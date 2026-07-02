local toml = require 'modules.tinytoml.tinytoml'

function PrepareBoard(config_file)
	local config = toml.parse(config_file)

	print(config.format_name)
end

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
