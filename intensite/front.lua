require "path"

function resize(frametc, maxsize)
	local sizex, sizey = frametc:sizeXY()
	if sizex > maxsize or sizey > maxsize then
		if sizex > sizey then
			local nsizey = sizey*maxsize/sizex
			local nframetc = gd.createTrueColor(maxsize, nsizey)
			nframetc:copyResampled(frametc, 0, 0, 0, 0, maxsize, nsizey, sizex, sizey)
			return nframetc
		else
			local nsizex = sizex*maxsize/sizey
			local nframetc = gd.createTrueColor(nsizex, maxsize)
			nframetc:copyResampled(frametc, 0, 0, 0, 0, nsizex, maxsize, sizex, sizey)
			return nframetc
		end
	end
end
--math.randomseed(os.time())
local debut = point(238, 552)
local fin = point(483, 90)
--local origin = {x=20, y=280}
--local canvas = gd.create(debut.y-fin.y+origin.x+40, 300)
local canvas = gd.createFromPng("stabs/stab_28.png")
--canvas = resize(canvas, 400)
--canvas = canvas:createPaletteFromTrueColor(true, 40)
local white = canvas:colorResolve(255, 255, 255) --background color
--local black = canvas:colorResolve(0, 0, 0)
local red = canvas:colorResolve(255, 0, 0)
local blue = canvas:colorResolve(0, 0, 255)
--[[
canvas:string(gd.FONT_LARGE, 2, 2, "coupe mediane", black)
local uparrow = {y=30, s=5}
local rightarrow = {x=debut.y-fin.y+origin.x, s=5}
canvas:line(origin.x, origin.y, origin.x, uparrow.y, black)
canvas:line(origin.x, uparrow.y, origin.x+uparrow.s, uparrow.y+uparrow.s, black)
canvas:line(origin.x, uparrow.y, origin.x-uparrow.s, uparrow.y+uparrow.s, black)
canvas:line(origin.x, origin.y, rightarrow.x, origin.y, black)
canvas:line(rightarrow.x, origin.y, rightarrow.x-rightarrow.s, origin.y-rightarrow.s, black)
canvas:line(rightarrow.x, origin.y, rightarrow.x-rightarrow.s, origin.y+rightarrow.s, black)
canvas:string(gd.FONT_SMALL, rightarrow.x-55, origin.y-14, "position", black)
canvas:stringUp(gd.FONT_SMALL, 19, 90, "intensite", black)
]]
local l1 = 30
local l2 = 40
local cnt = 0
local fronts = {}
canvas:gifAnimBegin("out.gif", false, 0)
for frm = 28, 46 do --2, 46, 3 do
	cnt = cnt + 1
	--[[
	canvas:filledRectangle(0, 0, debut.y-fin.y+origin.x+40, 300, white)
	canvas:string(gd.FONT_LARGE, 2, 2, "coupe mediane de diff avec accroissement et milieu de front", black)
	local uparrow = {y=30, s=5}
	local rightarrow = {x=debut.y-fin.y+origin.x, s=5}
	canvas:line(origin.x, origin.y, origin.x, uparrow.y, black)
	canvas:line(origin.x, uparrow.y, origin.x+uparrow.s, uparrow.y+uparrow.s, black)
	canvas:line(origin.x, uparrow.y, origin.x-uparrow.s, uparrow.y+uparrow.s, black)
	canvas:line(origin.x, origin.y, rightarrow.x, origin.y, black)
	canvas:line(rightarrow.x, origin.y, rightarrow.x-rightarrow.s, origin.y-rightarrow.s, black)
	canvas:line(rightarrow.x, origin.y, rightarrow.x-rightarrow.s, origin.y+rightarrow.s, black)
	canvas:string(gd.FONT_SMALL, rightarrow.x-55, origin.y-14, "position", black)
	canvas:stringUp(gd.FONT_SMALL, 19, 90, "intensite", black)
	local cr, cg, cb =
		math.floor(math.random()*256),
		math.floor(math.random()*256),
		math.floor(math.random()*256)
	local color = canvas:colorAllocate(cr, cg, cb)
	]]
	local inputpng = gd.createFromPng("diffs/diff_"..frm..".png")
	--local 
	canvas = gd.createFromPng("diffs/diff_"..frm..".png")
	--canvas = canvas:createPaletteFromTrueColor(true, 20)
	--canvas:filledRectangle(0, 0, 700, 600, white)
	local black = canvas:colorResolve(0, 0, 0)
	local white = canvas:colorResolve(255, 255, 255)
	local red = canvas:colorResolve(255, 0, 0)
	--canvas:line(240+origin.x, 0, 240+origin.x, 255, red)
	--canvas:line(400+origin.x, 0, 400+origin.x, 255, red)
	local f0 = nil
	for ix = -100, 100, 5 do
		local chemin = path({point(238+ix, 552), point(483+ix, 90)}):subdivide()
		chemin:Draw(canvas, black)
		local ppv = {}
		local dppv = {}
		local lfronts = {}
		if frm < 28 then
			ppv = nil
			dppv = nil
			lfronts = nil
		end
		local points = {}
		for _, p in chemin:points() do
			local x, y = p.x, p.y
			local c = inputpng:getPixel(x, y)
			local r, g, b = inputpng:red(c), inputpng:green(c), inputpng:blue(c)
			local i = (g/3-10)*3 -- on voit dans cristal_diff.gif que l'intensite dominante est dans le vert
			table.insert(points, i)
		end
		--[[
		for y = debut.y, fin.y, -1 do
			local x = debut.x + (y-debut.y)*pente + ix
			local c = inputpng:getPixel(x, y)
			local r, g, b = inputpng:red(c), inputpng:green(c), inputpng:blue(c)
			--local i = ((r+g+b)/3-70)*5
			local i = (g/3-10)*3 -- on voit dans cristal_diff.gif que l'intensite dominante est dans le vert
			--local i = (r+g+b)/3
			table.insert(points, i)
			--canvas:setPixel(debut.y-y+origin.x, 255-i-ix, black)
		end
		]]
		for i = l1+1, #points-l1 do
			local c = 0
			for j = i-l1, i+l1 do
				c = c+points[j]
			end
			c = c/(2*l1+1)
			if ppv and i > 240 and i < 400 then
				table.insert(ppv, {i, c})
			end
			--canvas:setPixel(i+origin.x, 255-c-ix, black)--color)--red)
		end
		for i = l2+1, #points-l2 do
			local c1, c2 = 0, 0
			for j = 1, l2 do
				c1 = c1+points[i-j]
				c2 = c2+points[i+j]
			end
			c1, c2 = c1/l2, c2/l2
			if dppv and i > 240 and i < 400 then
				table.insert(dppv, {i, c2-c1})
				--canvas:setPixel(i+origin.x, 128-c2+c1-ix, red)--color)
			end
		end
		if ppv then
			local avg = 0
			for _, p in ipairs(ppv) do
				avg = avg + p[2]
			end
			avg = avg / #ppv
			print(avg)
			local ph = 0 --nb de points qui sont au dessus de la moyenne
			for _, p in ipairs(ppv) do
				if p[2] < avg then
					ph = ph + 1
				end
			end
			print(ph)
			--canvas:line(ppv[ph][1]+origin.x, 0, ppv[ph][1]+origin.x, 255, color)
			local mind = 1
			for i, p in ipairs(dppv) do
				if p[2] < dppv[mind][2] then
					mind = i
				end
			end
			print("mind "..mind)
			table.insert(lfronts, dppv[mind][1])
			--canvas:line(dppv[mind][1]+origin.x, 0, dppv[mind][1]+origin.x, 255, red) --color)
			local front = 0
			for _, fronti in ipairs(lfronts) do
				front = front + fronti
			end
			front = front/#lfronts
			table.insert(fronts, front)
			local f = chemin[front]
			if f0 and f then
				canvas:line(f0.x, f0.y, f.x, f.y, red)
			end
			if f0 and not f then
				local image = gd.create(500, 300)
				local blanc = image:colorAllocate(255, 255, 255)
				local noir = image:colorAllocate(0, 0, 0)
				for _, kudfgrig in ipairs(ppv) do
					image:setPixel(kudfgrig[1], kudfgrig[2]+100, noir)
				end
				image:png("debug.png")
				os.exit(0)
			end
			--canvas:line(front, 0, front, 255, blue)
			f0 = f
		end
	end
	--canvas:string(gd.FONT_SMALL, debut.y-fin.y+origin.x, 280, "frm "..frm, black)
	--canvas:string(gd.FONT_SMALL, debut.y-fin.y+origin.x, (cnt-0.8)*16, "frm "..frm, color)
	canvas:string(gd.FONT_SMALL, 750, 550, "frm"..frm, white)
	canvas:gifAnimAdd("out.gif", true, 0, 0, 10, 2)
	canvas:png("out.png")
	print("frm :"..frm)
end
--local f = io.open("out.txt", "w")
--for i = 1, #fronts do
--	--canvas:line((i-2)*10, fronts[i-1]-fronts[i-2]+128, (i-1)*10, fronts[i]-fronts[i-1]+128, black)
--	f:write(i.."\t"..fronts[i].."\n")
--end
--f:close()

gd.gifAnimEnd("out.gif")
--canvas:png("out.png")

--[[
canvas = gd.createFromPng("frms/frm_40.png")
for x = 1, 700 do
	for y = 1, 600 do
		local c = canvas:getPixel(x, y)
		canvas:setPixel(x, y, canvas:colorAllocate(2*canvas:red(c)+canvas:green(c)-canvas:blue(c), 0, 0))
	end
end
]]
