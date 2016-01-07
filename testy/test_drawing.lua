package.path = "../?.lua;"..package.path;

--test_drawing.lua

local bmp = require("tflremote.bmpcodec")
local DrawingContext = require("tflremote.DrawingContext")
local colors = require("colors")
local FileStream = require("filestream")

local awidth = 640
local aheight = 480;

local graphPort = DrawingContext(awidth, aheight)
local graphParams = bmp.setup(awidth, aheight, 32, graphPort.data);


function draw()
	graphPort:setPixel(10, 10, colors.white)

	graphPort:hline(10, 20, 100, colors.white)

	graphPort:rect(10, 30, 100, 100, colors.red)
	graphPort:rect(110, 30, 100, 100, colors.green)
	graphPort:rect(210, 30, 100, 100, colors.blue)
end

function save()
	print("save(): ")

	-- generate a .bmp file
	local fs = FileStream.open("test_drawing.bmp")
	bmp.write(fs, graphParams)
	fs:close();
end

draw()
save()
