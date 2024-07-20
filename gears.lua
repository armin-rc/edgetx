-- TNS|GEAR SHIFT SETUP|TNE

---- ########################################################
---- #                                                      #
---- # Copyright (C) arminRC                                #
---- # YouTube channel: https://www.youtube.com/@arminrc    #
---- # !!! Please like and subscribe !!!                    #
---- #                                                      #
---- # Like this script? Buy me a coffee!                   #
---- # https://www.buymeacoffee.com/arminrc                 #
---- #                                                      #
---- ########################################################

-- Ich habe heute den ganzen Tag lang versucht, eine Gangschaltung ( R - N - G1, G2, G3, G4, G5 ) mit Logischen Schaltern zu simulieren...
-- Irgendwann waren so viele L-SWs vergeben, dass es keinen Spaß mehr gemacht hat.
-- Jetzt könnte ich das Script ja so verwenden und von ( R ) bis ( G5 ) alles easy durch schalten, ABER...
-- Auch hier hab ich wieder sonderwünsche.
-- ( N ) Soll beim einschalten immer aktiv sein.
-- Nun soll es möglich sein, von ( N ) in beide richtungen ( R ) aber auch in die Gruppe ( G1-G5 ) schalten zu können.
-- Es darf aber nicht möglich sein, von ( G1 ) ausversehen wieder in ( N ) zu schalten. Hier muss bei ( G1 ) also ein STOP sein.
-- Auch soll man nicht ausversehen im ( R ) landen.
-- ( N ) & ( R ) sollen nun aber aus jedem Gang heraus mit einem langen Tastendruck direkt zu erreichen sein.
-- Selbstverständlich muss dann aber wieder die Gruppe ( G1-G5 ) inaktiv sein. 

local GEAR_STEP = 20

local input =
	{                                                       	-- Names on the input table are shown on the radio when specifying the data
		{ "SW_UP1", SOURCE },    			                	-- User selected source (Swtich 1 [short press] for gear up)
		{ "SW_UP2", SOURCE },    			                	-- User selected source (Swtich 2 [long press] for gear up)
		{ "SW_DN1", SOURCE },                               	-- User selected source (Swtich 1 [short press] for gear down)
		{ "SW_DN2", SOURCE },                               	-- User selected source (Swtich 2 [medium press] for gear down)
		{ "SW_DN3", SOURCE }                               	    -- User selected source (Swtich 3 [long press] for gear down)
	}

local output = { "ChaVal", "Gear" }                       		-- Data provided by the script to the radio (can be used in the mixer page for example // Names max. 6 chars)

local cha_val = 0                                               -- The channel value which is returned to EdgeTX
local current_gear = 0											-- The currently selected gear. Will be provided to EdgeTX in the output value
local active = 0                                                -- Flag if we are currently active

local function init()
	-- Called once when the script is loaded
end

local function run(sw_up_1, sw_up_2, sw_dn_1, sw_dn_2, sw_dn_3) -- Number of params must match number of params in the input table
	-- Called periodically

	-- ---------------------------------------------------
	-- !!! KEEP THE CODE AS SHORT AND FAST AS POSSIBLE !!!
	-- ---------------------------------------------------

    if sw_dn_3 > 10 then                                        -- Long press down > always go to reverse
        if active == 1 then
            return cha_val * 10.24, current_gear * 10.24
        end
        current_gear = -1
        cha_val = -100
        active = 1
        return cha_val * 10.24, current_gear * 10.24
    end

    if sw_dn_2 > 10 or sw_up_2 > 10 then                        -- Medium press down or medium press up > always go to neutral
        if active == 1 then
            return 0, 0
        end
        current_gear = 0
        cha_val = 0
        active = 1
        return 0, 0
    end

    if sw_up_1 > 10 then
        if active == 1 then
            return cha_val * 10.24, current_gear * 10.24
        end
        if current_gear < 5 then
            current_gear = current_gear + 1
            cha_val = current_gear * GEAR_STEP
        end        
        active = 1
        return cha_val * 10.24, current_gear * 10.24
    end

    if sw_dn_1 > 10 then
        if active == 1 then
            return cha_val * 10.24, current_gear * 10.24    
        end
        if current_gear > 1 then
            current_gear = current_gear - 1
            cha_val = current_gear * GEAR_STEP
        end
        active = 1
        return cha_val * 10.24, current_gear * 10.24
    end

    active = 0
	return cha_val * 10.24, current_gear * 10.24         	    	    -- Count of params must match number of values in output table
end

return { input=input, output=output, run=run, init=init }
