package.path = "../?.lua;"..package.path;

--[[
	This application will display the CPU utilization Percentage, 
	The data and calculation is the same as what you would see running
	the 'top' command from a command line.
--]]

local ffi = require("ffi")
local NetInteractor = require("tflremote.sharer")



--local colors = require("colors")
--local keycodes = require("tflremote.jskeycodes")
local CPUStripChart = require("CPUStripChart")

local width = 1024;
local height = 768;


local graphPort = size(width, height)

-- Create a few charts, just to flesh out local problems
-- eventually these will display individual cpu stats
-- as well as the combined stats
local cpuchart = CPUStripChart(0,0,640,100)
local cpuchart0 = CPUStripChart(0,104, 640, 100, 0)
local cpuchart1 = CPUStripChart(0,208, 640, 100, 1)
local cpuchart2 = CPUStripChart(0,312, 640, 100, 2)
local cpuchart3 = CPUStripChart(0,420, 640, 100, 3)

function loop()
	graphPort:clearToWhite();

	cpuchart:draw(graphPort);
	cpuchart0:draw(graphPort);
	cpuchart1:draw(graphPort);
	cpuchart2:draw(graphPort);
	cpuchart3:draw(graphPort);
end

loopInterval(1000/2)

run()