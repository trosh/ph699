require "gd"

local prev = gd.createFromPng("frms/frm_1.png")
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
	local curr = gd.createFromPng("stabs/stab_"..frame..".png")
	local currt = {}
	for x = 1, 700 do
		currt[x] = {}
		for y = 1, 600 do
			local c = curr:getPixel(x, y)
			currt[x][y] = {r=curr:red(c), g=curr:green(c), b=curr:blue(c)}
		end
	end
	print("built currt")
	local canvas = gd.createTrueColor(700, 600)
	for x = 1, 700 do
		for y = 1, 600 do
			canvas:setPixel(x, y, canvas:colorAllocate(
				10*math.abs(currt[x+ix][y+iy].r - prevt[x][y].r),
				10*math.abs(currt[x+ix][y+iy].g - prevt[x][y].g),
				10*math.abs(currt[x+ix][y+iy].b - prevt[x][y].b)))
		end
	end
	print("frm "..frame, ix, iy)
	canvas:png("diffs/diff_"..frame..".png")
end