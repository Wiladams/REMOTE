
local sqrt = math.sqrt

-- determine where a point (p3) intersects the
-- line determined by points p1 and p2
	-- Points on line defined by
	-- P = P1 + u*(P2 - P1)
local function lineMag(x1, y1, x2, y2)
	local x = x2 - x1;
	local y = y2 - y1;

	return sqrt(x*x+y*y);
end

local function pointLineIntersection(x1, y1, x2, y2, x3, y3)
	local mag = lineMag(x1, y1, x2, y2)
	local u = ((x3 - x1)*(x2-x1) + (y3-y1)*(y2-y1))/(mag*mag)
	local x = x1 + u * (x2 - x1);
	local y = y1 + u * (y2 - y1);

	return x, y
end

local function pointLineDistance(x1, y1, x2, y2, x3, y3)
	local x, y = pointLineIntersection(x1, y1, x2, y2, x3, y3)

	return lineMag(x3, y3, x, y)
end

return {
	lineMag = lineMag;
	pointLineIntersection = pointLineIntersection;
	pointLineDistance = pointLineDistance;
}