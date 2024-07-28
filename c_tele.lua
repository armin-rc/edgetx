-- TNS|SET TELEMETRY-SENSOR VALUES|TNE

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

-- Constants
local LINE_HEIGHT = 9 -- px
local HEADER_SPACE = 3 -- px
local LCD_W_QUART = LCD_W / 4

local IDX_STF_CH = 0
local IDX_STR_CH = 2

local IDX_THF_CH = 1
local IDX_THR_CH = 3

local IDX_WIN_CH = 4

local ST_MIX_RATIO = "s1"
local MOA_ODR_RATIO = "input3"

local LSW_ID_BURN_MODE = 11
local LSW_ID_DIG_MODE = 13

local LSW_ID_4WS_PRIO = 2

-- Variables
local fieldIdStMix = nil
local fieldIdMoaOd = nil

local cycleCounter = 0
local total_x_offset = 0
local winch_x_base = LCD_W * 3 / 4 - 4

local function init()
	-- Called once when the script is loaded

	-- Retrieve Info about the channel for the steering mix (front vs rear)
	local fieldInfo = getFieldInfo(ST_MIX_RATIO)
	if fieldInfo ~= nil then
		fieldIdStMix = fieldInfo.id
    else
        fieldIdStMix = 0
	end
	
	-- Retrieve Info about the channel for the overdrive ratio on MOA
	fieldInfo = getFieldInfo(MOA_ODR_RATIO)
	if fieldInfo ~= nil then
		fieldIdMoaOd = fieldInfo.id
    else 
        fieldIdMoaOd = 0
	end
end

local function processThrottle()
    local ch_thf_val = getOutputValue(IDX_THF_CH)
    if ch_thf_val == nil then
        ch_thf_val = -1
    end
    ch_thf_val = ch_thf_val / 10.24
    if math.abs(ch_thf_val) < 1 then
        ch_thf_val = 0
    end

    local ch_thr_val = getOutputValue(IDX_THR_CH)
    if ch_thr_val == nil then
        ch_thr_val = -1
    end
    ch_thr_val = ch_thr_val / 10.24
    if math.abs(ch_thr_val) < 1 then
        ch_thr_val = 0
    end

    local moa_od_val = getSourceValue(fieldIdMoaOd)
    if moa_od_val == nil then
        moa_od_val = -1
    end
    moa_od_val = (1024 - moa_od_val) / 10.24

    local sw_val_burn = getLogicalSwitchValue(LSW_ID_BURN_MODE)
    local sw_val_dig = getLogicalSwitchValue(LSW_ID_DIG_MODE)

    local moa_mode = "MOA"
    if sw_val_burn == true then
        moa_mode = "BURN"
        moa_od_val = 0
    elseif sw_val_dig == true then
        moa_mode = "DIG"
        moa_od_val = 0
    end

    local y_pos = 0

    lcd.drawFilledRectangle(0, y_pos, LCD_W / 2 - 2, LINE_HEIGHT)
    lcd.drawText(1, y_pos + 1, "THROTTLE", INVERS)
    y_pos = y_pos + LINE_HEIGHT + HEADER_SPACE

    lcd.drawText(0, y_pos, "MODE:", SMLSIZE)
    lcd.drawText(LCD_W_QUART, y_pos, moa_mode, SMLSIZE)
    y_pos = y_pos + LINE_HEIGHT

    local th_mix_txt = string.format("%.0f%%", moa_od_val)
    lcd.drawText(0, y_pos, "OD:", SMLSIZE)
    lcd.drawText(LCD_W_QUART, y_pos, th_mix_txt, SMLSIZE)
    y_pos = y_pos + LINE_HEIGHT

    local ch_thf_txt = string.format("F: %.0f", ch_thf_val)
    lcd.drawText(0, y_pos, ch_thf_txt, SMLSIZE)
    local ch_thr_txt = string.format("R: %.0f", ch_thr_val)
    lcd.drawText(LCD_W_QUART, y_pos, ch_thr_txt, SMLSIZE)
    y_pos = y_pos + LINE_HEIGHT

    local bar_y_center = y_pos + LINE_HEIGHT / 2

    lcd.drawLine(LCD_W_QUART, y_pos, LCD_W_QUART, y_pos + LINE_HEIGHT - 1, SOLID, 0)

    local hor_bar_x_off_fr = 0
    if ch_thf_val > 0 then
        hor_bar_x_off_fr = 1
    elseif ch_thf_val < 0 then
        hor_bar_x_off_fr = -1
    end

    if hor_bar_x_off_fr ~= 0 then
        local bar_factor_fr = ch_thf_val / 100
        local bar_value_fr = LCD_W_QUART + LCD_W_QUART * bar_factor_fr - hor_bar_x_off_fr
        lcd.drawLine(LCD_W_QUART + hor_bar_x_off_fr, bar_y_center - 2, bar_value_fr, bar_y_center - 2, SOLID, 0)
        lcd.drawLine(LCD_W_QUART + hor_bar_x_off_fr, bar_y_center - 1, bar_value_fr, bar_y_center - 1, SOLID, 0)
    end

    local hor_bar_x_off_rr = 0
    if ch_thr_val > 0 then
        hor_bar_x_off_rr = 1
    elseif ch_thr_val < 0 then
        hor_bar_x_off_rr = -1
    end

    if hor_bar_x_off_rr ~= 0 then
        local bar_factor_rr = ch_thr_val / 100
        local bar_value_rr = LCD_W_QUART + LCD_W_QUART * bar_factor_rr - hor_bar_x_off_rr
        lcd.drawLine(LCD_W_QUART + hor_bar_x_off_rr, bar_y_center + 1, bar_value_rr, bar_y_center + 1, SOLID, 0)
        lcd.drawLine(LCD_W_QUART + hor_bar_x_off_rr, bar_y_center + 2, bar_value_rr, bar_y_center + 2, SOLID, 0)
    end

    y_pos = y_pos + LINE_HEIGHT

    return y_pos
