local ffi = require("ffi")


local function GetAlignedByteCount(width, bitsPerPixel, byteAlignment)
    local nbytes = width * (bitsPerPixel/8);
    return nbytes + (byteAlignment - (nbytes % byteAlignment)) % 4
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

function DrawingContext.setPixel(self, x, y, value)
	local offset = y*self.width+x;
	self.data[offset] = value;
end

function DrawingContext.hline(self, x, y, length, value)
	while length > 0 do
		self:setPixel(x+length-1, y, value)
		length = length-1;
	end
end

function DrawingContext.hspan(self, x, y, length, span)
	local dst = ffi.cast("char *", self.data) + (y*self.width*4)+(x*4)
	ffi.copy(dst, span, length*ffi.sizeof("int32_t"))
end

function DrawingContext.rect(self, x, y, width, height, value)
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

return DrawingContext