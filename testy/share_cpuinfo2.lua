package.path = "../?.lua;"..package.path;

--[[
	This application will display the CPU utilization Percentage, 
	The data and calculation is the same as what you would see running
	the 'top' command from a command line.
--]]

local ffi = require("ffi")
local NetInteractor = require("tflremote.sharer")

local stat = require("stat")
local colors = require("colors")


local CPUStripChart = require("CPUStripChart")

local width = 1024;
local height = 768;

-- read the stats once to determine how many cpus
-- we have
local cpustats = stat.decoder();
local numcpus = #cpustats.cpus
print("Num cpus: ", numcpus)

local chartwidth = 640;
local chartmargin = 2;
local chartheight = math.floor((height - chartmargin*(numcpus+1))/ (numcpus+1));
print("chartheight: ", chartheight, chartheight*numcpus);

local graphPort = size(width, height)
local charts = {}

-- Create a few charts, just to flesh out local problems
-- eventually these will display individual cpu stats
-- as well as the combined stats
local function createStripCharts()
	local xoffset = chartmargin;
	local yoffset = 0;

	-- first chart is the combined CPU stats
	table.insert(charts, CPUStripChart(xoffset,yoffset,chartwidth,chartheight))

	-- create an individual chart for each cpu
	local idx = 0;
	while (idx < numcpus) do
		yoffset = yoffset + chartheight + chartmargin;
		table.insert(charts, CPUStripChart(xoffset,yoffset,chartwidth,chartheight, idx))
		idx = idx + 1;
	end
end

local function draw(graphPort)
	for _, chart in ipairs(charts) do
		chart:draw(graphPort)
	end
end

function loop()
	graphPort:clearToWhite();
	--graphPort:fillRect(0,0,width, height, colors.red)
	draw(graphPort)
end

loopInterval(1000/4)
createStripCharts();

run()