-- TNS|n-POSITION-SWITCH|TNE

---- ########################################################
---- #                                                      #
---- # Copyright (C) arminRC                                #
---- # YouTube channel: https://www.youtube.com/@arminrc    #
---- # !!! Please like and subscribe !!!                    #
---- #                                                      #
---- # Script Type: Function                                #
---- #                                                      #
---- ########################################################

TRIG1_IDX = 0				-- index of the 1st logical switch that trigger the script (up)
TRIG2_IDX = 1				-- index of the 2nd logical switch that trigger the script (down)

START_IDX = 4				-- index of the 1st logical switch in the multi-position-switch

local current_idx = START_IDX		-- index of the currently active switch-position

local function incrementSticky()
	local sw_val = model.getLogicalSwitch(current_idx + 1)
	if sw_val == nil then
		return
	end
	
	if sw_val["func"] ~= LS_FUNC_STICKY then
		return
	end

	setStickySwitch(current_idx, false)
	setStickySwitch(current_idx + 1, true)
	
	current_idx = current_idx + 1
end

local function decrementSticky()
	if current_idx == START_IDX then
		return
	end

	setStickySwitch(current_idx, false)
	setStickySwitch(current_idx - 1, true)
	
	current_idx = current_idx - 1
end

-- Called once when the script is loaded
local function init()
	setStickySwitch(START_IDX, true)
end

-- Called periodically while the Special Function switch is on
local function run()
	local trig1_val = getLogicalSwitchValue(TRIG1_IDX)
	local trig2_val = getLogicalSwitchValue(TRIG2_IDX)
	
	if trig1_val == true then
		incrementSticky()
	elseif trig2_val == true then
		decrementSticky()
	end
end

-- Called periodically while the Special Function switch is off
local function background()
  
end

return { run=run, background=background, init=init }
