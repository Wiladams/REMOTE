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

function CPUStripChart.init(self, params)
	local TitleMargin = 96;
	local numSamples = (params.width - TitleMargin)/4;
	--local numSamples = width - TitleMargin;
	--local numSamples = 100;

	local obj = {
		originX = params.originX or 0;
		originY = params.originY or 0;
		width = params.width;
		height = params.height;
		cpuid = params.cpuid;
		color = params.color or colors.red;

		numSamples = numSamples;
		loadnums = ffi.new("double[?]", numSamples);
		PreviousStats = nil;
		TitleMargin = TitleMargin;
		Font = fonts.verdana18_bold;
	}
	if params.cpuid then 
		obj.Name = "CPU "..tostring(params.cpuid); 
	else 
		obj.Name = "CPU" 
	end

	setmetatable(obj, CPUStripChart_mt)

	return obj;
end

function CPUStripChart.new(self, originX, originY, width, height, cpuid)
	return self:init(originX, originY, width, height, cpuid);
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
	if self.cpuid then
		--print("cpuid: ", self.cpuid)
		local cpuStats = newStats.cpus[self.cpuid+1];
		newStats = cpuStats;
	else
		--print("allcpus")
		newStats = newStats.allcpus;
	end

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
	
	-- draw line for each value
	local i = 0;
	while i < self.numSamples-2 do
		local value1 = self.loadnums[i];
		local value2 = self.loadnums[i+1];

		local yval1 = RANGEMAP(value1, 0, 1.0, self.originY+self.height-2, self.originY+1)
		local xval1 = RANGEMAP(i, 0, self.numSamples-1, self.originX + self.TitleMargin, self.originX+self.width-2)

		local yval2 = RANGEMAP(value2, 0, 1.0, self.originY+self.height-2, self.originY+1)
		local xval2 = RANGEMAP(i+1, 0, self.numSamples-1, self.originX + self.TitleMargin, self.originX+self.width-2)+1

		graphPort:line(xval1, yval1, xval2, yval2, self.color)

--print(xval1, yval1, xval2, yval2)

		i = i + 1;
	end


	-- draw a border around the samples
	graphPort:frameRect(self.originX + self.TitleMargin, self.originY, 
		self.width - self.TitleMargin, self.height, 
		colors.blue);

	-- put in the title
	--self.Font:scan_str(graphPort, self.originX+4, self.originY+4, "CPU", colors.blue)
	graphPort:fillText(self.originX+4, self.originY+4, self.Name, self.Font, colors.blue);
end

return CPUStripChart
