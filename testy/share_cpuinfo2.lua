package.path = "../?.lua;"..package.path;

--[[
	This application will display the CPU utilization Percentage, 
	The data and calculation is the same as what you would see running
	the 'top' command from a command line.
--]]

local ffi = require("ffi")
local NetInteractor = require("tflremote.sharer")

local stat = require("stat")
local CPUStripChart = require("CPUStripChart")

local width = 1024;
local height = 768;
local chartwidth = 640;
local chartheight = 100;


local graphPort = size(width, height)
local charts = {}

-- Create a few charts, just to flesh out local problems
-- eventually these will display individual cpu stats
-- as well as the combined stats
local function createStripCharts()
	-- read the stats once to determine how many cpus
	-- we have
	local cpustats = stat.decoder();
	local numcpus = #cpustats.cpus
	--print("Num cpus: ", numcpus)

	local xoffset = 0;
	local yoffset = 0;

	-- first chart is the combined CPU stats
	table.insert(charts, CPUStripChart(xoffset,yoffset,chartwidth,chartheight))

	-- create an individual chart for each cpu
	for idx = 0,numcpus-1 do
		yoffset = yoffset + chartheight + 4;
		table.insert(charts, CPUStripChart(xoffset,yoffset,chartwidth,chartheight, idx))
	end
end

local function draw(graphPort)
	for _, chart in ipairs(charts) do
		chart:draw(graphPort)
	end
end

function loop()
	graphPort:clearToWhite();

	draw(graphPort)
end

loopInterval(1000/10)
createStripCharts();

run()