local ffi = require("ffi")
local bit = require("bit")
local rshift = bit.rshift

local abs = math.abs;
local floor = math.floor;

local maths = require("tflremote.maths")
local sgn = maths.sgn;

local Surface = require("tflremote.Surface")

--local int16_t = ffi.typeof("int16_t")
--local uint32_t = ffi.typeof("uint32_t")
--local int32_t = ffi.typeof("int32_t")

local int16_t = tonumber;
local int32_t = tonumber;
local uint32_t = tonumber;


--[[
	Some useful utility routines
--]]
-- given two points, return them in order
-- where the 'y' value is the lowest first
local function order2(pt1, pt2)
	if pt1.y < pt2.y then
		return pt1, pt2;
	end

	return pt2, pt1;
end

-- given three points, reorder them from lowest
-- y value to highest.  Good for drawing triangles
local function order3(a, b, c)
	local a1,b1 = order2(a,b)
	local b1,c = order2(b1,c)
	local a, b = order2(a1, b1)

	return a, b, c
end


local DrawingContext = {}
setmetatable(DrawingContext, {
	__call = function(self, ...)
		return self:new(...)
	end,
})
local DrawingContext_mt = {
	__index = DrawingContext;
}



function DrawingContext.init(self, width, height, data)
	--rowsize = GetAlignedByteCount(width, bitcount, alignment);
    --pixelarraysize = rowsize * math.abs(height);
    local surf = Surface(width, height, data);

	local obj = {
		surface = surf;
		width = width;
		height = height;
		--bitcount = bitcount;
		--data = data;

		rowsize = rowsize;
		pixelarraysize = pixelarraysize;

		SpanBuffer = ffi.new("int32_t[?]", width);
	}
	setmetatable(obj, DrawingContext_mt)

	return obj;
end

function DrawingContext.new(self, width, height, data)
	data = data or ffi.new("int32_t[?]", width*height)
	return self:init(width, height, data)
end


function DrawingContext.clearAll(self)
	self.surface:clearAll();
end

function DrawingContext.clearToWhite(self)
	self.surface:clearToWhite();
end

function DrawingContext.fillText(self, x, y, text, font, value)
	font:scan_str(self.surface, x, y, text, value)
end



--[[
	Filling a triangle is a specialization of filling a convex
	polygon.  Since we break polygons down into triangles, we
	implement the fillTriangle as the base, rather than implementing
	the triangle as a polygon.
--]]
function DrawingContext.fillTriangle(self, x1, y1, x2, y2, x3, y3, color)

	-- sort vertices, such that a == y with lowest number (top)
	local pt1, pt2, pt3 = order3({x=x1,y=y1}, {x=x2,y=y2}, {x=x3,y=y3})


	local a, b, y, last = 0,0,0,0;

	-- Handle the case where points are colinear (all on same line)
	-- could calculate distance of second point to the line formed
	-- from points 1 and 3
	if (pt1.y == pt3.y) then 
		a = pt1.x;
		b = pt1.x;

		if (pt2.x < a)  then 
			a = pt2.x;
		elseif (pt2.x > b) then 
			b = pt2.x;
		end

		if (pt3.x < a) then 
			a = pt3.x;
		elseif (pt3.x > b) then 
			b = pt3.x;
		end

		self.surface:hline(a, pt1.y, b - a + 1, color);

		return;
	end


	local dx01 = int16_t(pt2.x - pt1.x);
	local dy01 = int16_t(pt2.y - pt1.y);
	local dx02 = int16_t(pt3.x - pt1.x);
	local dy02 = int16_t(pt3.y - pt1.y);
	local dx12 = int16_t(pt3.x - pt2.x);
	local dy12 = int16_t(pt3.y - pt2.y);
	
	local sa = int32_t(0);
	local sb = int32_t(0);

	-- For upper part of triangle, find scanline crossings for segments
	-- 0-1 and 0-2. If y1=y2 (flat-bottomed triangle), the scanline y1
	-- is included here (and second loop will be skipped, avoiding a /0
	-- error there), otherwise scanline y1 is skipped here and handled
	-- in the second loop...which also avoids a /0 error here if y0=y1
	-- (flat-topped triangle).
	if (pt2.y == pt3.y) then 
		last = pt2.y; -- Include y1 scanline
	else 
		last = pt2.y - 1; -- Skip it
	end
	
	y = pt1.y;
	while y <= last do 
		a = pt1.x + sa / dy01;
		b = pt1.x + sb / dy02;
		sa = sa + dx01;
		sb = sb + dx02;
		--[[ longhand:
		a = x0 + (x1 - x0) * (y - y0) / (y1 - y0);
		b = x0 + (x2 - x0) * (y - y0) / (y2 - y0);
		--]]
		
		if (a > b) then
			a, b = b, a;
		end

		self.surface:hline(a, y, b - a + 1, color);
		y = y + 1;
	end


	-- For lower part of triangle, find scanline crossings for segments
	-- 0-2 and 1-2. This loop is skipped if y1=y2.
	sa = dx12 * (y - pt2.y);
	sb = dx02 * (y - pt1.y);
	while y < pt3.y do 

		a = pt2.x + sa / dy12;
		b = pt1.x + sb / dy02;
		sa = sa + dx12;
		sb = sb + dx02;
		--[[ longhand:
		a = x1 + (x2 - x1) * (y - y1) / (y2 - y1);
		b = x0 + (x2 - x0) * (y - y0) / (y2 - y0);
		--]]
		if (a > b) then 
			a, b = b, a;
		end

		self.surface:hline(a, y, b - a + 1, color);

		y = y + 1;
	end
