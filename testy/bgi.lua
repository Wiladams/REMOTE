-- Emulating Borlage Graphics Interface
-- Some drawing routines and some colors
-- https://www.cs.colorado.edu/~main/bgi/doc/
-- 

local colors = require("colors")
local fonts = require("tflremote.embedded_raster_fonts")

local graphPort = nil;



-- Color Values
local colorValues = {
	{index=0, name = "BLACK", value=colors.RGBA(0,0,0)},
	{index=1, name = "BLUE", value=colors.RGBA(0,0,255)},
	{index=2, name = "GREEN", value=colors.RGBA(0,255,0)},
	{index=3, name = "CYAN", value=colors.RGBA(0,255,255)},
	{index=4, name = "RED", value=colors.RGBA(255,0,0)},
	{index=5, name = "MAGENTA", value=colors.RGBA(255, 0, 255)},
	{index=6, name = "BROWN", value=colors.RGBA(165,42,42)},
	{index=7, name = "LIGHTGRAY", value=colors.RGBA(211,211,211)},
	{index=8, name = "DARKGRAY", value=colors.RGBA(49,79,79)},
	{index=9, name = "LIGHTBLUE", value=colors.RGBA(172,216,230)},
	{index=10, name = "LIGHTGREEN", value=colors.RGBA(32,178,170)},
	{index=11, name = "LIGHTCYAN", value=colors.RGBA(224,255,255)},
	{index=12, name = "LIGHTRED", value=colors.RGBA(255,127,127)},
	{index=13, name = "LIGHTMAGENTA", value=colors.RGBA(255,127,255)},
	{index=14, name = "YELLOW", value=colors.RGBA(255,255,0)},
	{index=15, name = "WHITE", value=colors.RGBA(255,255,255)},
}

-- Values that are part of the graphics state
local cursorX = 0;
local cursorY = 0;
local colorIndex = 0;
local colorRGB = colors.white;
local fgColor = colors.white;
local bgColor = colors.black;
local currentFont = fonts.verdana12;


function RGBFromColorIndex(cindex)
	return colorValues[cindex+1].value
end

function initgraph(graphdriver, graphmode, pathtodriver)
	graphPort = graphdriver;
end

function cleardevice()
	graphPort:clearAll();
end

function closegraph()
end

function floodfill(x, y, cindex)
end

function getmaxcolor()
	return 15
end

function getmaxx()
	return graphPort.width-1;
end

function getmaxy()
	return graphPort.height-1;
end

function gotoxy(x, y)
	cursorX = x*8;
	cursorY = y*15;
end

function line(x1, y1, x2, y2)
	graphPort:line(x1, y1, x2, y2, fgColor)

	return true;
end

function outtextxy(x, y, text)
--	print("Height: ", font.height)
--	print("# Chars: ", font.num_chars)
--	print("String Width: ", font:stringWidth(str));

	currentFont:scan_str(graphPort, x, y, text, fgColor);
end

function printf(fmt, ...)
	local str = string.format(fmt, ...)
	outtextxy(cursorX, cursorY, str);
end

function putpixel(x, y, cindex)
	local c = RGBFromColorIndex(cindex) or colors.black;

	graphPort:setPixel(x, y, c);

	return true;
end

function rectangle(left, top, right, bottom)
	local width = right - left+1;
	local height = bottom - top+1;

	graphPort:frameRect(left, top, width, height, fgColor);
end

function setbkcolor(cindex)
	if cindex < 0 or cindex > getmaxcolor() then
		return false;
	end

	bgColor = RGBFromColorIndex(cindex);
	return true;
end

function setcolor(cindex)
	if cindex < 0 or cindex > getmaxcolor() then
		return false;
	end

	colorIndex = cindex;
	fgColor = RGBFromColorIndex(cindex);

	return true;
end

function setfillstyle(astyle, size)
	return false;
end

function setlinestyle(a, b, astyle)
	return false;
end

function settextstyle(...)
	return false;
end
