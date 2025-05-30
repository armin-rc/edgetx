-- TNS|SPECIAL CRUISE CONTROL SETUP|TNE

---- ########################################################
---- #                                                      #
---- # Copyright (C) arminRC                                #
---- # YouTube channel: https://www.youtube.com/@arminrc    #
---- # !!! Please like and subscribe !!!                    #
---- #                                                      #
---- # Like this script? Buy me a coffee!                   #
---- # https://www.buymeacoffee.com/arminrc                 #
---- #                                                      #
---- # Script Type: Mixes                                   #
---- #                                                      #
---- ########################################################

local input =
	{                                                       	-- Names on the input table are shown on the radio when specifying the data
		{ "Power", SOURCE },    			                	-- User selected source (the throttle input)
		{ "Switch", SOURCE },                               	-- User selected source (the switch to set the modes [SA])
		{ "DeadZo", VALUE, 1, 5, 1 }                     		-- User selected value (Deadzone || minimum: 1 | maximum: 5 | default: 1)
	}

local output = { "Thrtle", "Mode" }                       		-- Data provided by the script to the radio (can be used in the mixer page for example // Names max. 6 chars)

local cruise_value = 0                                      	-- The value for the throttle channel provided by the script
local prev_power = 0

local function handlePowerChange(power, deadzo)
	local cv_abs = math.abs(cruise_value)						-- Work with absolute values in order to make this methode universal for both sides (forward vs reverse)

																-- power greater then deadzo 		--> increase speed
																-- power less then (deadzo * -1) 	--> decrease speed

	if power > deadzo and power > cv_abs then								-- Increase throttle output
		cv_abs = power
		prev_power = 0
	elseif power < (deadzo * -1) and power < prev_power and cv_abs > 0 then	-- Decrease throttle output
		local diff_power = power - prev_power								-- diff between current throttle input and last throttle input
		cv_abs = cv_abs + diff_power										-- decrease the actual throttle value by the throttle input difference
		prev_power = power													-- store current throttle input for next cycle
	end
	
	cruise_value = cv_abs										-- assign the (positive) output value to the cruise_value variable
	
	if cruise_value < 0 then									-- Make sure that there are no negative values for cruise_value
		cruise_value = 0
	end
end

local function init()
	-- Called once when the script is loaded
end

local function run(power, switch, deadzo) 						-- Number of params must match number of params in the input table
	-- Called periodically
	
	-- ------------------------------------------
	-- !!! KEEP THE CODE AS SHORT AS POSSIBLE !!!
	-- ------------------------------------------
	
	if switch == 0 then											-- Are we in "neutral" mode > set all to zero and back again
		cruise_value = 0
		prev_power = 0
		return 0, 0
	end
	
	local deadzone = deadzo * 10.24								-- apply factor to match the input value to the internal value handling
	handlePowerChange(power, deadzone)							-- lets do some work ...
	
	local cruise_mode = 1
	if switch < -10 then										-- set the output values according to the mode
		cruise_value = cruise_value * -1						-- If we in reverse mode then flip the value
		cruise_mode = -1
	end
	
	return cruise_value, cruise_mode * 1024         	    	-- Count of params must match number of values in output table
end

return { input=input, output=output, run=run, init=init }
