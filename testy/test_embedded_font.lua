local fonts = require("embedded_raster_fonts");
local EmbeddedFont = require("EmbeddedFont");

local gse4x6_data = fonts.gse4x6;


local font1 = EmbeddedFont:new(gse4x6_data)

print("Height: ", font1.height)
print("# Chars: ", font1.num_chars)
print("String Width: ", font1:stringWidth("Hello, World"));
