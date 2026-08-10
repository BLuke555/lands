-- this moulde introduce abstraction to create, destroy and
-- manipulate entities

Entities = {}

function NewEntity()
	local idx = #Entities + 1

	return idx
end
