package.path = "../?.lua;"..package.path;

local NetInteractor = require("tflremote.sharer")


local colors = require("colors")
local keycodes = require("tflremote.jskeycodes")

local random = math.random

local width = 640;
local height = 480;
local graphPort = size(width, height)


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
	for i=1, 20 do
		draw();
	end
end



run()
