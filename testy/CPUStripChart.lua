package.path = "../?.lua;"..package.path;

--[[
	This application will display the CPU utilization Percentage, 
	The data and calculation is the same as what you would see running
	the 'top' command from a command line.
--]]

local ffi = require("ffi")

local colors = require("colors")
local stat = require("stat")
local fonts = require("tflremote.embedded_raster_fonts")

-- Reference for CPU_Percentage calculation
-- http://stackoverflow.com/questions/23367857/accurate-calculation-of-cpu-usage-given-in-percentage-in-linux
--

local CPUStripChart = {}
setmetatable(CPUStripChart, {
	__call = function(self, ...)
		return self:new(...);
	end,
})

local CPUStripChart_mt = {
	__index = CPUStripChart;
}

function CPUStripChart.init(self, originX, originY, width, height, cpuid)
	local numSamples = 100;

	local obj = {
		originX = originX;
		originY = originY;
		width = width;
		height = height;
		cpuid = cpuid;

		numSamples = numSamples;
		loadnums = ffi.new("double[?]", numSamples);
		PreviousStats = nil;
		TitleMargin = 96;
		Font = fonts.verdana18_bold;
	}
	setmetatable(obj, CPUStripChart_mt)

	return obj;
end

function CPUStripChart.new(self, originX, originY, width, height, cpuid)
	return self:init(originX, originY, width, height, graphPort);
end

function CPUStripChart.shiftleft(self)
	local offset = 0
	while (offset <= self.numSamples-2) do
		self.loadnums[offset] = self.loadnums[offset+1]
		offset = offset + 1;
	end		
end

function CPUStripChart.sample(self)
	-- get the latest load number
	-- newest number goes into highest position
	local newStats = stat.decoder();
	
	-- Calculate current collection percentages
	newStats.Idle = newStats.idle + newStats.iowait;
	newStats.NonIdle = newStats.user + newStats.nice + 
		newStats.system + newStats.irq + newStats.softirq +
		newStats.steal;
	newStats.Total = newStats.Idle + newStats.NonIdle;

	if not self.PreviousStats then
		self.PreviousStats = newStats;
		return false;
	end

	-- Calculate difference between two collections
	local totald = newStats.Total - self.PreviousStats.Total;
	local idled = newStats.Idle - self.PreviousStats.Idle;

	local CPU_Percentage = (totald - idled)/totald;

	self.PreviousStats = newStats;

	-- shift everything from highest down one
	self:shiftleft()

	self.loadnums[self.numSamples-1] = CPU_Percentage;

	return true;
end

function CPUStripChart.draw(self, graphPort)

	if not self:sample() then
		return ;
	end

	-- create the overall background
	graphPort:fillRect(self.originX, self.originY, self.width, self.height, colors.lightgray);

	-- draw the cpu percentage values
	graphPort:fillRect(self.originX+self.TitleMargin, self.originY, self.width-self.TitleMargin, self.height, colors.white)
	-- draw vertical line for each value
	for i=0,self.numSamples-1 do
		local yval = RANGEMAP(self.loadnums[i], 0, 1.0, self.originY+self.height-1, self.originY)
		local xval = RANGEMAP(i, 0, self.numSamples-1, self.originX + self.TitleMargin, self.originX+self.width-1)

		--print("yval: ", yval)
		graphPort:line(xval, self.originY+self.height-1, xval, yval, colors.black)
	end

	-- draw a border around the samples
	graphPort:frameRect(self.originX + self.TitleMargin, self.originY, 
		self.width - self.TitleMargin, self.height, 
		colors.blue);

	-- put in the title
	self.Font:scan_str(graphPort, self.originX+4, self.originY+4, "CPU", colors.blue)
end

return CPUStripChart
