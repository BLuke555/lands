-- this moulde introduce abstraction to create, destroy and
-- manipulate entities

Entities = {}


function NewEntity()
	local entity = #Entities + 1

	if #Entities == 1 and Entities[1] > 1 then
		entity = 1

	elseif #Entities > 1 then
		table.sort(Entities)
		for key, value in ipairs(Entities) do
			if Entities[key+1] ~= nil and Entities[key+1] > value+1 then
				entity = value+1
			end
		end
	end

	table.insert(Entities, entity)
	return entity
end

function RemoveEntity(entity)
	for key, value in ipairs(Entities) do
		if value == entity then
			table.remove(Entities, key)
		end
	end
end
