package.path = "../?.lua;"..package.path;

local NetInteractor = require("tflremote.sharer")



local colors = require("colors")
local keycodes = require("tflremote.jskeycodes")

local random = math.random

local width = 320;
local height = 240;
local graphPort = size(width, height)



function mouseDown(activity)
	print("mouseDown")
	-- clear the screen
	graphPort:clearAll();
end

function drawRandomLine()
	local x1 = random(width)
	local y1 = random(height)
	local x2 = random(width)
	local y2 = random(height)

	local c = colors.RGBA(random(255), random(255), random(255))

	graphPort:line(x1, y1, x2, y2, c);

end

function loop()
	-- draw some random lines
	for i=1, 20 do
		drawRandomLine();
	end
end

run()
