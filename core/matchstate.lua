matchstate = {}

matchstate.init = function() -- resets the match state to the beginning
	turnPlayer = 2 -- 2 (opponent) for test
	turnNumber = 1
	currentPhase = 1
end

matchstate.phaseAdvance = function() -- advances the phase
	if currentPhase < #Game.phases then
		currentPhase = currentPhase + 1
	else
		turnNumber = turnNumber + 1
		if turnPlayer < #Game.board.players then
			turnPlayer = turnPlayer + 1
		else
			turnPlayer = 1
			currentPhase = 1
		end
	end
	print(currentPhase)
	print(Game.phases[currentPhase])
end