package.path = "../?.lua;"..package.path;

local NetInteractor = require("tflremote.sharer")


local colors = require("colors")

local width = 320;
local height = 240;
local graphPort = size(width, height)


function draw()
	--graphPort:rect(0,0,width, height, colors.black)
	graphPort:clearAll();
	
	-- colinear
	graphPort:fillTriangle(10,10,  50, 10,  200, 10,  colors.red)

	-- flat bottom
	graphPort:fillTriangle(10,20,  10, 200,  200, 200,  colors.green)

	-- obtuse
	graphPort:fillTriangle(30,10,  20,150,  230,75, colors.blue);

	-- flat top
	graphPort:fillTriangle(50,60,  120,60,  85,230, colors.lightgray);
	graphPort:frameTriangle(50,60,  120,60,  85,230, colors.black);
end

function loop()
	draw()
end



run()
