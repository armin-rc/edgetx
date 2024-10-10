-- TNS|ROBOT AUTO MOVE|TNE

---- ############################################################
---- #                                                          #
---- # Copyright (C) arminRC                                    #
---- # YouTube channel: https://www.youtube.com/@arminrc        #
---- # !!! Please like and subscribe !!!                        #
---- #                                                          #
---- # Like this script? Buy me a coffee!                       #
---- # https://www.buymeacoffee.com/arminrc                     #
---- #                                                          #
---- ############################################################

---- ############################################################
---- #                                                          #
---- # USAGE OF THIS SCRIPT                                     #
---- # * Set the sequence [mov_seq] here in this script         #
---- #   as you wish. One line per move.                        #
---- # * Save the script and put it into the correct            #
---- #   folder of the SC-Card.                                 #
---- #   The folder is: /SCRIPTS/MIXES                          #
---- # * Beware of the max filename length!                     #
---- #   Must be 6 chars or less without extension              #
---- # * Define a logical switch that will trigger the          #
---- #   The LS must be of type "STICKY"!                       #
---- #   A good physical switch to use for the logical		    #
---- #   switch would be "SC" (or any other simple push btn)    #
---- # * Select the script on the CUSTOM SCRIPTS page.          #
---- # * Set the index of the logical STICKY switch that        #
---- #   should trigger the script.                             #
---- # * In the MIXES page setup a mix for the channel		    #
---- #   that should be driven by the script.				    #
---- #   Set the SOURCE of that mix to "MAX" and the            #
---- #   "Weight" to global variable (GVx) that matches		    #
---- #   the entry in the sequence table (mov_seq).			    #
---- #   The indeces are zero based: 						    #
---- #    > GV1 > Index: 0									    #
---- #    > GV2 > Index: 1									    #
---- #    > GV3 > Index: 2									    #
---- # * You may use the ouput value of the script (STATE)      #
---- #   to enable/disable other functions of the radio         #
---- #   while the script is running.                           #
---- #                                                          #
---- ############################################################

---- ############################################################
---- #                                                          #
---- # LIMITATIONS                                              #
---- # The "run" function is called periodically			    #
---- # about 30 times per second. Which means the time          #
---- # resolution is about 33ms! Shorter times are			    #
---- # therefore not possible and essentially all timings	    #
---- # are a multiple of 33ms. Please keep that in mind!        #
---- # This is a limitation of the EdgeTX environment, not      #
---- # of the script.										    #
---- #                                                          #
---- ############################################################

local mov_seq = {										-- The sequence that is processed by the script. One line for each move.
	[0] = { gv_idx = 0, duration = 2, value = -50 },	-- Each line has three values: 
	[1] = { gv_idx = 1, duration = 15, value = 100 },	-- * gv_idx: 	index of the global variable (zero based)
	[2] = { gv_idx = 0, duration = 2, value = 50 }		-- * duration: 	defines how long one move is active (value is a multiplicator). A value of 5 results in about 50ms for example!
}														-- * value:		the value to which the global variable will be set. Value is a percentage: 0: off | 100: full power | -50: negativ 50%
														-- If more lines are added please make sure to set the number of the sequence correctly ([0], [1], [2]). Must be incrementing without gaps.

local input =                                           -- Names on the input table are shown on the radio when specifying the data
	{
		{ "LS_IDX", VALUE, 0, 16, 0 }					-- Index of the logical sticky switch that triggers the auto pilot (LS1 > 0, LS2 > 1, etc.)
	}													-- The logical switch is set in the GUI of the radio (on the "Custom Scripts" page)
	
local output = { "STATE" }								-- Number values must match the number of params at the return statements

local is_running = 0									-- Flag that indicates whether the script is active or not. Is returnd as the output parameter
local seq_idx = 0										-- Index of the currently processed sequence-element from the mov_seq - list
local start_time = 0									-- Time-value against the current time is compared to
local do_update = 0										-- Flag the indicates whether an update to global variables is necesseary or not

local function resetPrevValue()							-- Function that resets the previous processed global variable
	if seq_idx == 0 then								-- If we are at the first position there is no previous value
		return
	end
		
	local prev_seq = mov_seq[seq_idx - 1]				-- Get the previous sequence entry
	if prev_seq == nil then								-- If there is none -> exit
		return		
	end
	
	model.setGlobalVariable(prev_seq.gv_idx, 0, 0)		-- Reset the global variable at the given index to zero (0)
end

local function resetAll()								-- Function that resets all global variables processed by the script
	for i,v in ipairs(mov_seq) do
		model.setGlobalVariable(v.gv_idx, 0, 0)
	end
end

local function init()									-- init-function; called once by EdgeTX when the script is loaded
	resetAll()											-- Reset all used global variables to zero (0)
end

local function run(ls_idx) 								-- Number of params must match number of params in the input table	
	if is_running == 0 then								-- If the script is not running then check if the trigger condition is met
		if getLogicalSwitchValue(ls_idx) == true then	-- Check the logical sticky switch if it is on. If so, initialize relevant values
			is_running = 1
			seq_idx = 0
			do_update = 1
			start_time = getTime()
			setStickySwitch(ls_idx, false)				-- Reset the trigger condition (set the relevant logical sticky switch to false)
		end
	end

	if is_running == 0 then								-- If the script is still not running -> reset relevant values -> exit
		seq_idx = 0
		do_update = 0
		return 0										-- Number of params must match number of values in output-list
	end
	
	local seq = mov_seq[seq_idx]						-- Get the current sequence element to process
	if seq == nil then									-- If there is none (if we have already processed all the elements for example) then ...
		resetAll()										-- Reset all global variables
		setStickySwitch(ls_idx, false)					-- Reset the trigger condition
		seq_idx = 0										-- Reset relevant internal values
		do_update = 0
		is_running = 0
		return 0										-- And exit (number of params must match number of values in output-list)
	end
	
	if do_update == 1 then								-- If necesseary process the current sequence and set the global variable
		model.setGlobalVariable(seq.gv_idx, 0, seq.value)
		resetPrevValue()
		do_update = 0
	end
	
	local curr_time = getTime()							-- Get the current time (is a multiple of 10ms!). Text from the docu: "Number of 10ms ticks since the radio was started"
	local time_diff = curr_time - start_time			-- Retrieve the time difference that is then used to check if a global variable should be set	
	
	if time_diff > (seq.duration * 10) then				-- If the time difference is greater then the provided compare value ...
		seq_idx = seq_idx + 1							-- Increment the sequence index
		start_time = curr_time							-- Set the new compare time
		do_update = 1									-- Set the flag in order to process the global variable on the next run
	end
	
	return 1024											-- Number of params must match number of values in output-list
end

return { input=input, init=init, output=output, run=run }
