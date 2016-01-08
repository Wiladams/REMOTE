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

local FrameInterval = 100;
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
    print("loadStartupContent; request.host: ", self.request.host)
    --print("loadStartupContent, host, headers: ", self.host, self.headers)
    --print();

    -- load the file into memory
    --local fs, err = io.open("viewcanvas.htm")
    --local fs, err = io.open("viewscreen_simple.htm")
    --local fs, err = io.open("viewscreen.htm")
    local fs, err = io.open("sharescreen.htm")

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
      ["authority"]     = self.request.host;
      --["hostip"]      = net:GetLocalAddress(),
      --["httpbase"]      = self:get_header("x-rmt-http-url-base"),
      --["websocketbase"] = self:get_header("x-rmt-ws-url-base"),
      ["websocketbase"] = "ws://"..self.request.host..'/',
      ["serviceport"]   = serviceport,

      ["frameinterval"] = FrameInterval,
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
  self:flush();

  return true
end

local WSExHandler = class("WSExHandler", turbo.websocket.WebSocketHandler)

function WSExHandler:on_message(msg)
  --print("WSExHandler:on_message: ", msg)
  -- assume the msg is a lua string, so parse it
  local f = loadstring("return "..msg)
  if not f then return end

--print("f: ", f)

  local tbl = f();

--print("type(tbl): ", type(tbl))

  if type(tbl) ~= "table" then
    return;
  end

  self:handleIOActivity(tbl)
end

local activityMap = {
  mousedown = mouseDown;
  mousemove = mouseMove;
  mouseup = mouseUp;

  keydown = keyDown;
  keyup = keyUp;
  keypress = keyPress;
}

local function lookupActionHandler(action)
  local handler = activityMap[action]
  if handler then
    return handler;
  end

  if action == "mousedown" then
    handler = mouseDown;
  elseif action == "mouseup" then
    handler = mouseUp;
  elseif action == "mousemove" then
    handler = mouseMove;
  elseif action == "keydown" then
    handler = keyDown;
  elseif action == "keyup" then
    handler = keyUp;
  elseif action == "keypress" then
    handler = keyPress;
  end

  activityMap[action] = handler;
 
  return handler;
end

function WSExHandler:handleIOActivity(activity)
  --print("Activity.action: ", activity.action)

  local handler = lookupActionHandler(activity.action)

  --print("Handler: ", handler)

  if not handler then return end

  handler(activity)
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



turbo.log.categories.success = false;


local app = nil;

function run()
  app = turbo.web.Application({
  {"/(jquery%.js)", turbo.web.StaticFileHandler, "./jquery.js"},
  {"/(favicon%.ico)", turbo.web.StaticFileHandler, "./favicon.ico"},
  {"/grab%.bmp(.*)$", GrabHandler},
  {"/screen", StartupHandler},
  {"/ws/uiosocket", WSExHandler}
})

  app:listen(serviceport)
  local ioinstance = turbo.ioloop.instance()
  
  ioinstance:set_interval(30, onInterval, ioinstance)
  --ioinstance:add_callback(onLoop, ioinstance)

  ioinstance:start()
end
