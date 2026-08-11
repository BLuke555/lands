function Switch(param, case_table)
    local case = case_table[param]
    if case then return case() end
    local def = case_table['default']
    return def and def() or nil
end

function IsMouseOver(rect)
	local x, y = love.mouse.getPosition()
	return (x > rect.x - rect.origin_x and x < rect.x + rect.width - rect.origin_x and
					y > rect.y - rect.origin_y and y < rect.y + rect.height - rect.origin_y)
end

