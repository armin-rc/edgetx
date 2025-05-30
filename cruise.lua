-- TNS|CRUISE CONTROL|TNE

---- ########################################################
---- #                                                      #
---- # Copyright (C) arminRC                                #
---- # YouTube channel: https://www.youtube.com/@arminrc    #
---- # !!! Please like and subscribe !!!                    #
---- #                                                      #
---- # Script Type: Mixes									#
---- #                                                      #
---- ########################################################

local input =
	{                                                       -- Names (Max. 6 chars) on the input table are shown on the radio when specifying the data
		{ "Power", SOURCE },    			                -- User selected source (the throttle input)
		{ "Switch", SOURCE },                               -- User selected source (the state of the push button)
		{ "DeadZo", VALUE, 1, 20, 10 }                      -- User selected value (Deadzone || minimum: 1 | maximum: 20 | default: 10)
	}

local output = { "Thrtle", "Active" }                       -- Data provided by the script to the radio (can be used in the mixer page for example // Names max. 6 chars)

local cruise_state = 0                                      -- State of cruise control: on or off
local cruise_value = 0                                      -- The value for the throttle channel provided by the script
local allow_toggle = 1                                      -- Internal flag if toggling the state is allowed

local function init()
	-- Called once when the script is loaded
end

local function run(power, switch, deadzo) 				    -- Number of params must match number of params in the input table
	-- Called periodically
	
	-- ------------------------------------------
	-- !!! KEEP THE CODE AS SHORT AS POSSIBLE !!!
	-- ------------------------------------------
	
	-- The value of a (logical) two position switch is -100 or 100
	-- So, if the input value for the switch is lower/equal zero,
	-- then Cruise Control is disabled and the function returns
	-- the input value for throttle without further processing.
	
	if switch <= 0 and cruise_state == 0 then               -- Push button not pushed and cruise control inactive
		allow_toggle = 1
		cruise_value = power
	else
		if switch > 0 then                                  -- Push button is currently pushed
			if allow_toggle > 0 then                        -- If toggling the curise control state is possible, then ...
				cruise_value = power                        -- Set the cruise control throttle value
				allow_toggle = 0                            -- Set flag to 0 in order to run this code only once
				cruise_state = cruise_state == 1 and 0 or 1 -- toggle cruise control (1 > 0 | 0 > 1)
			end
		else
			allow_toggle = 1                                -- Push button is currently not pushed; now set flag to 1
			
			-- Use the following block if you want to disable/override cruise control by using the throttle trigger.
            -- Possible scenarios:
            -- * Disengage cruise control when trigger in the opposite direction (shown in this example)
            -- * Override cruise control value when actual throttle input is bigger than cruise control value
            -- * The sky (or your imagination) is the limit ;-)
            -- ** START **
			if cruise_state > 0 then
				-- From EdgeTX LUA Doc:
				-- the typical input range is -1024 thru +1024. Simply divide the 
				-- input value by 10.24 to convert to a percentage from -100% to +100%.				
				local deadzone = deadzo * 10.24
				if cruise_value > 0 and power < -deadzone or cruise_value < 0 and power > deadzone then -- small dead zone around neutral
					cruise_state = 0                        -- Disengage cruise control
					cruise_value = power                    -- Set output value to current throttle value
				end
			end
            -- ** END **
		end
	end
	
	return cruise_value, cruise_state * 1024         	    -- Must match output table
end

return { input=input, output=output, run=run, init=init }
