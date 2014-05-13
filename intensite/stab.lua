require "gd"

local prev = gd.createFromPng("frms/frm_1.png")
prev:png("stabs/stab_1.png")
local prevt = {}
for x = 1, 700 do
	prevt[x] = {}
	for y = 1, 600 do
		local c = prev:getPixel(x, y)
		prevt[x][y] = {r=prev:red(c), g=prev:green(c), b=prev:blue(c)}
	end
end
print("built prevt")
for frame = 2, 46 do
	local curr = gd.createFromPng("frms/frm_"..frame..".png")
	local currt = {}
	for x = 1, 700 do
		currt[x] = {}
		for y = 1, 600 do
			local c = curr:getPixel(x, y)
			currt[x][y] = {r=curr:red(c), g=curr:green(c), b=curr:blue(c)}
		end
	end
	print("built currt")
	local leastval = math.huge
	local leastkey = {-5, -5}
	for ix = -5, 5 do
		for iy = -5, 5 do
			local currval = 0
			for x = 434, 520 do
				for y = 59, 138 do
					currval = currval +
						math.abs(currt[x+ix][y+iy].r - prevt[x][y].r) +
						math.abs(currt[x+ix][y+iy].g - prevt[x][y].g) +
						math.abs(currt[x+ix][y+iy].b - prevt[x][y].b)
				end
			end
			if currval < leastval then
				leastkey = {ix, iy}
				leastval = currval
			end
			print(ix, iy, currval, leastval)
		end
	end
	local ix, iy = unpack(leastkey)
	print("frm "..frame, ix, iy)
	local canvas = gd.createTrueColor(700, 600)
	canvas:copy(curr, -ix, -iy, 0, 0, 700, 600)
	canvas:png("stabs/stab_"..frame..".png")
end