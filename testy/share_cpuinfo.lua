package.path = "../?.lua;"..package.path;

--[[
	This application will display the CPU utilization Percentage, 
	The data and calculation is the same as what you would see running
	the 'top' command from a command line.
--]]

local ffi = require("ffi")
local NetInteractor = require("tflremote.sharer")



local colors = require("colors")
local keycodes = require("tflremote.jskeycodes")
--local procfs = require("lj2procfs.procfs")
local stat = require("stat")

local random = math.random

local width = 640;
local height = 100;
local loadnums = ffi.new("double[?]", width)
local PreviousStats = nil;


local graphPort = size(width, height)

local function shiftleft(values)
	local offset = 0
	while (offset <= width-2) do
		values[offset] = values[offset+1]
		offset = offset + 1;
	end		
end

-- Reference for CPU_Percentage calculation
-- http://stackoverflow.com/questions/23367857/accurate-calculation-of-cpu-usage-given-in-percentage-in-linux
--
function loop()

	-- get the latest load number
	-- newest number goes into highest position
	local newStats = stat.decoder();
	
	-- Calculate current collection percentages
	newStats.Idle = newStats.idle + newStats.iowait;
	newStats.NonIdle = newStats.user + newStats.nice + 
		newStats.system + newStats.irq + newStats.softirq +
		newStats.steal;
	newStats.Total = newStats.Idle + newStats.NonIdle;

	if not PreviousStats then
		PreviousStats = newStats;
		return 
	end

	-- Calculate difference between two collections
	local totald = newStats.Total - PreviousStats.Total;
	local idled = newStats.Idle - PreviousStats.Idle;

	local CPU_Percentage = (totald - idled)/totald;

	PreviousStats = newStats;

	-- shift everything from highest down one
	shiftleft(loadnums)

	loadnums[width-1] = CPU_Percentage;

	-- draw vertical line for each value
	graphPort:clearAll();
	for i=0,width-1 do
		--print("loadnums: ", i, loadnums[i])
		local yval = RANGEMAP(loadnums[i], 0, 1.0, height-1, 0)
		--print("yval: ", yval)
		--graphPort:setPixel(i, yval, colors.white)blue
		graphPort:line(i, height-1, i, yval, colors.yellow)
	end
end

loopInterval(1000/4)

run()