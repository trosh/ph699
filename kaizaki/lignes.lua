require "point"
require "bezier"
require "gd"

local f = io.open("fronts.txt", "r")
local fl = io.open("lignes.txt", "w")
local canvas = gd.createFromPng("frms/frm_1.png")
local red = canvas:colorResolve(255, 0, 0)

local fronts = {}
for line in f:lines() do
	local cnt, pfx, pfy = string.match(line, "(%d+)\t(%d+)\t(%d+)")
	cnt = tonumber(cnt)
	pfx = tonumber(pfx)
	pfy = tonumber(pfy)
	if fronts[cnt] then
		table.insert(fronts[cnt], point(pfx, pfy))
	else
		fronts[cnt] = {point(pfx, pfy)}
	end
end

print("CONSTRUCTION FRONTS (BEZIER)")
for n = 1, #fronts do
	fronts[n] = bezierGen(fronts[n])
	fronts[n]:Draw(canvas, 20)
end

print("RECHERCHE DEBUT LIGNES")
local lines = {}
local nlines = 80
local across = bezierGen({point(141, 178), point(747, 116)})
for t = 1, nlines do
	local n1 = across:Plot(t/(nlines+1))
	local n2 = across:Normal(t/(nlines+1))
	n2 = n1+n2
	for n = 1, #fronts do
		local intt = fronts[n]:Intersect(n1, n2)
		if intt then
			table.insert(lines, {n, intt})
			break
		end
	end
	io.write(t.."\t")
	if t % 8 == 0 then
		io.write("\n")
	end
end

print("CONSTRUCTION LIGNES")
for nl, l in ipairs(lines) do
	local t = l[2]
	for n = l[1], #fronts-1 do
		local front = fronts[n]
		local n1 = front:Plot(t)
		local n2 = front:Normal(t)
		n2 = n1+n2
		local intt = fronts[n+1]:Intersect(n1, n2)
		if intt then
			local intp = fronts[n+1]:Plot(intt)
			fl:write(n.."\t"..intp.x.."\t"..intp.y.."\n")
			canvas:line(n1.x, n1.y, intp.x, intp.y, red)
			t = intt
		else
			break
		end
	end
	io.write(nl.."\t")
	if nl % 8 == 0 then
		io.write("\n")
	end
end
io.write("\n")

--[[
local L = 15
local lines = {}
local prevt = {}
for i = 0, L do
	table.insert(prevt, i/L)
	lines[i+1] = {fronts[1]:Plot(i/L)}
end
local prevbez = fronts[1]
for front = 2, #fronts do
	local currbez = fronts[front]
	currbez:Draw(canvas, 30)
	local nints = {}
	for l, startt in pairs(prevt) do
		local n1 = prevbez:Plot(startt)
		local n2 = prevbez:Normal(startt)
		n2 = point(n1.x+n2.x, n1.y+n2.y)
		local t = currbez:Intersect(n1, n2)
		if t then
			nints[l] = t
			table.insert(lines[l], currbez:Plot(t))
			local plot = currbez:Plot(t)
			canvas:line(n1.x, n1.y, plot.x, plot.y, red)
		end
	end
	prevbez = currbez
	prevt = nints
	-- points de départ pour l'itération suivante
end
]]
canvas:png("out.png")

f:close()
fl:close()
