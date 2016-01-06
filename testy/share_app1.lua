package.path = "../?.lua;"..package.path;

local NetInteractor = require("tflremote.sharer")
local colors = require("colors")

local width = 320;
local height = 240;

local graphPort = size(width, height)
local yoffset = 0;


function draw()
	graphPort:rect(0,0,width, height, colors.black)

	graphPort:setPixel(10, 10, colors.white)

	graphPort:hline(10, yoffset, 100, colors.red)
	graphPort:hline(110, yoffset, 100, colors.green)
	graphPort:hline(210, yoffset, 100, colors.blue)

	graphPort:rect(10, 30, 100, 100, colors.red)
	graphPort:rect(110, 30, 100, 100, colors.green)
	graphPort:rect(210, 30, 100, 100, colors.blue)
end

function loop()
	yoffset = yoffset + 1
	if yoffset >= height then 
		yoffset = 0;
	end

	draw()
end

run()
