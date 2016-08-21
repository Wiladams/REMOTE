package.path = "../?.lua;"..package.path;

local SVGInteractor = require("tflremote.SVGInteractor")
local SVGStream = require("tflremote.SVGStream")
local SVGGeometry = require("tflremote.SVGGeometry")
local svg = SVGGeometry.Document;
local rect = SVGGeometry.Rect;
local circle = SVGGeometry.Circle;


local keycodes = require("tflremote.jskeycodes")


local width = 640;
local height = 480;
local mstream = size(width, height)
local ImageStream = SVGStream(mstream);



function mouseDown(activity)
	print("mouseDown")
	-- clear the screen
	graphPort:clearAll();
end

local function drawCircle(filename)
	ImageStream:reset();

	local doc = svg({
		version="1.1", 
		width = "12cm", height= "4cm", 
		viewBox="0 0 1200 400",
		
		-- Show outline of canvas using 'rect' element
		rect({x = 1;y = 1;width = 1198; height = 398;
			fill = "none";
			stroke = "blue";
			["stroke-width"] = 2;
		});

		circle({
  			fill="red", 
  			stroke="blue", 
  			["stroke-width"]=10, 
        	cx =600;
        	cy = 200;
        	r = 100;
        });
		
	})

	doc:write(ImageStream);
end


function frame()
	drawCircle();
end

run()
