require "gd"

local prev = gd.createFromPng("frms/frm_1.png")
local prevt = {}
local sizex, sizey = prev:sizeXY()
for x = 1, sizex do
	prevt[x] = {}
	for y = 1, sizey do
		local c = prev:getPixel(x, y)
		prevt[x][y] = {r=prev:red(c), g=prev:green(c), b=prev:blue(c)}
	end
end
print("built prevt")
for frame = 2, 196 do
	local curr = gd.createFromPng("stabs/stab_"..frame..".png")
	local currt = {}
	for x = 1, sizex do
		currt[x] = {}
		for y = 1, sizey do
			local c = curr:getPixel(x, y)
			currt[x][y] = {r=curr:red(c), g=curr:green(c), b=curr:blue(c)}
		end
	end
	print("built currt")
	local canvas = gd.createTrueColor(sizex, sizey)
	for x = 1, sizex do
		for y = 1, sizey do
			canvas:setPixel(x, y, canvas:colorAllocate(
				math.abs(currt[x][y].r - prevt[x][y].r),
				math.abs(currt[x][y].g - prevt[x][y].g),
				math.abs(currt[x][y].b - prevt[x][y].b)))
		end
	end
	print("frm "..frame)
	canvas:png("diffs/diff_"..frame..".png")
end