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
			table.insert(entities, entity)
		end
	end

	return entities
end
