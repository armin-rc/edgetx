-- TNS|PROCESS TELEMETRY|TNE

---- ########################################################
---- #                                                      #
---- # Copyright (C) arminRC                                #
---- # YouTube channel: https://www.youtube.com/@arminrc    #
---- # !!! Please like and subscribe !!!                    #
---- #                                                      #
---- # Script Type: Telemetry                               #
---- #                                                      #
---- ########################################################

-- Constants
local LINE_HEIGHT = 9 -- px

-- Variables
local sensorIdEsc = nil -- Sensor monitors voltage delivered by ESC
local sensorIdBat = nil -- Sensor monitors voltage delivered by Battery

local function getCellCount(voltage)
	-- The normal voltage range for a LiPo cell is from 3.2V to 4.2V
	
	if voltage < 3 then
		return 0 -- out of range
	end	
	
	if voltage < 5 then
		return 1 -- 1S
	end
	
	if voltage < 9 then
		return 2 -- 2S
	end
	
	if voltage < 12 then
		return 3 -- 3S
	end
	
	if voltage < 18 then
		return 4 -- 4S
	end
	
	return 0 -- out of range
end

local function init()
	-- init is called once when model is loaded
	
	-- Retrieve Info about Sensor "A1" (Supply Voltage delivered by the ESC)
	local sensorInfo = getFieldInfo("A1")
	if sensorInfo ~= nil then
		sensorIdEsc = sensorInfo.id	-- ID of the sensor
	end
	
	-- Retrieve Info about Sensor "A2" (Supply Voltage delivered by the Battery)
	sensorInfo = getFieldInfo("A2")
	if sensorInfo ~= nil then
		sensorIdBat = sensorInfo.id	-- ID of the sensor
	end	
end

local function run(event)
	-- run is called periodically only when screen is visible
	lcd.clear() -- needed to run properly
	
	local line_index = 0
	
	lcd.drawText(0, LINE_HEIGHT * line_index, string.upper("Voltage total"), BOLD)
	
	line_index = line_index + 1
	
	local voltEsc = getValue(sensorIdEsc)
	local voltBat = getValue(sensorIdBat)
	
	local dataEsc = string.format("ESC: %.2fV", voltEsc) -- ESC: 7.40V
	local dataBat = string.format("BAT: %.2fV", voltBat) -- BAT: 8.10V
	
	lcd.drawText(0, LINE_HEIGHT * line_index, dataEsc .. " | " .. dataBat) -- ESC: 7.40V | BAT: 8.10V
	
	line_index = line_index + 1
	
	local vert_pos = LINE_HEIGHT * line_index + LINE_HEIGHT / 2 - 1
	lcd.drawLine(0, vert_pos, LCD_W, vert_pos, SOLID, 0)
	
	line_index = line_index + 1	
  
	lcd.drawText(0, LINE_HEIGHT * line_index, string.upper("Cell average"), BOLD)
  
	line_index = line_index + 1
	
	local cell_cnt = getCellCount(voltBat)
	if cell_cnt > 0 then
		local cell_avg = voltBat / cell_cnt
		local cell_data = string.format("CELL: %.2fV (%d cells)", cell_avg, cell_cnt) -- CELL: 4.05V (2 cells)
		lcd.drawText(0, LINE_HEIGHT * line_index, cell_data)
	else
		lcd.drawText(0, LINE_HEIGHT * line_index, "Cell count: N/A")
	end
end

local function background()
	-- background is called periodically
end

return { run = run, background = background, init = init }
