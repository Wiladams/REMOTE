package.path = "../?.lua;"..package.path;

local ffi = require("ffi")

local DrawingContext = require("tflremote.DrawingContext")
local FileStream = require("filestream")
local bmp = require("tflremote.bmpcodec")
local fonts = require("tflremote.embedded_raster_fonts");
local colors = require("colors")



local gse4x6 = fonts.gse4x6;
local verdana14 = fonts.verdana14;
local verdana18_bold = fonts.verdana18_bold;

-- Create a buffer
local pb = DrawingContext:new(640,480);
pb:clearToWhite();


local function outtext(x, y, str, font, color)
	print("Height: ", font.height)
	print("# Chars: ", font.num_chars)
	print("String Width: ", font:stringWidth(str));

	font:scan_str(pb, x, y, str, color);
end

local text = "Hello, World!";

local messages = {
	{"gse4x6 - Hello, World", gse4x6},
	{"mcs7x12_mono_high - The quick brown fox jumped over the lazy dogs back", fonts.mcs7x12_mono_high},
	{"verdana14 - The quick brown fox jumped over the lazy dogs back", verdana14},
	{"verdana18_bold - The quick brown fox jumped over the lazy dogs back", verdana18_bold},
}

local basex = 10;
local basey = 10;
local vgap = 4;

local cursorx = 10;
local cursory = 10;

for _, msg in ipairs(messages) do
	outtext(cursorx, cursory, msg[1], msg[2], colors.black);
	cursorx = 10;
	cursory = cursory + msg[2].height + vgap;
end



-- write it out to a .bmp file
local fs = FileStream.open("test_embedded_font.bmp")
bmp.write(fs, pb)
fs:close();
