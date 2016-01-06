local ffi = require("ffi")
local turbo = require("turbo")

local colors = require("colors")
local bmp = require("bmpcodec")
local DrawingContext = require("DrawingContext")
local MemoryStream = require("memorystream")

--[[
  Application Variables
--]]
local ScreenWidth = 640;
local ScreenHeight = 480;


local captureWidth = ScreenWidth;
local captureHeight = ScreenHeight;

local ImageWidth = captureWidth * 1.0;
local ImageHeight = captureHeight * 1.0;
local ImageBitCount = 32;

local serviceport = tonumber(arg[1]) or 8080

local awidth = 640
local aheight = 480;

local graphPort = DrawingContext(ScreenWidth, ScreenHeight)
local graphParams = bmp.setup(ScreenWidth, ScreenHeight, 32, graphPort.data);
local strm = MemoryStream:new(graphParams.streamsize);

local yoffset = 0;

function draw()
  graphPort:rect(0,0,awidth, aheight, colors.black);

  graphPort:rect(10, 30, 100, 100, colors.red)
  graphPort:rect(110, 30, 100, 100, colors.green)
  graphPort:rect(210, 30, 100, 100, colors.blue)

  graphPort:hline(10, yoffset, 100, colors.white)
  yoffset = yoffset + 1;
  if yoffset >= aheight then
    yoffset = 2;
  end

end

function writeImage(graphParams)
  -- generate a .bmp file
  strm:seek(0);
  bmp.write(strm, graphParams)
  
  return strm;
end


local DefaultHandler = class("DefaultHandler", turbo.web.RequestHandler)
function DefaultHandler:get(...)
  self:write("Example Handler: Hello world!")
end


local ScreenHandler = class("ScreenHandler", turbo.web.RequestHandler)
function ScreenHandler:get(...)
  --turbo.log.devel("ScreenHandler: "..self.host)
  draw();
  local strm = writeImage(graphParams);

  --print("STREAM: ", strm:position())
  -- write headers appropriate for a bmp image
  self:set_status(200)
  self:add_header("Content-Type", "image/bmp")
  self:add_header("Content-Length", tostring(strm:position()))
  self:add_header("Connection", "close")
  --self:add_header("Connection", "Keep-Alive")
  
  self:write(ffi.string(strm.Buffer, strm:position()));
end


local StartupHandler = class("StartupHandler", turbo.web.RequestHandler)

local startupContent = nil;

local function loadStartupContent(self)
    -- load the file into memory
    local fs, err = io.open("viewcanvas.htm")
    --local fs, err = io.open("viewscreen_simple.htm")
    --local fs, err = io.open("viewscreen.htm")
    --local fs, err = io.open("sharescreen.htm")

    if not fs then
      self:set_status(500)

      return true
    end
    
    local content = fs:read("*all")
    fs:close();

    -- perform the substitution of values
    -- assume content looks like this:
    -- <?hostip?>:<?serviceport?>
    local subs = {
      ["authority"]     = self:get_header("host"),
      --["hostip"]      = net:GetLocalAddress(),
      ["httpbase"]      = self:get_header("x-bhut-http-url-base"),
      ["websocketbase"] = self:get_header("x-bhut-ws-url-base"),
      ["serviceport"]   = serviceport,

      ["frameinterval"] = 100,
      ["capturewidth"]  = captureWidth,
      ["captureheight"] = captureHeight,
      ["imagewidth"]    = ImageWidth,
      ["imageheight"]   = ImageHeight,
      ["screenwidth"]   = ScreenWidth,
      ["screenheight"]  = ScreenHeight,
    }

--[[
print("TEMPLATE CONSTRUCTION")
for key, value in pairs(subs) do
  print(key, value)
end
--]]
    startupContent = string.gsub(content, "%<%?(%a+)%?%>", subs)
    --print(startupContent)
end

function StartupHandler:get(...)

  if not startupContent then
    loadStartupContent(self)
  end

  -- send the content back to the requester
  self:set_status(200)
  self:add_header("Content-Type", "text/html")
  self:add_header("Connection", "Keep-Alive")
  self:write(startupContent);

  return true
end

local app = turbo.web.Application({
  {"/(jquery%.js)", turbo.web.StaticFileHandler, "./jquery.js"},
  {"/(favicon%.ico)", turbo.web.StaticFileHandler, "./favicon.ico"},
  {"/grab%.bmp(.*)$", ScreenHandler},
  {"/screen", StartupHandler},
})

turbo.log.categories.success = false;

app:listen(serviceport)
turbo.ioloop.instance():start()



