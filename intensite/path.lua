require "point"

-----------------
-- CLASSE PATH --
-----------------

path = {}
path.__index = path

-- pour creer un path: "local c = path({p1, p2, p3, ...})" avec pn des point(x, y)
setmetatable(path, {__call = function (_, pt)
		-- constructeur; au moins un point est obligatoire
		assert(type(pt) == "table", "pt doit etre une table de points")
		for _, p in ipairs(pt) do
			assert(type(p) == "table", "chaque valeur de pt doit etre un point")
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
	local pt = {}
	local p1 = point(0, 0)
	for n, p2 in self:points() do
		if n > 1 then
			local inc = 1 -- sens d'incrementation
			local alongx = math.abs(math.cos(math.atan2(p2.y-p1.y, p2.x-p1.x))) > math.sqrt(2)/2
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

-- FONCTIONS D'AFFICHAGE
function path:Draw(canvas, c)
	for _, p in self:points() do
		canvas:setPixel(p.x, p.y, c)
	end
end