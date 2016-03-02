package.path = "../?.lua;"..package.path;

local NetInteractor = require("tflremote.sharer")



local colors = require("colors")
local keycodes = require("tflremote.jskeycodes")


local width = 320;
local height = 240;
local graphPort = size(width, height)

local targetarea = nil;
local yoffset = 0;



local redhalf = colors.RGBA(127, 0, 0, 255);
local greenhalf = colors.RGBA(0, 127, 0, 255);
local bluehalf = colors.RGBA(0, 0, 127, 255);

local areas = {
	{x = 10, y = 30, width = 100, height = 100, color = colors.red},
	{x = 110, y = 30, width = 100, height = 100, color = colors.green},
	{x = 210, y = 30, width = 100, height = 100, color = colors.blue},
}

local function rect_contains(rect, x, y)
	if x < rect.x or y < rect.y then return false; end

	if x >= rect.x + rect.width or y >= rect.y+rect.height then return false; end

	return true;
end

-- figure out which area the mouse location is in
local function whichRect(areas, x, y)
	for _, area in ipairs(areas) do
		if rect_contains(area, x, y) then
			return area;
		end
	end

	return nil;
end


function mouseMove(activity)
	targetarea = whichRect(areas, activity.x, activity.y)
end


function draw()
	--graphPort:rect(0,0,width, height, colors.black)
	graphPort:clearAll();

	for _, area in ipairs(areas) do
		graphPort:fillRect(area.x, area.y, area.width, area.height, area.color);
	end

	-- draw the current hover area in yellow
	if targetarea then
		graphPort:fillRect(targetarea.x, targetarea.y, targetarea.width, targetarea.height, colors.darkyellow)
	end

	graphPort:hline(10, yoffset, 100, redhalf);
	graphPort:hline(110, yoffset, 100, greenhalf);
	graphPort:hline(210, yoffset, 100, bluehalf);

end


function loop()
	yoffset = yoffset + 1
	if yoffset >= height then 
		yoffset = 0;
	end

	draw()
end


--loopInterval(1000,2)
run()
