local numpatt = "(%d+)"

local fieldNames = {
	"user",
	"nice",
	"system",
	"idle",
	"iowait",
	"irq",
	"softirq",
	"steal",
	"guest",
	"guest_nice";
}

local function stat(path)
	path = path or "/proc/stat"

	-- read only first line to get overall information
	local tbl = {}
	for str in io.lines(path) do
		local offset = 1;
		for value in str:gmatch(numpatt) do
			tbl[fieldNames[offset]] = tonumber(value)
			offset = offset + 1;
		end

		return tbl;
	end

	return tbl;
end

return {
	decoder = stat;
}