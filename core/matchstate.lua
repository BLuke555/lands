return {
	Match = require("states.match"),
	DrawPhase = require("formats/lands/states/draw_phase"),
	MainPhase = require("formats/lands/states/main_phase"),

	transition = function(newState) -- moves to a new state (marked with a string)
		local currentState = Game.currentState
		print("Switching from "..currentState.." to "..newState)
		if State[currentState] and State[newState] then -- checks if both the current and new states have an entry in the state machine
			State[currentState].exit()
			Game.currentState = newState
			State[currentState].enter()
		end
	end,

	update = function (dt)
		State[Game.currentState].update(dt)
	end,
	
	mousepressed = function(x, y, button, istouch, pressed)
	end
}

--[[
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
			State.transition("DrawPhase")
		end
	end

	MainPhase.exit = function()
	end
]]