package.path = "../?.lua;"..package.path;

local NetInteractor = require("tflremote.sharer")



local colors = require("colors")
local keycodes = require("tflremote.jskeycodes")

local random = math.random

local width = 640;
local height = 480;
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

function mouseDown()
	-- clear the screen
	graphPort:clearAll();
end

function draw()
	-- draw a triangle
	local x1 = 200;
	local y1 = 10;

	local x2 = 10;
	local y2 = 300;

	local x3 = 390;
	local y3 = 300;

	graphPort:frameTriangle(x1, y1, x2, y2, x3, y3, colors.white)
end

function loop()
	-- draw some random lines
	for i=1, 20 do
		draw();
	end
end



run()
