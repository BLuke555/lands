function TrimLeadingChar(str, char)
	local pos = 1

	while string.sub(str, pos, pos) == char do
		pos = pos + 1
	end
	
	return string.sub(str, pos, string.len(str))
end


function TrimTrailingChar(str, char)
	local pos = string.len(str)

	while string.sub(str, pos, pos) == char do
		pos = pos - 1
	end
	
	return string.sub(str, 1, pos)
end


function TrimEdgeChar(str, char)
	str = TrimLeadingChar(str, char)
	str = TrimTrailingChar(str, char)

	return str
end


function Switch(param, case_table)
    local case = case_table[param]
    if case then return case() end
    local def = case_table['default']
    return def and def() or nil
end


function IsMouseOver(rect)
	local x, y = love.mouse.getPosition()

	local origin_x = rect.origin_x or 0
	local origin_y = rect.origin_y or 0


	return (x > rect.x - origin_x and x < rect.x + rect.width - origin_x and
					y > rect.y - origin_y and y < rect.y + rect.height - origin_y)
end

function GetEntitiesUnderMouseCursor()
	local entities = {}

	for _, entity in ipairs(Entities) do
		if Rects[entity] ~= nil and IsMouseOver(Rects[entity]) then
			print(entity)
			table.insert(entities, entity)
		end
	end

	print(#entities)
	return entities
end
