require "point" -- gd est deja dependant de point
require "path"

---------------------------------------
-- CLASSE COURBES DE BEZIER CUBIQUES --
---------------------------------------

bezierCub = {}
bezierCub.__index = bezierCub

-- pour creer une courbe de Bezier: "local b = bezierCub(p1, p2, p3, p4)"
setmetatable(bezierCub, {__call = function (_, p1, p2, p3, p4)
		-- constructeur; les points sont obligatoires et doivent etre
		-- bien formes
		for _, c in ipairs({p1.x, p1.y,
		                   p2.x, p2.y,
		                   p3.x, p3.y,
		                   p4.x, p4.y}) do
			assert(type(c) == "number",
				"Bezier parameters must be numbers")
		end
		local b = {p1, p2, p3, p4}
		setmetatable(b, bezierCub)
		return b
	end})

function bezierCub:Plot(t)
	-- calcule le point sur la courbe au parametre t
	-- (t entre 0 et 1 pour etre à l'interieur de la courbe)
	local p1, p2, p3, p4 = self[1], self[2], self[3], self[4]
	return (1-t)^3*p1 + 3*(1-t)^2*t*p2 + 3*(1-t)*t^2*p3 + t^3*p4
end

function bezierCub:Tangent(t)
	-- calcule la DIRECTION de la tangente a la courbe au parametre t
	local p1, p2, p3, p4 = self[1], self[2], self[3], self[4]
	return 3*(1-t)^2*(p2-p1) + 6*(1-t)*t*(p3-p2) + 3*t^2*(p4-p3)
end

function bezierCub:Normal(t)
	-- calcule la DIRECTION de la normale a la courbe au parametre t
	-- (rotation de la direction de la tangente de pi/2)
	local t = self:Tangent(t)
	return point(t.y, -t.x)
end

function bezierCub:Divide(f)
	-- renvoie les f+1 extremites des f segments qui composent la courbe
	local points = {}
	for n = 0, f do
		local p = self:Plot(n/f)
		table.insert(points, p)
	end
	return points
end

function bezierCub:Points(f)
	-- usine pour l'iterateur
	local n = 0
	return function ()
		-- itere sur les f "fins" d'extremites des f segments qui
		-- composent la courbe (renvoie parametre et point
		-- correspondant sur la courbe)
		n = n + 1
		if n <= f then return n, self:Plot(n/f) end
	end
end

function bezierCub:Intersect(n1, n2)
	-- determine une APPROXIMATION de l'intersection de la courbe et
	-- de la droite formee par n1, n2
	-- (uniquement dans le cas ou une telle intersection est trouvee)
	-- l'approximation consiste a determiner la premiere intersection
	-- avec les segs segments qui composent la courbe, puis de calculer
	-- le parametre t qui correspond à la position de l'intersection
	local segs = 16
	local s1 = self[1] -- debut du segment a tester
	for i, s2 in self:Points(segs) do -- fin du segment a tester
		local den = (n1.x-n2.x)*(s1.y-s2.y)-(n1.y-n2.y)*(s1.x-s2.x)
		if den ~= 0 then
			-- les droites ne sont pas paralleles (il existe une
			-- intersection entre elles)
			local I = point(
				((n1.x*n2.y-n1.y*n2.x)*(s1.x-s2.x)
				-(n1.x-n2.x)*(s1.x*s2.y-s1.y*s2.x))/den,
				((n1.x*n2.y-n1.y*n2.x)*(s1.y-s2.y)
				-(n1.y-n2.y)*(s1.x*s2.y-s1.y*s2.x))/den)
			-- l'intersection avec la droite est-elle dans le segment?
			if I.x >= math.min(s1.x, s2.x)
			and I.x <= math.max(s1.x, s2.x)
			and I.y >= math.min(s1.y, s2.y)
			and I.y <= math.max(s1.y, s2.y) then
				-- le parametre correspondant au debut du
				-- segment PLUS la composante parcourue sur
				-- le segment l'approximation n'est bonne
				-- que pour des courbes relativement aplaties
				return (i-1+(I.x-s1.x)/(s2.x-s1.x))/segs
			end
		end
		s1 = s2
	end
end

-- FONCTIONS D'AFFICHAGE
function bezierCub:Draw(canvas, f)
	-- dessine en noir les f segments qui composent la courbe
	local black = canvas:colorResolve(0, 0, 0)
	local prev = self[1]
	for _, curr in self:Points(f) do
		canvas:line(prev.x, prev.y, curr.x, curr.y, black)
		prev = curr
	end
end

function bezierCub:TangentDraw(canvas, t)
	-- dessine en noir le segment partant du point sur la courbe
	-- au parametre t, de direction la tangente a la courbe en ce point
	-- et de longueur la norme de la derivee de la fonction de
	-- Bezier en ce point
	local p = self:Plot(t)
	local t = self:Tangent(t)
	local black = canvas:colorResolve(0, 0, 0)
	canvas:line(p.x, p.y, p.x+t.x, p.y+t.y, black)
end

function bezierCub:NormalDraw(canvas, t)
	-- dessine en noir le segment partant du point sur la courbe
	-- au parametre t, de direction la normale a la courbe en ce point
	-- et de longueur la norme de la derivee de la fonction de
	-- Bezier en ce point
	local p = self:Plot(t)
	local t = self:Normal(t)
	local black = canvas:colorResolve(0, 0, 0)
	canvas:line(p.x, p.y, p.x+t.x, p.y+t.y, black)
end

local function bincoeff(k, n)
	local c = 1
	for i = 1, k do
		c = c * (n+1-i)/i
	end
	return c
end

-------------------------------------------
-- CLASSE COURBES DE BEZIER GENERALISEES --
-------------------------------------------

bezierGen = {}
bezierGen.__index = bezierGen

-- pour creer une courbe de Bezier: "local b = bezierGen({p1, p2, ...})"
setmetatable(bezierGen, {__call = function (_, points)
		-- constructeur; les points sont obligatoires et doivent etre
		-- bien formes
		assert(#points > 0, "need at least one point")
		for _, p in ipairs(points) do
			assert(type(p.x) == "number",
				"Bezier parameters must be numbers")
			assert(type(p.y) == "number",
				"Bezier parameters must be numbers")
		end
		setmetatable(points, bezierGen)
		if #points == 1 then
			table.insert(points, points[1])
		end
		return points
	end})

function bezierGen:Plot(t)
	-- calcule le point sur la courbe au parametre t
	-- (t entre 0 et 1 pour etre à l'interieur de la courbe)
	local b = point(0, 0)
	local n = #self-1
	for i = 0, n do
		b = b + bincoeff(i, n)*(1-t)^(n-i)*t^i*self[i+1]
	end
	return b
end

function bezierGen:Tangent(t)
	-- calcule la DIRECTION de la tangente a la courbe au parametre t
	local b = point(0, 0)
	local n = #self-1
	for i = 0, n-1 do
		b = b + bincoeff(i, n-1)*t^i*(1-t)^(n-i-1)*n*(self[i+2]-self[i+1])
	end
	return b
end

function bezierGen:Normal(t)
	-- calcule la DIRECTION de la normale a la courbe au parametre t
	-- (rotation de la direction de la tangente de pi/2)
	local t = self:Tangent(t)
	return point(t.y, -t.x)
end

function bezierGen:Divide(f)
	-- renvoie les f+1 extremites des f segments qui composent la courbe
	local points = {}
	for n = 0, f do
		local p = self:Plot(n/f)
		table.insert(points, p)
	end
	return path(points)
end

function bezierGen:Points(f)
	-- usine pour l'iterateur
	local n = 0
	return function ()
		-- itere sur les f "fins" d'extremites des f segments qui
		-- composent la courbe (renvoie parametre et point
		-- correspondant sur la courbe)
		n = n + 1
		if n <= f then return n, self:Plot(n/f) end
	end
end

function bezierGen:Intersect(n1, n2)
	-- determine une APPROXIMATION de l'intersection de la courbe et
	-- de la droite formee par n1, n2
	-- (uniquement dans le cas ou une telle intersection est trouvee)
	-- l'approximation consiste a determiner la premiere intersection
	-- avec les segs segments qui composent la courbe, puis de calculer
	-- le parametre t qui correspond à la position de l'intersection
	local segs = 16
	local s1 = self[1] -- debut du segment a tester
	for i, s2 in self:Points(segs) do -- fin du segment a tester
		local den = (n1.x-n2.x)*(s1.y-s2.y)-(n1.y-n2.y)*(s1.x-s2.x)
		if den ~= 0 then
			-- les droites ne sont pas paralleles (il existe une
			-- intersection entre elles)
			local I = point(
				((n1.x*n2.y-n1.y*n2.x)*(s1.x-s2.x)
				-(n1.x-n2.x)*(s1.x*s2.y-s1.y*s2.x))/den,
				((n1.x*n2.y-n1.y*n2.x)*(s1.y-s2.y)
				-(n1.y-n2.y)*(s1.x*s2.y-s1.y*s2.x))/den)
			-- l'intersection avec la droite est-elle dans le segment?
			if I.x >= math.min(s1.x, s2.x)
			and I.x <= math.max(s1.x, s2.x)
			and I.y >= math.min(s1.y, s2.y)
			and I.y <= math.max(s1.y, s2.y) then
				-- le parametre correspondant au debut du
				-- segment PLUS la composante parcourue sur
				-- le segment l'approximation n'est bonne
				-- que pour des courbes relativement aplaties
				return (i-1+(I.x-s1.x)/(s2.x-s1.x))/segs
			end
		end
		s1 = s2
	end
end

-- FONCTIONS D'AFFICHAGE
function bezierGen:Draw(canvas, f)
	-- dessine en noir les f segments qui composent la courbe
	local black = canvas:colorResolve(0, 0, 0)
	local prev = self[1]
	if prev then
		for _, curr in self:Points(f) do
			canvas:line(prev.x, prev.y, curr.x, curr.y, black)
			prev = curr
		end
	end
end

function bezierGen:TangentDraw(canvas, t)
	-- dessine en noir le segment partant du point sur la courbe
	-- au parametre t, de direction la tangente a la courbe en ce point
	-- et de longueur la norme de la derivee de la fonction de
	-- Bezier en ce point
	local p = self:Plot(t)
	local t = self:Tangent(t)
	local black = canvas:colorResolve(0, 0, 0)
	canvas:line(p.x, p.y, p.x+t.x, p.y+t.y, black)
end

function bezierGen:NormalDraw(canvas, t)
	-- dessine en noir le segment partant du point sur la courbe
	-- au parametre t, de direction la normale a la courbe en ce point
	-- et de longueur la norme de la derivee de la fonction de
	-- Bezier en ce point
	local p = self:Plot(t)
	local t = self:Normal(t)
	local black = canvas:colorResolve(0, 0, 0)
	canvas:line(p.x, p.y, p.x+t.x, p.y+t.y, black)
end
