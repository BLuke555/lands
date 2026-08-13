matchstate = {}
DrawPhase = {}
MainPhase = {}

matchstate.transition = function(newState) -- moves to a new state (marked with a string)
	print("Switching from "..currentState.." to "..newState)
	if matchstate[currentState] and matchstate[newState] then -- checks if both the current and new states have an entry in the state machine
		matchstate[currentState].exit()
		currentState = newState
		matchstate[currentState].enter()
	end
end

matchstate.update = function (dt)
	currentState.update(dt)
end

DrawPhase.enter = function() --when entering a state
	currentPhase = 1
	turnNumber = turnNumber + 1
	if turnPlayer < Game.players then
		turnPlayer = turnPlayer + 1
	else
		turnPlayer = 1
	end
	currentPhase = 1
end

DrawPhase.exit = function()
end

MainPhase.enter = function()
	currentPhase = currentPhase + 1
	
	if turnPlayer == 2 then
		print("It's the opponent's turn.\nOpponent passed.")
		matchstate.transition("DrawPhase")
	end
end

MainPhase.exit = function()
end
