-- TNS|ENGINE SOUND SIMULATION|TNE

---- ########################################################
---- #                                                      #
---- # Copyright (C) arminRC                                #
---- # YouTube channel: https://www.youtube.com/@arminrc    #
---- # !!! Please like and subscribe !!!                    #
---- #                                                      #
---- # Script Type: Function                                #
---- #                                                      #
---- ########################################################


local IDX_THR_CH = 1

local last_value = 0
local last_frq = 0

-- Called once when the script is loaded
local function init()

end

-- Called periodically while the Special Function switch is on
local function run()
    flushAudio()

    local ch_thr_val = getOutputValue(IDX_THR_CH)

    if last_value == ch_thr_val then
        playTone(last_frq, 2, 1, 3, 0, 5) -- play tone, use Beep volume 5
        return
    end

    last_value = ch_thr_val

    if ch_thr_val == nil then
        ch_thr_val = 0
    end

    ch_thr_val = math.abs(ch_thr_val / 10.24)
    if ch_thr_val < 1 then
        ch_thr_val = 0
    end

    if ch_thr_val == 0 then
        return
    end

    last_frq = 200 + ch_thr_val

    playTone(last_frq, 2, 1, 0, 0, 5) -- play tone, use Beep volume 5
end

-- Called periodically while the Special Function switch is off
local function background()

end

return { run=run, background=background, init=init }