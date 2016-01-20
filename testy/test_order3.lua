local function order2(pt1, pt2)
	if pt1.y < pt2.y then
		return pt1, pt2;
	end

	return pt2, pt1;
end

local function order3(a, b, c)
	local a1,b1 = order2(a,b)
	local b1,c = order2(b1,c)
	local a, b = order2(a1, b1)

	return a, b, c
end

local function printPoints(a, b, c)
	print("---- ---- ---- ----");
	print(a.x, a.y)
	print(b.x, b.y)
	print(c.x, c.y)
end

printPoints(order3({x=1, y=1}, {x=1, y=2}, {x=1,y=3}));
printPoints(order3({x=1, y=1}, {x=1, y=3}, {x=1,y=2}));
printPoints(order3({x=1, y=2}, {x=1, y=1}, {x=1,y=3}));
printPoints(order3({x=1, y=2}, {x=1, y=3}, {x=1,y=1}));
printPoints(order3({x=1, y=3}, {x=1, y=1}, {x=1,y=2}));
printPoints(order3({x=1, y=3}, {x=1, y=2}, {x=1,y=1}));
