local ffi = require("ffi")
local bit = require("bit")
local rshift = bit.rshift

local abs = math.abs;
local floor = math.floor;

local function GetAlignedByteCount(width, bitsPerPixel, byteAlignment)
    local nbytes = width * (bitsPerPixel/8);
    return nbytes + (byteAlignment - (nbytes % byteAlignment)) % 4
end

function RANGEMAP(x, a, b, c, d)
	return c + ((x-a)/(b-a)*(d-c))
end

local function CLIP(x, a, b)
	if x < a then return a end
	if x > b then return b end

	return x;
end

local function sgn(x)
	if x < 0 then return -1 end
	if x > 0 then return 1 end

	return 0
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


local bitcount = 32;
local alignment = 4;

function DrawingContext.init(self, width, height, data)
	rowsize = GetAlignedByteCount(width, bitcount, alignment);
    pixelarraysize = rowsize * math.abs(height);

	local obj = {
		width = width;
		height = height;
		bitcount = bitcount;
		data = data;

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
	ffi.fill(ffi.cast("char *", self.data), self.width*self.height*4)
end

function DrawingContext.clearToWhite(self)
	ffi.fill(ffi.cast("char *", self.data), self.width*self.height*4, 255)
end

function DrawingContext.fillText(self, x, y, text, font, value)
	font:scan_str(self, x, y, text, value)
end

function DrawingContext.setPixel(self, x, y, value)
	local offset = y*self.width+x;
	self.data[offset] = value;
end

function DrawingContext.vline(self, x, y, length, value)
	local offset = y*self.width+x;
	while length > 0 do
		self.data[offset] = value;
		offset = offset + self.width;
		length = length - 1;
	end
end

function DrawingContext.hline(self, x, y, length, value)
	local offset = y*self.width+x;
	while length > 0 do
		self.data[offset] = value;
		offset = offset + 1;
		length = length-1;
	end
end

function DrawingContext.hspan(self, x, y, length, span)
	local dst = ffi.cast("char *", self.data) + (y*self.width*4)+(x*4)
	ffi.copy(dst, span, length*ffi.sizeof("int32_t"))
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

	self:setPixel(x1, y1, value);

	if (dxabs >= dyabs) then -- the line is more horizontal than vertical
		for i = 0, dxabs-1 do
			y = y+dyabs;
			if (y >= dxabs) then
				y = y - dxabs;
				py = py + sdy;
			end
			px = px + sdx;
			self:setPixel(px, py, value);
		end
	else -- the line is more vertical than horizontal
	
		for i = 0, dyabs-1 do
		
			x = x + dxabs;
			if (x >= dyabs) then
				x = x - dyabs;
				px = px + sdx;
			end

			py = py + sdy;
			self:setPixel( px, py, value);
		end
	end
end

function DrawingContext.fillRect(self, x, y, width, height, value)
	local length = width;
	while length > 0 do
		self.SpanBuffer[length-1] = value;
		length = length-1;
	end

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