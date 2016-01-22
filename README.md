# REMOTE
Remote Execution Might Offer True Excitement


This code was pulled out of one of the TINNSnips projects.  
It is a web server, which is meant to be attached to a framebuffer/app 
so that drawing can be viewed from a remote client.

Typical usage is to create an 'application' such as can be found in 
test/share_app1.lua

Within this app, you setup the screen, and setup your drawing routines
and start the application running.

```lua
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
```

A web page will be served up, with your imagery as the backing store.  In addition,
keyboard and mouse events are automatically tracked, and sent back to the application.
These events can be handled by simiply implementing various optional handler functions:

```lua
function mouseMove(activity)
	targetarea = whichRect(areas, activity.x, activity.y)
end

function keyPress(activity)
	print("keyPress: ", string.char(activity.which))
end

function keyDown(activity)
	print("keyDown: ", activity.keyCode, keycodes[activity.keyCode])
end
```

The mouse events are: mouseMove, mouseDown, mouseUp

The keyboard events are: keyDown, keyUp, keyPress

Dependencies
libpng-dev(el)