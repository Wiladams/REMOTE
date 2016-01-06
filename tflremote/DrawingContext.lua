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
	}
	setmetatable(obj, DrawingContext_mt)

	return obj;
end

function DrawingContext.new(self, width, height, data)
	data = data or ffi.new("int32_t[?]", width*height*4)
	return self:init(width, height, data)
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

function DrawingContext.rect(self, x, y, width, height, value)
	while height > 0 do
		self:hline(x, y+height-1, width, value)
		height = height - 1;
	end
end

return DrawingContext