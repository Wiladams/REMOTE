package.path = "../?.lua;"..package.path;

local NetInteractor = require("tflremote.sharer")



local colors = require("colors")
local keycodes = require("tflremote.jskeycodes")


local width = 320;
local height = 240;
local graphPort = size(width, height)



local redhalf = colors.RGBA(127, 0, 0, 255);
local greenhalf = colors.RGBA(0, 127, 0, 255);
local bluehalf = colors.RGBA(0, 0, 127, 255);

function keyPress(activity)
	print("keyPress: ", string.char(activity.which))
end

function keyDown(activity)
	print("keyDown: ", activity.keyCode, keycodes[activity.keyCode])
end

local yoffset = 0;

function draw()
	--graphPort:rect(0,0,width, height, colors.black)
	graphPort:clearAll();


	graphPort:rect(10, 30, 100, 100, colors.red)
	graphPort:rect(110, 30, 100, 100, colors.green)
	graphPort:rect(210, 30, 100, 100, colors.blue)

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



run()
