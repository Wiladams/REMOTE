package.path = "../?.lua;"..package.path;

local NetInteractor = require("tflremote.sharer")


local colors = require("colors")

local width = 320;
local height = 240;
local graphPort = size(width, height)


function draw()
	--graphPort:rect(0,0,width, height, colors.black)
	graphPort:clearAll();
	
	-- convex polygon
	local verts = {
		{10,10},
		{10, 17},
		{20, 15},
	}
	graphPort:fillPolygon(verts, colors.red);


end

draw();

--[[
function loop()
	draw()
end
--]]


run()
