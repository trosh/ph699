require "gd"

------------------
-- CLASSE POINT --
------------------

point = {}
point.__index = point

-- pour creer un point: "local p = point(x, y)"
setmetatable(point, {__call = function (_, x, y)
		-- constructeur; les coordonnées sont obligatoires
		assert(type(x) == "number", "x doit etre un nombre")
		assert(type(y) == "number", "y doit etre un nombre")
		local p = {x=x, y=y}
		setmetatable(p, point)
		return p
	end})

function point.__add(p1, p2)
	-- somme usuelle? (entre deux points uniquement)
	for _, c in pairs({p1.x, p1.y, p2.x, p2.y}) do
		assert(type(c) == "number", "somme invalide")
	end
	return point(p1.x + p2.x, p1.y + p2.y)
end

function point.__sub(p1, p2)
	-- soustraction usuelle? (entre deux points uniquement)
	for _, c in pairs({p1.x, p1.y, p2.x, p2.y}) do
		assert(type(c) == "number", "somme invalide")
	end
	return point(p1.x - p2.x, p1.y - p2.y)
end

function point.__mul(p1, p2)
	-- multiplication par un scalaire?
	if type(p2) == "number" then
		p1, p2 = p2, p1
	end
	if type(p1) == "number" then
		return point(p1*p2.x, p1*p2.y)
	end
	-- produit scalaire? (entre deux points uniquements)
	for _, c in pairs({p1.x, p1.y, p2.x, p2.y}) do
		assert(type(c) == "number", "produit invalide")
	end
	return point(p1.x + p2.x, p1.y + p2.y)
end

function point.__div(p1, p2)
	-- division par un scalaire?
	if type(p2) == "number" then
		assert(p2 == 0, "division par zero")
		return point(p1.x/p2, p1.y/p2)
	end
	assert(false, "division d'un point invalide")
end

function point.__tostring(p)
	-- affichage sous forme "(x, y)"
	return "("..p.x..", "..p.y..")"
end

function point.__concat(a, b)
	-- concatenation usuelle avec la methode tostring precedente
	return tostring(a)..tostring(b)
end

function point:cursorDraw(canvas)
	-- dessine un carre rouge de 5 pixel de cote autour du point
	local red = canvas:colorResolve(255, 0, 0)
	canvas:rectangle(self.x-2, self.y-2, self.x+2, self.y+2, red)
end

function point:filledcursorDraw(canvas)
	-- dessine un carre rouge rempli de 5 pixel de cote autour du point
	local red = canvas:colorResolve(255, 0, 0)
	canvas:filledRectangle(self.x-2, self.y-2, self.x+2, self.y+2, red)
end