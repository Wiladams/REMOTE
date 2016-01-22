local ffi = require("ffi")
local zlib_ffi = require("zlib_ffi")

local ZLIB_VERSION = zlib_ffi.zlibVersion();

local function deflateInit(strm, level)
    zlib_ffi.deflateInit_(strm, level, ZLIB_VERSION, ffi.sizeof(ffi.typeof("z_stream")))
end

local function inflateInit(strm)
    zlib_ffi.inflateInit_(strm, ZLIB_VERSION, ffi.sizeof(ffi.typeof("z_stream")))
end

local function deflateInit2(strm, level, method, windowBits, memLevel, strategy)
    zlib_ffi.deflateInit2_(strm,level,method,windowBits,memLevel,
                      strategy, ZLIB_VERSION, ffi.sizeof(ffi.typeof("z_stream")))
end

local function inflateInit2(strm, windowBits)
    zlib_ffi.inflateInit2_(strm, windowBits, ZLIB_VERSION,
                    ffi.sizeof(ffi.typeof("z_stream")))
end

local function inflateBackInit(strm, windowBits, window)
    zlib_ffi.inflateBackInit_(strm, windowBits, window,
                      ZLIB_VERSION, ffi.sizeof(ffi.typeof("z_stream")))
end

local function compress(txt, txtlen)
	txtlen = txtlen or #txt

	local n = zlib_ffi.compressBound(#txt)
	local buf = ffi.new("uint8_t[?]", n)
	local buflen = ffi.new("unsigned long[1]", n)
	local res = zlib_ffi.compress2(buf, buflen, txt, txtlen, 6)
  	assert(res == 0)
	
	return ffi.string(buf, buflen[0])
end

return {
	Lib_z = zlib_ffi;

	deflateInit = deflateInit;
	deflateInit2 = deflateInit2;

	inflateInit = inflateInit;
	inflateInit2 = inflateInit2;
	inflateBackInit = inflateBackInit;

	VERSION = ffi.string(ZLIB_VERSION);
}
