require "gd"
local function point(x, y)
	return {x=x, y=y}
end
local debut = point(238, 552)
local fin = point(483, 90)
for frm = 1, 46 do
	local inputpng = gd.createFromPng("frms/frm_"..frm..".png")
	local white = inputpng:colorAllocate(255, 255, 255)
	local red = inputpng:colorAllocate(255, 0, 0)
	local pente = (debut.x-fin.x)/(debut.y-fin.y)
	local l = 15
	local points = {}
	for y = debut.y, fin.y, -1 do
		local x = debut.x + (y-debut.y)*pente
		local c = inputpng:getPixel(x, y)
		local r, g, b = inputpng:red(c), inputpng:green(c), inputpng:blue(c)
		local i = ((r+g+b)/3-70)*5
		--local i = (r+g+b)/3
		table.insert(points, i)
	end
	for i = l+1, #points-l do
		local c = 0
		for j = i-l, i+l do
			c = c+points[j]
		end
		c = c/(2*l+1)
		local y = debut.y-i+1
		local x = debut.x + (y-debut.y)*pente
		inputpng:line(x, y, x-c, y, white)
	end
	inputpng:png("overlays/overlay_"..frm..".png")
end