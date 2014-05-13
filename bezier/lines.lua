require "bezier"

math.randomseed(os.time())

local canvas = gd.create(400, 400)
local white = canvas:colorResolve(255, 255, 255) --background color
local black = canvas:colorResolve(0, 0, 0)

canvas:gifAnimBegin("out.gif", false, 0)
for frame = 1, 40, 2 do
	io.write("FRAME "..frame.."\n")
	canvas:filledRectangle(0, 0, 400, 400, white)
	local bezs = {}
	for line = 1, 30 do
		local p1 = point(100+frame-5*line, 50+10*line)
		local p2 = point(160+frame, 80-frame+(10+frame/10)*line)
		local p3 = point(250+frame, 10+2*frame+10*line)
		local p4 = point(300+frame+5*line, 50+10*line)
		local p5 = point(320+frame+5*line, 50+10*line)
		table.insert(bezs, bezierGen({p1, p2, p3, p4, p5}))
	end
	local L = 20
	local lines = {}
	local prevt = {}
	for i = 0, L do
		table.insert(prevt, i/L)
		lines[i+1] = {bezs[1]:Plot(i/L)}
	end
	local prevbez = bezs[1]
	prevbez:Draw(canvas, 30)
	for line = 2, 30 do
		local currbez = bezs[line]
		currbez:Draw(canvas, 30)
		local nints = {}
		-- liste actuelle d'intersections à remplir
		for l, startt in pairs(prevt) do
			--if not startt then
			--	-- aucune intersection n'a ete trouvee a l'iteration precedente
			--	nints[l] = false
			--else
				local n1 = prevbez:Plot(startt)
				local n2 = prevbez:Normal(startt)
				n2 = point(n1.x+n2.x, n1.y+n2.y)
				local t = currbez:Intersect(n1, n2)
				--if t == nil then
				--	nints[l] = false
				--else
				if t then
					nints[l] = t
					table.insert(lines[l], currbez:Plot(t))
					--local p = bezierCubPlot(np1, np2, np3, np4, t)
					--canvas:line(n1.x, n1.y, p.x, p.y, red)
				end
			--end
		end
		prevbez = currbez
		prevt = nints -- points de départ pour l'itération suivante
		io.write(line.." ")
	end
	for linei, line in pairs(lines) do
		--io.write("\n"..linei.. ": ")
		local color = canvas:colorResolve(math.random()*256, math.random()*256, math.random()*256)
		local prev = line[1]
		for i = 2, #line do
			local plot = line[i]
			--io.write(plot.." ")
			canvas:line(prev.x, prev.y, plot.x, plot.y, color)
			prev = plot
		end
	end
	canvas:string(gd.FONT_SMALL, 2, 2, "BEZIER INTERSECTIONS N LIGNES", black)
	canvas:gifAnimAdd("out.gif", true, 0, 0, 10, gd.DISPOSAL_NONE)
	io.write("\n")
end
gd.gifAnimEnd("out.gif")