end

local function processSteering()
    local ch_stf_val = getOutputValue(IDX_STF_CH)
    if ch_stf_val == nil then
        ch_stf_val = -1
    end
    ch_stf_val = ch_stf_val / 10.24
    if math.abs(ch_stf_val) < 2 then
        ch_stf_val = 0
    end    

    local ch_str_val = getOutputValue(IDX_STR_CH)
    if ch_str_val == nil then
        ch_str_val = -1
    end
    ch_str_val = ch_str_val / 10.24
    if math.abs(ch_str_val) < 2 then
        ch_str_val = 0
    end

    local st_mix_val = getSourceValue(fieldIdStMix)
    if st_mix_val == nil then
        st_mix_val = -1
    end
    st_mix_val = st_mix_val / 10.24
    if math.abs(st_mix_val) < 2 then
        st_mix_val = 0
    end

    local sw_val_4ws_prio = getLogicalSwitchValue(LSW_ID_4WS_PRIO)
    local prio_4ws = "FRONT"
    local mode_4ws = "FWS"
    if sw_val_4ws_prio == true then
        prio_4ws = "REAR"
        mode_4ws = "RWS"
    end

    if st_mix_val < 0 then
        mode_4ws = "4WS"
    elseif st_mix_val > 0 then
        mode_4ws = "CRAB"
    end

    local y_pos = 0
    local left_start = LCD_W / 2 + 2

    lcd.drawFilledRectangle(left_start, y_pos, LCD_W / 2 - 2, LINE_HEIGHT)
    lcd.drawText(left_start + 1, y_pos + 1, "STEERING", INVERS)
    y_pos = y_pos + LINE_HEIGHT + HEADER_SPACE

    lcd.drawText(left_start, y_pos, "PRIO:", SMLSIZE)
    lcd.drawText(left_start + LCD_W_QUART, y_pos, prio_4ws, SMLSIZE)
    y_pos = y_pos + LINE_HEIGHT

    lcd.drawText(left_start, y_pos, "MODE:", SMLSIZE)
    lcd.drawText(left_start + LCD_W_QUART, y_pos, mode_4ws, SMLSIZE)
    y_pos = y_pos + LINE_HEIGHT

    local st_mix_txt = string.format("%.0f%%", st_mix_val)
    lcd.drawText(left_start, y_pos, "MIX:", SMLSIZE)
    lcd.drawText(left_start + LCD_W_QUART, y_pos, st_mix_txt, SMLSIZE)
    y_pos = y_pos + LINE_HEIGHT

    local half_screen_width = (LCD_W - left_start) / 2
    local bar_x_center = left_start + half_screen_width
    local bar_y_center = y_pos + LINE_HEIGHT / 2

    local bar_factor_fr = ch_stf_val / 100 -- 1% >> 0.01
    local bar_value_fr = bar_x_center + half_screen_width * bar_factor_fr    
    lcd.drawLine(bar_x_center, y_pos, bar_x_center, y_pos + LINE_HEIGHT - 1, SOLID, 0)
    if ch_stf_val ~= 0 then
        local hor_bar_x_off = 1
        if ch_stf_val < 0 then
            hor_bar_x_off = -1
        end
        lcd.drawLine(bar_x_center + hor_bar_x_off, bar_y_center - 2, bar_value_fr, bar_y_center - 2, SOLID, 0)
        lcd.drawLine(bar_x_center + hor_bar_x_off, bar_y_center - 1, bar_value_fr, bar_y_center - 1, SOLID, 0)
    end

    local bar_factor_rr = ch_str_val / 100 -- 1% >> 0.01
    local bar_value_rr = bar_x_center + half_screen_width * bar_factor_rr
    if ch_str_val ~= 0 then
        local hor_bar_x_off = 1
        if ch_str_val < 0 then
            hor_bar_x_off = -1
        end
        lcd.drawLine(bar_x_center + hor_bar_x_off, bar_y_center + 1, bar_value_rr, bar_y_center + 1, SOLID, 0)
        lcd.drawLine(bar_x_center + hor_bar_x_off, bar_y_center + 2, bar_value_rr, bar_y_center + 2, SOLID, 0)
    end
    y_pos = y_pos + LINE_HEIGHT

    return y_pos
