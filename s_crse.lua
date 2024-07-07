-- TNS|SPECIAL CRUISE CONTROL|TNE

---- ########################################################
---- #                                                      #
---- # Copyright (C) arminRC                                #
---- # YouTube channel: https://www.youtube.com/@arminrc    #
---- # !!! Please like and subscribe !!!                    #
---- #                                                      #
---- ########################################################

local input =
	{                                                       	-- Names (Max. 6 chars) on the input table are shown on the radio when specifying the data
		{ "Power", SOURCE },    			                	-- User selected source (the throttle input)
		{ "Switch", SOURCE },                               	-- User selected source (the state of the push button)
		{ "DeadZo", VALUE, 1, 5, 2 }                     		-- User selected value (Deadzone || minimum: 0 | maximum: 20 | default: 5)
	}

local output = { "Thrtle", "Mode" }                       		-- Data provided by the script to the radio (can be used in the mixer page for example // Names max. 6 chars)

local cruise_value = 0                                      	-- The value for the throttle channel provided by the script
local prev_power = 0

local function handlePowerChange(power, deadzo)
	local cv_abs = math.abs(cruise_value)						-- Work with absolute values in order to make this methode universal for both sides (forward vs reverse)

	if power > deadzo and power > cv_abs then								-- Increase throttle output
		cv_abs = power
		prev_power = 0
	elseif power < (deadzo * -1) and power < prev_power and cv_abs > 0 then	-- Decrease throttle output
		local diff_power = power - prev_power
		cv_abs = cv_abs + diff_power
		prev_power = power
	end
	
	cruise_value = cv_abs
	
	if cruise_value < 0 then									-- Here always positive values
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
	
	if switch == 0 then
		cruise_value = 0
		prev_power = 0
		return 0, 0
	end
	
	local deadzone = deadzo * 10.24
	handlePowerChange(power, deadzone)
	
	local cruise_mode = 1
	if switch < -10 then
		cruise_value = cruise_value * -1						-- If we in reverse mode then flip the value
		cruise_mode = -1
	end
	
	return cruise_value, cruise_mode * 1024         	    	-- Must match output table
end

return { input=input, output=output, run=run, init=init }
