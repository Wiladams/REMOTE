--test_zlib.lua
local ffi = require("ffi")

--local zlib = require("zlib_ffi")
local zlib = require("zlib")

local verpatt = "(%d+)%.(%d+)%.(%d+)"
local verstr = zlib.VERSION
local major, minor, revision = verstr:match(verpatt)

print("Version: ", verstr, major, minor, revision)
