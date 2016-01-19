
local function GetAlignedByteCount(width, bitsPerPixel, byteAlignment)
    local nbytes = width * (bitsPerPixel/8);
    return nbytes + (byteAlignment - (nbytes % byteAlignment)) % 4
end


local Surface = {}
setmetatable(Surface, {
	__call = function(self, ...)
		return self:new(...)
	end,
})
local Surface_mt = {
	__index = Surface;
}


local bitcount = 32;
local alignment = 4;

function Surface.init(self, width, height, data)
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
	setmetatable(obj, Surface_mt)

	return obj;
end

function Surface.new(self, width, height, data)
	data = data or ffi.new("int32_t[?]", width*height)
	return self:init(width, height, data)
end

return Surface