-- TNS|GEAR SHIFT SETUP|TNE

---- ################################################################
---- #                                                              #
---- # Copyright (C) arminRC                                        #
---- # YouTube channel: https://www.youtube.com/@arminrc            #
---- # !!! Please like and subscribe !!!                            #
---- #                                                              #
---- # Like this script? Buy me a coffee!                           #
---- # https://www.buymeacoffee.com/arminrc                         #
---- #                                                              #
---- ################################################################

---- ################################################################
---- #                                                              #
---- # Logical switches used in the setup                            #
---- # SW_UP1: L01: Edge | T3- | [0.0:0.3] | Duration: 0.2          #
---- # SW_UP2: L02: Edge | T3- | [0.4:<<]  | Duration: 0.2          #
---- # SW_DN1: L03: Edge | T3+ | [0.0:0.3] | Duration: 0.2          #
---- # SW_DN2: L04: Edge | T3+ | [0.4:0.8] | Duration: 0.2          #
---- # SW_DN3: L05: Edge | T3+ | [1.0:<<]  | Duration: 0.2          #
---- #                                                              #
---- ################################################################

local input =
	{                                                       	-- Names on the input table are shown on the radio when specifying the data
		{ "SW_UP1", SOURCE },    			                	-- User selected source (Swtich 1 [short press] for gear up)
		{ "SW_UP2", SOURCE },    			                	-- User selected source (Swtich 2 [long press] for gear up)
		{ "SW_DN1", SOURCE },                               	-- User selected source (Swtich 1 [short press] for gear down)
		{ "SW_DN2", SOURCE },                               	-- User selected source (Swtich 2 [medium press] for gear down)
		{ "SW_DN3", SOURCE },                              	    -- User selected source (Swtich 3 [long press] for gear down)
        { "GEARS", VALUE, 1, 10, 5}                             -- User selected value (Number of gears || minimum: 1 | maximum: 10 | default: 5)
	}

local output = { "ChaVal", "Gear" }                       		-- Data provided by the script to the radio (can be used in the mixer page for example // Names max. 6 chars)

local cha_val = 0                                               -- The channel value which is returned to EdgeTX
local current_gear = 0											-- The currently selected gear. Will be provided to EdgeTX in the output value
local active = 0                                                -- Flag if we are currently active

local function init()
	-- Called once when the script is loaded
end

local function run(sw_up_1, sw_up_2, sw_dn_1, sw_dn_2, sw_dn_3, gears) -- Number of params must match number of params in the input table
	-- Called periodically

	-- ------------------------------------------------------
	-- !!! KEEP THE CODE AS SHORT AND/OR FAST AS POSSIBLE !!!
	-- ------------------------------------------------------

    local gear_step = 100 / gears

    if sw_dn_3 > 10 then                                        -- Long press down > always go to reverse
        if active == 1 then
            return cha_val * 10.24, current_gear * 10.24
        end
        current_gear = -1
        cha_val = -100
        active = 1
        return cha_val * 10.24, current_gear * 10.24
    end

    if sw_dn_2 > 10 or sw_up_2 > 10 then                        -- Medium press down or up > always go to neutral
        if active == 1 then
            return 0, 0
        end
        current_gear = 0
        cha_val = 0
        active = 1
        return 0, 0
    end

    if sw_up_1 > 10 then                                        -- Short press up > go to next gear (max gear is 5)
        if active == 1 then
            return cha_val * 10.24, current_gear * 10.24
        end
        if current_gear < gears then
            current_gear = current_gear + 1
            cha_val = current_gear * gear_step
        end        
        active = 1
        return cha_val * 10.24, current_gear * 10.24
    end

    if sw_dn_1 > 10 then                                        -- Short press down > go to previous gear (min gear is 1)
        if active == 1 then
            return cha_val * 10.24, current_gear * 10.24
        end
        if current_gear > 1 then
            current_gear = current_gear - 1
            cha_val = current_gear * gear_step
        end
        active = 1
        return cha_val * 10.24, current_gear * 10.24
    end

    active = 0
	return cha_val * 10.24, current_gear * 10.24         	    -- Count of params must match number of values in output table
end

return { input=input, output=output, run=run, init=init }