end

function DrawingContext.frameTriangle(self, x1, y1, x2, y2, x3, y3, color)

	-- sort vertices, such that a == y with lowest number (top)
	local pt1, pt2, pt3 = order3({x=x1,y=y1}, {x=x2,y=y2}, {x=x3,y=y3})

	self:line(pt1.x, pt1.y, pt2.x, pt2.y, color);
	self:line(pt2.x, pt2.y, pt3.x, pt3.y, color);
	self:line(pt3.x, pt3.y, pt1.x, pt1.y, color);
end

function DrawingContext.setPixel(self, x, y, value)
	self.surface:pixel(x, y, value)
end

function DrawingContext.vline(self, x, y, length, value)
	local offset = y*self.width+x;
	while length > 0 do
		self.surface.data[offset] = value;
		offset = offset + self.width;
		length = length - 1;
	end
end

function DrawingContext.hline(self, x, y, length, value)
	self.surface:hline(x, y, length, value);
end

function DrawingContext.hspan(self, x, y, length, span)
	self.surface:hspan(x, y, length, span)
end


-- Bresenham simple line drawing
function DrawingContext.line(self, x1, y1, x2, y2, value)
	x1 = floor(x1);
	y1 = floor(y1);
	x2 = floor(x2);
	y2 = floor(y2);

	local dx = x2 - x1;      -- the horizontal distance of the line
	local dy = y2 - y1;      -- the vertical distance of the line
	local dxabs = abs(dx);
	local dyabs = abs(dy);
	local sdx = sgn(dx);
	local sdy = sgn(dy);
	local x = rshift(dyabs, 1);
	local y = rshift(dxabs, 1);
	local px = x1;
	local py = y1;

	self.surface:pixel(x1, y1, value);

	if (dxabs >= dyabs) then -- the line is more horizontal than vertical
		for i = 0, dxabs-1 do
			y = y+dyabs;
			if (y >= dxabs) then
				y = y - dxabs;
				py = py + sdy;
			end
			px = px + sdx;
			self.surface:pixel(px, py, value);
		end
	else -- the line is more vertical than horizontal
		for i = 0, dyabs-1 do
			x = x + dxabs;
			if (x >= dyabs) then
				x = x - dyabs;
				px = px + sdx;
			end

			py = py + sdy;
			self.surface:pixel( px, py, value);
		end
	end
end

function DrawingContext.fillRect(self, x, y, width, height, value)
	local length = width;

	-- fill the span buffer with the specified
	while length > 0 do
		self.SpanBuffer[length-1] = value;
		length = length-1;
	end

	-- use hspan, since we're doing a srccopy, not an 'over'
	while height > 0 do
		self:hspan(x, y+height-1, width, self.SpanBuffer)
		height = height - 1;
	end
end

function DrawingContext.frameRect(self, x, y, width, height, value)
	-- two horizontals
	self:hline(x, y, width, value);
	self:hline(x, y+height-1, width, value);

	-- two verticals
	self:vline(x, y, height, value);
	self:vline(x+width-1, y, height, value);
end

return DrawingContext