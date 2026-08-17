local Events = {}


function ConnectToEvent(event, prerequisits, action)
	if Events[event] == nil then Events[event] = {} end
	local new_event = Events[event][#Events+1]

	new_event = {}
	new_event.prerequisits = prerequisits
	new_event.action = action
end


function DisconnectToEvent(event, prerequisits, action)
	if Events[event] == nil then
		print('[EVENT] this event does not exists')
		return
	end

	for index, value in ipairs(Events[event]) do
		if value.prerequisits == prerequisits and value.action == action then
			table.remove(Events[event], index)
			break
		end
	end
end


function CallEvent(event, ...)
	local arguments = {...}
	print(event)
	
	for i, v in ipairs(arguments) do
		print(i .. ' - ' .. v)
	end
end
