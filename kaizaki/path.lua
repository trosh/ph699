---------------------------------
-- path.lua ---------------------
---------------------------------
-- classe path avec iterateur, --
-- subdiviseur en segments,    --
-- generateur d'homotopies et  --
-- fonction de dessin          --
---------------------------------
-- version 1.0                 --
-- date 2014/04/16-23:30       --
-- author John Gliksberg       --
---------------------------------

require "gd"
require "point"

path = {}
path.__index = path

-- pour creer un path: "local c = path({p1, p2, p3, ...})"
-- avec pn des point(x, y)
setmetatable(path, {__call = function (_, pt, dummy)
		-- constructeur; au moins un point est obligatoire
		assert(type(pt) == "table",
			"pt doit etre une table de points")
		assert(dummy == nil,
			"path ne prend qu'une valeur table")
		for _, p in ipairs(pt) do
			assert(type(p) == "table",
				"chaque valeur de pt doit etre un point")
		end
		setmetatable(pt, path)
		return pt
	end})

function path:points()
	-- usine pour l'iterateur
	local n = 0
	local size = #self
	return function ()
		-- itere sur les points qui composent le path
		-- (renvoie l'indice du point et le point)
		n = n + 1
		if n <= size then return n, self[n] end
	end
end

function path.__tostring(pt)
	-- affichage sous la forme "((x1, y1), (x2, y2), ...)"
	local t = "("
	for n, p in pt:points() do
		if n > 1 then
			t = t .. ", "
		end
		t = t .. p
	end
	t = t .. ")"
	return t
end

function path.__concat(a, b)
	-- concatenation usuelle avec la methode tostring precedente
	return tostring(a)..tostring(b)
end

function path:subdivide()
	-- subdivise le path en points de segments
	-- (transforme des extremites de segments en segments)
	local pt = {}
	local p1 = point(0, 0)
	for n, p2 in self:points() do
		if n > 1 then
			local inc = 1 -- sens d'incrementation
			--local alongx = math.abs(math.cos(math.atan2(p2.y-p1.y, p2.x-p1.x))) > math.sqrt(2)/2
			local alongx = true
			if math.abs(p2.y-p1.y) > math.abs(p2.x-p1.x) then
				alongx = false
			end
			-- doit on parcourir le segment selon x ou y
			if alongx then
				if p2.x < p1.x then
					inc = -1
				end
				local pente = (p2.y-p1.y)/(p2.x-p1.x)
				for x = p1.x+inc, p2.x, inc do
					local y = p1.y + (x-p1.x)*pente
					table.insert(pt, point(x, y))
				end
			else
				if p2.y < p1.y then
					inc = -1
				end
				local pente = (p2.x-p1.x)/(p2.y-p1.y)
				for y = p1.y+inc, p2.y, inc do
					local x = p1.x + (y-p1.y)*pente
					table.insert(pt, point(x, y))
				end
			end
		else
			table.insert(pt, p2)
		end
		p1 = p2
	end
	return path(pt)
end

function path.homotopie(p1, p2)
	return function(t)
		if #p2 > #p1 then
			p1, p2 = p2, p1
		end
		local r = #p2/#p1
		local p = {}
		for n = 1, #p1 do
			local m = math.min(math.max(math.ceil(n*r), 1), #p2)
			table.insert(p, (1-t)*p1[n]+t*p2[m])
		end
		return path(p)
	end
end

---------------------------
-- FONCTIONS D'AFFICHAGE --
---------------------------

function path:Draw(canvas, c, l)
	for _, p in self:points() do
		canvas:setPixel(p.x, p.y, c)
	end
	if l then
		local p = self[1]
		canvas:string(gd.FONT_LARGE, p.x+2, p.y+2, l, c)
	end
end

function path:DrawLines(canvas, c, l)
	for n = 2, #self do
		canvas:line(
			self[n-1].x, self[n-1].y,
			self[n  ].x, self[n  ].y, c)
	end
	if l then
		local p = self[1]
		canvas:string(gd.FONT_LARGE, p.x+2, p.y+2, l, c)
	end
end
