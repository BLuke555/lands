local toml = require 'modules.tinytoml.tinytoml'


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


function LoadArea(entity, file)
	local area = Cards[entity]

  while not #area == 0 do
		table.remove(area)
  end

	local cards_struct = toml.parse('formats/lands/cards.toml')

  for card_name in love.filesystem.lines(file) do
		if not Sprites[card_name] then
			Sprites[card_name] = love.graphics.newImage('formats/lands/cards/' .. card_name .. '.png' )
		end

		entity_idx = NewCard(entity, card_name, cards_struct)

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