end

local function processWinch(ypos)
    local y_pos = ypos

    lcd.drawLine(0, y_pos, LCD_W, y_pos, SOLID, 0)
    y_pos = y_pos + 3

    local winch_val = getOutputValue(IDX_WIN_CH)
    if winch_val == nil then
        winch_val = -1    
    end
    winch_val = winch_val / 10.24
    if math.abs(winch_val) < 2 then
        winch_val = 0
    end 
    
    local winch_txt = "--"
    local anim_x_offset = 0
    if winch_val > 0 then
        winch_txt = ">>"
        cycleCounter = cycleCounter + 1
        anim_x_offset = 5
    elseif winch_val < 0 then
        winch_txt = "<<"
        cycleCounter = cycleCounter + 1
        anim_x_offset = -5
    else
        winch_x_base = LCD_W * 3 / 4 - 4
        cycleCounter = 0
        total_x_offset = 0
    end

    if cycleCounter > 5 then
        if math.abs(total_x_offset) > (LCD_W_QUART - 12) then
            winch_x_base = LCD_W * 3 / 4 - 4
            total_x_offset = 0
        else
            total_x_offset = total_x_offset + anim_x_offset
            winch_x_base = winch_x_base + anim_x_offset            
        end
        cycleCounter = 0
    end

    lcd.drawFilledRectangle(0, y_pos, LCD_W / 2 - 2, LINE_HEIGHT)
    lcd.drawText(1, y_pos + 1, "WINCH", INVERS)
    lcd.drawText(winch_x_base, y_pos + 1, winch_txt)    
end

local function run(event)                                       -- Called periodically
    lcd.clear()                                                 -- needed to run properly    

    local th_y = processThrottle()
    local st_y = processSteering()

    local y_pos = math.max(th_y, st_y) + 3
    processWinch(y_pos)
end

return { input=input, run=run, init=init }
