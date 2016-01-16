package.path = "../?.lua;"..package.path;

local DrawingContext = require("tflremote.DrawingContext")
local FileStream = require("filestream")
local bmp = require("tflremote.bmpcodec")
local colors = require("colors")
local fonts = require("embedded_raster_fonts");
local EmbeddedFont = require("EmbeddedFont");


local gse4x6_data = fonts.gse4x6;
local verdana14 = fonts.verdana14;


--local font1 = EmbeddedFont:new(gse4x6_data)
local font1 = EmbeddedFont:new(verdana14)

print("Height: ", font1.height)
print("# Chars: ", font1.num_chars)
print("String Width: ", font1:stringWidth("Hello, World"));

-- Create a buffer
local pb = DrawingContext:new(320,240);

-- draw a string into it
font1:scan_str(pb, 20, 20, "Hello, World", colors.white)
--font1:scan_str(pb, 20, 20, "Hello", colors.red)

-- write it out to a .bmp file
local fs = FileStream.open("test_embedded_font.bmp")
bmp.write(fs, pb)
fs:close();
