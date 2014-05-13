require "gd"
local function point(x, y)
	return {x=x, y=y}
end
local debut = point(238, 552)
local fin = point(483, 90)
local inputpng = gd.createFromPng("frms/frm_40.png")
local red = inputpng:colorAllocate(255, 0, 0)
for ix = 0, 100, 10 do
	inputpng:line(debut.x, debut.y, fin.x, fin.y, red)
end
inputpng:png("out.png")