require "path"
require "gd"

local canvas = gd.createFromPng("diffs/diff_194.png")
local caanim = gd.createFromPng("diffs/diff_194.png")
caanim:gifAnimBegin("out.gif", false, 0)
local white = canvas:colorResolve(255, 255, 255)
local black = canvas:colorResolve(0, 0, 0)
local red = canvas:colorResolve(255, 0, 0)
local green = canvas:colorResolve(0, 255, 0)
local blue = canvas:colorResolve(0, 0, 255)
canvas:string(gd.FONT_LARGE, 2, 2, "FRONTS", white)

print("CONSTRUCTION CHEMINS")
local chemins = {}
local chemin1 = path({point(156, 118),
                      point(734, 106),
                      point(745, 120),
                      point(737, 160)})
local chemin2 = path({point(156, 118),
                      point(136, 172),
                      point(136, 172),
                      point(737, 160)})
local h = path.homotopie(chemin1, chemin2)
local npaths = 10
for n = 0, npaths do
	table.insert(chemins, h(n/npaths):subdivide())
end

print("RECHERCHE POINTS DE FRONT")
local f = io.open("fronts.txt", "w")
local l1 = 30
local l2 = 40
local cnt = 0
for frm = 10, 180, 3 do
	cnt = cnt + 1
	local inputpng = gd.createFromPng("stabs/stab_"..frm..".png")
	caanim = gd.createFromPng("stabs/stab_"..frm..".png")
	local ared = caanim:colorResolve(255, 0, 0)
	local ablue = caanim:colorResolve(0, 0, 255)
	local pf0 = nil
	local pfl0 = nil
	local pfr0 = nil
	local pappl0 = nil
	local pappr0 = nil
	for nligne, chemin in ipairs(chemins) do
		chemin:Draw(canvas, black)
		local approxf = math.floor(#chemin*cnt/(180-10)*3)
		local appl = 130
		local appr = 30
		local points = {}
		local ppv = {}
		local dppv = {}
		for _, p in chemin:points() do
			local c = inputpng:getPixel(p.x, p.y)
			local r = inputpng:red(c)
			local g = inputpng:green(c)
			local b = inputpng:blue(c)
			local i = r+g+b
			-- on voit dans cristal_diff.gif que l'intensite
			-- dominante est dans le vert
			table.insert(points, i)
		end
		-- MOYENNE
		for i = l1+1, #points-l1 do
			local c = 0
			for j = i-l1, i+l1 do
				c = c+points[j]
			end
			c = c/(2*l1+1)
			if ppv then
				table.insert(ppv, {i, c})
			end
		end
		-- ACCROISSEMENT
		for i = l2+1, #points-l2 do
			local c1, c2 = 0, 0
			for j = 1, l2 do
				c1 = c1+points[i-j]
				c2 = c2+points[i+j]
			end
			c1, c2 = c1/l2, c2/l2
			table.insert(dppv, {i, c2-c1})
		end
		-- POINT DE MINIMUM DE L'ACCROISSEMENT
		local mind = math.max(approxf-l2-100, 1)
		for i, p in ipairs(dppv) do
			if p[1] > approxf - appl
			and p[1] < approxf + appr
			and p[2] < dppv[mind][2] then
				mind = i
			end
		end
		local pappl = chemin[
			dppv[math.min(
				math.max(approxf-l2-appl, 1), #dppv)][1]]
		local pappr = chemin[
			dppv[math.min(
				math.max(approxf-l2+appr, 1), #dppv)][1]]
		if pappl0 then
			canvas:line(pappl.x, pappl.y,
			            pappl0.x, pappl0.y, blue)
			caanim:line(pappl.x, pappl.y,
			            pappl0.x, pappl0.y, ablue)
		end
		if pappr0 then
			canvas:line(pappr.x, pappr.y,
			            pappr0.x, pappr0.y, blue)
			caanim:line(pappr.x, pappr.y,
			            pappr0.x, pappr0.y, ablue)
		end
		pappl0 = pappl
		pappr0 = pappr
		--[[
		dppv[mind][2] = 0
		for min = 2, 5 do
			local minc = math.max(mind-20, 1)
			for i = math.max(mind-20, 1),
			        math.min(mind+20, #dppv) do
				if dppv[i][2] < dppv[minc][2] then
					minc = i
				end
			end
			mind = mind + minc
		end
		mind = math.floor(mind/5)
		if not dppv[mind] then
			io.write("BLEAH "..#dppv.."\t"..mind)
		end
		]]
		local mindl = mind
		while mindl > 1 do
			if dppv[mindl][2] > dppv[mind][2]/2 then
				break
			end
			mindl = mindl - 1
		end
		local mindr = mind
		while mindr < #dppv do
			if dppv[mindr][2] > dppv[mind][2]/2 then
				break
			end
			mindr = mindr + 1
		end
		--local pfront = dppv[mind][1]
		local pfrontl = dppv[mindl][1]
		local pfrontr = dppv[mindr][1]
		local pfront = math.floor((pfrontl+pfrontr)/2)
		-- POINT DE MILIEU DE FRONT
		local pf = chemin[pfront]
		local pfl = chemin[pfrontl]
		local pfr = chemin[pfrontr]
		if pf then
			f:write(cnt.."\t"
				..math.floor(pf.x).."\t"
				..math.floor(pf.y).."\n")
			if pf0 then
				canvas:line(pf0.x, pf0.y, pf.x, pf.y, red)
				caanim:line(pf0.x, pf0.y, pf.x, pf.y, ared)
			end
		end
		if pfl and pfl0 then
			canvas:line(pfl.x, pfl.y, pfl0.x, pfl0.y, green)
		end
		if pfr and pfr0 then
			canvas:line(pfr.x, pfr.y, pfr0.x, pfr0.y, green)
		end
		pf0 = pf
		pfl0 = pfl
	end
	caanim:gifAnimAdd("out.gif", true, 0, 0, 10, 2)
	io.write(frm.."\t")
	if cnt % 8 == 0 then
		io.write("\n")
	end
end
io.write("\n")
f:close()
canvas:png("fronts.png")
gd.gifAnimEnd("out.gif")
