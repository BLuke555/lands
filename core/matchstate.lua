matchstate = {}
DrawPhase = {}
MainPhase = {}

matchstate.init = function() -- resets the match state to the beginning
	turnPlayer = 2 -- 2 (opponent) for test
	turnNumber = 1
	currentPhase = 1
	currentState = "DrawPhase" -- name of the current state
	
	matchstate.DrawPhase = DrawPhase
	matchstate.MainPhase = MainPhase
end

matchstate.transition = function(newState) -- moves to a new state (marked with a string)
	print("Switching from "..currentState.." to "..newState)
	if matchstate[currentState] and matchstate[newState] then -- checks if both the current and new states have an entry in the state machine
		matchstate[currentState].exit()
		currentState = newState
		matchstate[currentState].enter()
	end
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
	
	if not(turnNumber == 1 and Game.should_draw_first_turn) then
		MoveCards(Board.library[turnPlayer].cards, Board.hand[turnPlayer].cards, 1, #Board.hand[turnPlayer].cards, 1)
	end
	
	matchstate.transition("MainPhase")
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