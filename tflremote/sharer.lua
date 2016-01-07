_G.TURBO_SSL = true -- SSL must be enabled for WebSocket support!

local ffi = require("ffi")
local turbo = require("turbo")

--local colors = require("colors")
local bmp = require("tflremote.bmpcodec")
local DrawingContext = require("tflremote.DrawingContext")
local MemoryStream = require("tflremote.memorystream")

--[[
  Application Variables
--]]
local serviceport = tonumber(arg[1]) or 8080

local ImageBitCount = 32;
local ScreenWidth = nil;
local ScreenHeight = nil;
local captureWidth = nil;
local captureHeight = nil;

local graphPort = nil;
local mstream = nil;
local BmpImageSize = nil;



function size(width, height)
  ScreenWidth = width;
  ScreenHeight = height;

  captureWidth = ScreenWidth;
  captureHeight = ScreenHeight;

  ImageWidth = captureWidth * 1.0;
  ImageHeight = captureHeight * 1.0;


  graphPort = DrawingContext(ScreenWidth, ScreenHeight)
  BmpImageSize = bmp.getBmpFileSize(graphPort)
  mstream = MemoryStream:new(BmpImageSize);

  return graphPort
end

function writeImage(strm, img)
  -- generate a .bmp file
  strm:reset();
  local bytesWritten = bmp.write(strm, img)
  
  return bytesWritten;
end


local DefaultHandler = class("DefaultHandler", turbo.web.RequestHandler)
function DefaultHandler:get(...)
  self:write("Example Handler: Hello world!")
end


-- Request handler for /grab%.bmp(.*)$
local GrabHandler = class("GrabHandler", turbo.web.RequestHandler)

function GrabHandler:get(...)
  --turbo.log.devel("ScreenHandler: "..self.host)

  local bytesWritten = writeImage(mstream, graphPort);

  --print("STREAM: ", bytesWritten)
  self:set_status(200)
  self:add_header("Content-Type", "image/bmp")
  self:add_header("Content-Length", tostring(bytesWritten))
  self:add_header("Connection", "Keep-Alive")
  
  self:write(ffi.string(mstream.Buffer, bytesWritten));
  self:flush();
end

-- Default request handler
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



local function onLoop(ioinstance)
  if loop then
    loop()
  end
  ioinstance:add_callback(onLoop, ioinstance)
end

local function onInterval(ioinstance)
  if loop then
    loop()
  end
end


local WSExHandler = class("WSExHandler", turbo.websocket.WebSocketHandler)

function WSExHandler:on_message(msg)
    self:write_message("Hello World.")
end


local app = turbo.web.Application({
  {"/(jquery%.js)", turbo.web.StaticFileHandler, "./jquery.js"},
  {"/(favicon%.ico)", turbo.web.StaticFileHandler, "./favicon.ico"},
  {"/grab%.bmp(.*)$", GrabHandler},
  {"/screen", StartupHandler},
  {"^/ws$", WSExHandler}
})

turbo.log.categories.success = false;



function run()
  app:listen(serviceport)
  local ioinstance = turbo.ioloop.instance()
  
  ioinstance:set_interval(30, onInterval, ioinstance)
  --ioinstance:add_callback(onLoop, ioinstance)

  ioinstance:start()
end
