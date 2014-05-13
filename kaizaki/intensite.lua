require "gd"
require "point"
require "path"

math.randomseed(os.time())

local output = "out.gif"
if arg[1] then
	output = arg[1]
end

local l1 = 20 -- moyenne sur combien de points (a gauche et a droite)
local l2 = 40 -- pseudo derivee sur combien de points (a gauche et a droite)
local l3 = 44 -- demi largeur où chercher les coupes autour du milieu du front
local debut = point(130, 144)
local fin = point(746, 144)
local pt = path({debut, fin}):subdivide()
local origin = point(20, 280)
local canvas = gd.create(#pt+origin.x+40, 300)
local white = canvas:colorAllocate(255, 255, 255) --background color
local black = canvas:colorAllocate(0, 0, 0)
local red = canvas:colorAllocate(255, 0, 0)
local green = canvas:colorAllocate(0, 255, 0)
local darkgreen = canvas:colorAllocate(0, 155, 0)
local blue = canvas:colorAllocate(0, 0, 255)
local cnt = 0
local fronts = {}
local bestmids = {}
canvas:gifAnimBegin(output, false, 0)
for frm = 2, 196, 2 do --2, 46, 3 do
	cnt = cnt + 1
	
	canvas:filledRectangle(0, 0, #pt+origin.x+40, 300, white)
	canvas:string(gd.FONT_LARGE, 2, 2, "coupe mediane de diff avec separation minimisante et milieu de front 1/2", black)
	local uparrow = {y=30, s=5}
	local rightarrow = {x=#pt+origin.x, s=5}
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
	local inputpng = gd.createFromPng("diffs/diff_"..frm..".png")
	local ppv = {} -- points moyennés
	local dppv = {} -- pseudo dérivée
	local lfronts = {} -- liste des points de milieu de front selon les paths
	--[[
	if frm < 28 then
		ppv = nil
		dppv = nil
		lfronts = nil
	end
	]]
	--canvas:line(240+origin.x, 0, 240+origin.x, 255, red)
	--canvas:line(400+origin.x, 0, 400+origin.x, 255, red)
	for ix = 0, 0, 1 do
		--canvas:line(0, 255-ix, debut.y-fin.y, 255-ix, black)
		local points = {}
		for n, p in pt:points() do
			local x, y = p.x, p.y
			local c = inputpng:getPixel(x, y)
			local r, g, b = inputpng:red(c), inputpng:green(c), inputpng:blue(c)
			local i = r+g+b
			table.insert(points, i)
			canvas:setPixel(n+origin.x, 255-i-ix, black)
		end
		for i = l1+1, #points-l1 do
			local c = 0
			for j = i-l1, i+l1 do
				c = c+points[j]
			end
			c = c/(2*l1+1)
			if ppv and i > 10 and i < 300 then
				table.insert(ppv, {i, c})
			end
			canvas:setPixel(i+origin.x, 255-c-ix, black)--color)--red)
		end
		for i = l2+1, #points-l2 do
			local c1, c2 = 0, 0
			for j = 1, l2 do
				c1 = c1+points[i-j]
				c2 = c2+points[i+j]
			end
			c1, c2 = c1/l2, c2/l2
			if dppv then -- and i > 240 and i < 400 then
				table.insert(dppv, {i, c2-c1})
				canvas:setPixel(i+origin.x, 128-c2+c1-ix, red)--color)
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
			print("ph:", ph)
			--canvas:line(ppv[ph][1]+origin.x, 0, ppv[ph][1]+origin.x, 255, color)
			--[[
			local mind = 1
			for i, p in ipairs(dppv) do
				if p[2] < dppv[mind][2] then
					mind = i
				end
			end
			]]
			table.sort(dppv, function (x, y) return x[2] < y[2] end)
			local mind = dppv[1][1]-l2
			print("mind:", mind)
			table.insert(lfronts, dppv[mind][1])
			canvas:line(dppv[mind][1]+origin.x, 0, dppv[mind][1]+origin.x, 255, red) --color)
			local bestcuts = {2,3}
			local leastf = math.huge
			for c1 = math.max(2, lfronts[#lfronts]-l3), math.min(#pt-1, lfronts[#lfronts]+l3) do
				for c2 = c1+1, math.min(#pt, lfronts[#lfronts]+l3) do
					local avg1 = 0
					local sd1 = 0
					for p = 1, c1-1 do
						avg1 = avg1 + points[p]
						sd1 = sd1 + points[p]^2
					end
					avg1 = avg1/(c1-1)
					sd1 = sd1/(c1-1)-avg1^2
					local avg2 = 0
					local sd2 = 0
					for p = c1, c2-1 do
						avg2 = avg2 + points[p]
						sd2 = sd2 + points[p]^2
					end
					avg2 = avg2/(c2-c1)
					sd2 = sd2/(c2-c1)-avg2^2
					local avg3 = 0
					local sd3 = 0
					for p = c2, #pt do
						avg3 = avg3 + points[p]
						sd3 = sd3 + points[p]^2
					end
					avg3 = avg3/(#pt-c2+1)
					sd3 = sd3/(#pt-c2+1)-avg3^2
					local f = sd1-2*sd2+sd3
					if f < leastf then
						bestcuts = {c1, c2}
						leastf = f
					end
				end
			end
			print(bestcuts[1], bestcuts[2], leastf)
			canvas:line(bestcuts[1]+origin.x, 25, bestcuts[1]+origin.x, 255, green)
			canvas:line(bestcuts[2]+origin.x, 25, bestcuts[2]+origin.x, 255, green)
			local bestmid = (bestcuts[1]+bestcuts[2])/2
			table.insert(bestmids, bestmid)
			canvas:line(bestmid+origin.x, 25, bestmid+origin.x, 255, darkgreen)
		end
	end
	local front = 0
	for _, fronti in ipairs(lfronts) do
		front = front + fronti
	end
	front = front/#lfronts
	table.insert(fronts, front)
	--canvas:line(front+origin.x, 0, front+origin.x, 255, blue)
	canvas:string(gd.FONT_SMALL, #pt+origin.x, 280, "frm"..frm, black)
	--canvas:string(gd.FONT_SMALL, #pt+origin.x, (cnt-0.8)*16, "frm "..frm, color)
	canvas:gifAnimAdd(output, true, 0, 0, 10, 2)
	--canvas:png("out.png")
	print("frm :"..frm)
end

local f = io.open("out.txt", "w")
for i = 1, #fronts do
	--canvas:line((i-2)*10, fronts[i-1]-fronts[i-2]+128, (i-1)*10, fronts[i]-fronts[i-1]+128, black)
	f:write(i.."\t"..fronts[i].."\t"..bestmids[i].."\n")
end
f:close()

gd.gifAnimEnd(output)
--canvas:png(output)

--[[
canvas = gd.createFromPng("frms/frm_40.png")
for x = 1, 700 do
	for y = 1, 600 do
		local c = canvas:getPixel(x, y)
		canvas:setPixel(x, y, canvas:colorAllocate(2*canvas:red(c)+canvas:green(c)-canvas:blue(c), 0, 0))
	end
end
]]