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
	local metrics = font:measureText(str);
	print("Text, Width/Height/Baseline: ", metrics.width, metrics.height, metrics.baseline)

	font:scan_str(pb, x, y, str, color);
end

local text = "Hello, World!";

local messages = {
	{text = "gse4x6 - The quick brown fox jumped over the lazy dogs back", font = fonts.gse4x6},
	{text = "gse8x16 - The quick brown fox jumped over the lazy dogs back", font = fonts.gse8x16},
	{text = "gse8x16_bold - The quick brown fox jumped over the lazy dogs back", font = fonts.gse8x16_bold},

	{text = "mcs5x10_mono - The quick brown fox jumped over the lazy dogs back", font = fonts.mcs5x10_mono},
	{text = "mcs5x11_mono - The quick brown fox jumped over the lazy dogs back", font = fonts.mcs5x11_mono},
	{text = "mcs6x10_mono - The quick brown fox jumped over the lazy dogs back", font = fonts.mcs6x10_mono},
	{text = "mcs6x11_mono - The quick brown fox jumped over the lazy dogs back", font = fonts.mcs6x11_mono},
	{text = "mcs7x12_mono_high - The quick brown fox jumped over the lazy dogs back", font = fonts.mcs7x12_mono_high},
	{text = "mcs7x12_mono_low - The quick brown fox jumped over the lazy dogs back", font = fonts.mcs7x12_mono_low},
	
	{text = "verdana12 - The quick brown fox jumped over the lazy dogs back", font = fonts.verdana12},
	{text = "verdana13 - The quick brown fox jumped over the lazy dogs back", font = fonts.verdana13},
	{text = "verdana14 - The quick brown fox jumped over the lazy dogs back", font = fonts.verdana14},
	{text = "verdana16 - The quick brown fox jumped over the lazy dogs back", font = fonts.verdana16},
	{text = "verdana17 - The quick brown fox jumped over the lazy dogs back", font = fonts.verdana17},
	{text = "verdana18 - A quick brown fox jumps over a lazy dog", font = fonts.verdana18},
	{text = "verdana18_bold - The quick brown fox jumped over the lazy dogs back", font = fonts.verdana18_bold},
}

local vgap = 4;

local cursorx = 10;
local cursory = 10;

for _, msg in ipairs(messages) do

	outtext(cursorx, cursory, msg.text, msg.font, colors.black);
	local metrics = msg.font:measureText(msg.text);
	

	pb:frameRect(cursorx, cursory, metrics.width, metrics.height, colors.blue);
	pb:hline(cursorx, cursory+metrics.height-metrics.baseline, metrics.width, colors.red);
	cursorx = 10;
	cursory = cursory + msg.font.height + vgap;
end



-- write it out to a .bmp file
local fs = FileStream.open("test_embedded_font.bmp")
bmp.write(fs, pb)
fs:close();
