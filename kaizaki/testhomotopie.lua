require "path"
require "bezier"
require "gd"

local canvas = gd.create(660, 660)
local white = canvas:colorResolve(255, 255, 255)
local black = canvas:colorResolve(0, 0, 0)
local red = canvas:colorResolve(255, 0, 0)
canvas:gifAnimBegin("homotopie.gif", false, 0)
for subs = 3, 20 do
	canvas:filledRectangle(0, 0, 660, 660, white)
	local p1 = path(bezierGen({
		point(240, 330),
		point(240, 480),
		point(540, 480),
		point(540, 180),
		point(240, 180),
		point(240, 330)}):Divide(subs))
	local p2 = path(bezierGen({
		point(60, 330),
		point(60, 780),
		point(900, 780),
		point(900, -120),
		point(60, -120),
		point(60, 330)}):Divide(24-subs))
	local h = path.homotopie(p1, p2)
	for t = 0, 1/.02 do
		local p = h(t*.02)
		p:DrawLines(canvas, black)
	end
	canvas:gifAnimAdd("homotopie.gif", true, 0, 0, 10, 2)
	print(subs)
end
gd.gifAnimEnd("homotopie.gif")
