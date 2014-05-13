require "gd"

local prev = gd.createFromPng("frms/frm_1.png")
prev:png("stabs/stab_1.png")
local sizex, sizey = prev:sizeXY()
local prevt = {}
for x = 1, sizex do
	prevt[x] = {}
	for y = 1, sizey do
		local c = prev:getPixel(x, y)
		prevt[x][y] = {r=prev:red(c), g=prev:green(c), b=prev:blue(c)}
	end
end
print("built prevt")
for frame = 2, 196 do
	local curr = gd.createFromPng("frms/frm_"..frame..".png")
	local currt = {}
	for x = 1, sizex do
		currt[x] = {}
		for y = 1, sizey do
			local c = curr:getPixel(x, y)
			currt[x][y] = {r=curr:red(c), g=curr:green(c), b=curr:blue(c)}
		end
	end
	print("built currt")
	local leastval = math.huge
	local leastkey = {-10, -10}
	for ix = -10, 10 do
		for iy = -10, 10 do
			local currval = 0
			for x = 250, 305 do
				for y = 68, 104 do
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
	local canvas = gd.createTrueColor(sizex, sizey)
	canvas:copy(curr, -ix, -iy, 0, 0, sizex, sizey)
	canvas:png("stabs/stab_"..frame..".png")
end