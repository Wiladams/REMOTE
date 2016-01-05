-- LocalScreen.lua

local MemoryStream = require("memorystream");
local BinaryStream = require("binarystream");


local ScreenWidth = User32.GetSystemMetrics(User32.FFI.CXSCREEN);
local ScreenHeight = User32.GetSystemMetrics(User32.FFI.CYSCREEN);

local captureWidth = ScreenWidth;
local captureHeight = ScreenHeight;

local ImageWidth = captureWidth * 1.0;
local ImageHeight = captureHeight * 1.0;
local ImageBitCount = 16;


local ScreenCapture = {}
setmetatable(ScreenCapture, {
	__call = function(self, ...)
		return self:create(...);
	end,
});

local ScreenCapture_mt = {
	__index = ScreenCapture;
}


--print("== ScreenCapture ==")
--print("Screen: ", ScreenWidth, ScreenHeight);
--print(" Image: ", ImageWidth, ImageHeight);
--print("-------------------")

ScreenCapture.init = function(self, params)
	params = params or {}

    -- source parameters
    params.Frame = 0;
    params.XOriginSrc = params.ScreenXOrigin or 0;
    params.YOriginSrc = params.ScreenYOrigin or 0;
    params.WidthSrc = params.WidthSrc or ScreenWidth;
    params.HeightSrc = params.HeightSrc or ScreenHeight;
    
    -- destination parameters
    params.BitCount = params.BitCount or ImageBitCount;
	params.XOriginDest = params.CaptureXOrigin or 0;
    params.YOriginDest = params.CaptureYOrigin or 0;
    params.WidthDest = params.WidthDest or ImageWidth;
    params.HeightDest = params.HeightDest or ImageHeight;

	params.hdcScreen = GDI32.CreateDCForDefaultDisplay();

	-- The bitmap the screen will be copied into
    params.hbmScreen = GDIDIBSection(params.WidthDest, params.HeightDest, params.BitCount);


	setmetatable(params, ScreenCapture_mt);

  	local width = params.hbmScreen.Info.bmiHeader.biWidth;
  	local height = params.hbmScreen.Info.bmiHeader.biHeight;
  	local rowsize = GDI32.GetAlignedByteCount(width, params.BitCount, 4);
  	params.pixelarraysize = rowsize * math.abs(height);
    params.pixeloffset = 54;
    params.filesize = 54+params.pixelarraysize;

    local streamsize = GDI32.GetAlignedByteCount(params.filesize, 8, 4);
	
	params.CapturedStream = MemoryStream(streamsize);

print("== Screen Capture ==")
print("Source: ", params.XOriginSrc, params.YOriginSrc, params.WidthSrc, params.HeightSrc);
print("  Dest: ", params.XOriginDest, params.YOriginDest, params.WidthDest, params.HeightDest);
print("--------------------");

	return params;
end

ScreenCapture.create = function(self, ...)
	return self:init(...);
end


ScreenCapture.getCurrentBitmap = function(self, srcWidth, srcHeight, srcXOrigin, srcYOrigin)
  	local ROP = GDI32.FFI.SRCCOPY;

    local status = GDI32.Lib.StretchBlt(self.hbmScreen.hDC.Handle,
      self.XOriginDest,self.YOriginDest,self.WidthDest,self.HeightDest,
      self.hdcScreen.Handle,
      self.XOriginSrc,self.YOriginSrc,self.WidthSrc,self.HeightSrc,
      ROP);

	self.Frame = self.Frame + 1;
	--print("Frame: ", self.Frame);


    --self.hbmScreen.hDC:Flush();

    return self.hbmScreen;
end

ScreenCapture.captureScreen = function(self)
	--print("printImage")
	local dibsec = self:getCurrentBitmap();

    self.CapturedStream:Seek(0);

    local bs = BinaryStream:new(self.CapturedStream);

--print("FILESIZE: ", self.filesize);
--print("PIXEL OFF:", self.pixeloffset);

	-- Write File Header
    bs:writeByte(string.byte('B'))
    bs:writeByte(string.byte('M'))
    bs:writeInt32(self.filesize);
    bs:writeInt16(0);
    bs:writeInt16(0);
    bs:writeInt32(self.pixeloffset);

    -- Bitmap information header
    bs:writeInt32(40);
    bs:writeInt32(dibsec.Info.bmiHeader.biWidth);
    bs:writeInt32(dibsec.Info.bmiHeader.biHeight);
    bs:writeInt16(dibsec.Info.bmiHeader.biPlanes);
    bs:writeInt16(dibsec.Info.bmiHeader.biBitCount);
    bs:writeInt32(dibsec.Info.bmiHeader.biCompression);
    bs:writeInt32(dibsec.Info.bmiHeader.biSizeImage);
    bs:writeInt32(dibsec.Info.bmiHeader.biXPelsPerMeter);
    bs:writeInt32(dibsec.Info.bmiHeader.biYPelsPerMeter);
    bs:writeInt32(dibsec.Info.bmiHeader.biClrUsed);
    bs:writeInt32(dibsec.Info.bmiHeader.biClrImportant);

    -- Write the actual pixel data
    self.CapturedStream:writeBytes(dibsec.Pixels, self.pixelarraysize, 0);
end


return ScreenCapture;
