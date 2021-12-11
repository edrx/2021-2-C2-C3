-- This file:
--   http://angg.twu.net/LATEX/2021-1-C2-critical-points.lua.html
--   http://angg.twu.net/LATEX/2021-1-C2-critical-points.lua
--           (find-angg "LATEX/2021-1-C2-critical-points.lua")
-- Author: Eduardo Ochs <eduardoochs@gmail.com>
--
-- (defun l () (interactive) (find-LATEX "2021-1-C2-critical-points.lua"))
-- Used by: (find-LATEX "2021-1-C2-integral-figuras.tex")

-- «.f_do_slide_8»		(to "f_do_slide_8")
-- «.f_parabola_preferida»	(to "f_parabola_preferida")
--
-- «.Partition-tests»		(to "Partition-tests")
-- «.CriticalPoints-tests»	(to "CriticalPoints-tests")
-- «.Approxer-tests»		(to "Approxer-tests")
-- «.Piecewisify-tests»		(to "Piecewisify-tests")

require "edrxpict"  -- (find-LATEX "edrxpict.lua")


-- «f_do_slide_8»  (to ".f_do_slide_8")
-- (c2m211somas2p 8 "imagens-de-intervalos")
-- (c2m211somas2a   "imagens-de-intervalos")
f_do_slide_8 = function (x)
    if            x <= 3 then return x+3 end
    if 3 <  x and x <  8 then return 9-x end
    if 8 <= x            then return x-7 end
  end

-- «f_parabola_preferida»  (to ".f_parabola_preferida")
-- (c2m211somas1p 6 "exercicio-1")
-- (c2m211somas1a   "exercicio-1")
f_parabola_preferida = function (x) return 4 - (x-2)^2 end

--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2021-1-C2-critical-points.lua"
f = f_do_slide_8
= f(0)
= f(2)
= f(3)
= f(4)
= f(7)
= f(8)
= f(9)

f = f_parabola_preferida
= f(0), f(1), f(2), f(3), f(4)

--]]



Partition = Class {
  type = "Partition",
  new  = function (a, b) return Partition {points={a,b}} end,
  __index = {
    a = function (ptn) return ptn.points[1] end,
    b = function (ptn) return ptn.points[#ptn.points] end,
    N = function (ptn) return #ptn.points - 1 end,
    ai = function (ptn, i) return ptn.points[i] end,
    bi = function (ptn, i) return ptn.points[i+1] end,
    bminusa = function (ptn) return ptn:b() - ptn:a() end,
    splitn = function (ptn, N)
        local points = {}
        local Delta = ptn:bminusa()
        for k=0,N do table.insert(points, ptn:a() + Delta*(k/N)) end
        return Partition {points=points}
      end,
  },
}

-- «Partition-tests»  (to ".Partition-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2021-1-C2-critical-points.lua"

ptn = Partition.new(2, 10)
PPV(ptn)
PPV(ptn:splitn(4))

ptn = Partition.new(2, 10):splitn(4)
for i=1,ptn:N() do
  print(i, ptn:ai(i), ptn:bi(i))
end

--]]



CriticalPoints = Class {
  type  = "CriticalPoints",
  new   = function (f, allcriticalpoints)
      return CriticalPoints {f=f, allcriticalpoints=allcriticalpoints}
    end,
  __index = {
    criticalpointsin = function (cp, a, b)
        local A = {}
        for _,x in ipairs(cp.allcriticalpoints) do
          if a < x and x < b then table.insert(A, x) end
        end
        return A
      end,
    infin = function (cp, a, b)
        local inf = cp.f(a)
        local add = function (x) inf = min(inf, cp.f(x)) end
        add(b)
        for _,x in ipairs(cp:criticalpointsin(a, b)) do add(x) end
        return inf
      end,
    supin = function (cp, a, b)
        local sup = cp.f(a)
        local add = function (x) sup = max(sup, cp.f(x)) end
        add(b)
        for _,x in ipairs(cp:criticalpointsin(a, b)) do add(x) end
        return sup
      end,
    method = function (cp, method, a, b)
        return cp[method](cp, a, b)
      end,
  },
}

-- «CriticalPoints-tests»  (to ".CriticalPoints-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2021-1-C2-critical-points.lua"
cpf = CriticalPoints.new(f_do_slide_8, {3,8})
= cpf:supin(7, 9)
= cpf:infin(7, 9)
= cpf:method("supin", 7, 9)

--]]



-- (find-es "tex" "pict2e")
-- TODO: add support for using different colours for filling and
-- contour
--
Rect0 = Class {
  type = "Rect0",
  new  = function (a, b, y) return Rect0 {a=a, b=b, y=y} end,
  __index = {
    corners = function (r0) 
      local a, b, y = r0.a, r0.b, r0.y
        return pformat("(%s,%s)(%s,%s)(%s,%s)(%s,%s)", a,y, b,y, b,0, a,0)
      end,
    pict = function (r0, what)
        str = ""
        corners = r0:corners()
        if what:match"c" then str = str .. "\\polygon*" .. corners .. "%\n" end
        if what:match"a" then str = str .. "\\polygon"  .. corners .. "%\n" end
        return str
      end,
  },
}

--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2021-1-C2-critical-points.lua"
r0 = Rect0.new(1, 2, 3)
= r0:pict("a")
= r0:pict("c")
= r0:pict("ac")

--]]




Approxer = Class {
  type    = "Approxer",
  __index = {
    pict = function (ap, N, method, what)
        bigstr = ""
        local cp = CriticalPoints.new(ap.f, ap.allcps)
        local pt = Partition.new(ap.a, ap.b):splitn(N or ap.N)
        for i=1,pt:N() do
          local ai,bi = pt:ai(i), pt:bi(i)
          local y = cp:method(method or ap.method, ai, bi)
          local pict = Rect0.new(ai, bi, y):pict(what or ap.what)
          bigstr = bigstr .. pict
        end
        return bigstr
      end,
  },
}

-- «Approxer-tests»  (to ".Approxer-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2021-1-C2-critical-points.lua"

appr = Approxer {
    f      = f_do_slide_8,
    allcps = {3,8},
    a      = 2,
    b      = 10,
    N      = 4,
    method = "supin",
    what   = "ac",
  }

= appr:pict()
= appr:pict(2, "infin", "c")

--]]


--    criticalpointsin = function (cp, a, b)
--        local A = {}
--        for _,x in ipairs(cp.allcriticalpoints) do
--          if a < x and x < b then table.insert(A, x) end
--        end
--        return A
--      end,
--    infin = function (cp, a, b)
--        local inf = cp.f(a)
--        local add = function (x) inf = min(inf, cp.f(x)) end
--        add(b)
--        for _,x in ipairs(cp:criticalpointsin(a, b)) do add(x) end
--        return inf
--      end,
--    supin = function (cp, a, b)
--        local sup = cp.f(a)
--        local add = function (x) sup = max(sup, cp.f(x)) end
--        add(b)
--        for _,x in ipairs(cp:criticalpointsin(a, b)) do add(x) end
--        return sup
--      end,
--    method = function (cp, method, a, b)
--        return cp[method](cp, a, b)
--      end,


Piecewisify = Class {
  type = "Piecewisify",
  new  = function (f, ...)
      return Piecewisify({f=f}):setpoints(...)
    end,
  __index = {
    addpoint = function (pwi, p)
        if type(p) ~= "number" then PP("Not a number:", p); error() end
        pwi.points:add(p)
        return pwi
      end,
    addlistofpoints = function (pwi, A)
        for _,p in ipairs(A) do pwi:addpoint(p) end
        return pwi
      end,
    addpoints = function (pwi, ...)
        for _,o in ipairs({...}) do
          if     type(o) == "number" then pwi:addpoint(o)
          elseif type(o) == "table"  then pwi:addlistofpoints(o) 
          else   PP("not a point or a list of points:", o); error()
          end
        end
        return pwi
      end,
    setpoints = function (pwi, ...)
        pwi.points = SetL.new()
        return pwi:addpoints(...)
      end,
    -- See: (find-angg "LUA/lua50init.lua" "SetL")
    --
    pointsin = function (pwi, a, b)
        local A = {}
        for _,x in ipairs(pwi.points:ks()) do
          if a < x and x < b then table.insert(A, x) end
        end
        return A
      end,
    --
    eps = 1/32768,
    delta = 1/128,
    hasjump = function (pwi, x0, x1)
        local y0,y1 = pwi.f(x0), pwi.f(x1)
        return math.abs(y1-y0) > pwi.delta
      end,
    hasjumpl = function (pwi, x) return pwi:hasjump(x - pwi.eps, x) end,
    hasjumpr = function (pwi, x) return pwi:hasjump(x, x + pwi.eps) end,
    --
    xy = function (pwi, x, y)  return pformat("(%s,%s)", x, y or pwi.f(x)) end,
    xyl = function (pwi, xc) return pwi:xy(xc - pwi.eps) end,
    xyr = function (pwi, xc) return pwi:xy(xc + pwi.eps) end,
    jumps_and_xys = function (pwi, xc)
        local xyl, xyc, xyr = pwi:xyl(xc), pwi:xy(xc), pwi:xyr(xc)
        local jumpl = pwi:hasjumpl(xc) and "l" or ""
        local jumpr = pwi:hasjumpr(xc) and "r" or ""
        local jumps = jumpl..jumpr
        return jumps, xyl, xyc, xyr
      end,
    piecewise_m = function (pwi, xc)   -- "m" is for "middle"
        local jumps, xyl, xyc, xyr = pwi:jumps_and_xys(xc)
        if     jumps == ""   then str = xyc
        elseif jumps == "l"  then str = format("%so %sc", xyl, xyc)
        elseif jumps == "r"  then str = format("%sc %so", xyc, xyr)
        elseif jumps == "lr" then str = format("%so %sc %so", xyl, xyc, xyr)
        end
        return str
      end,
    piecewise = function (pwi, a, b, method, sep)
        local method, sep = method or "piecewise_m", sep or "--"
        local f = function (x) return pwi[method](pwi, x) end
        local str = pwi:xyr(a)
        -- for _,x in ipairs(pwi.points:ks()) do
        --   if a < x and x < b then
        --     str = str..sep..f(x)
        --   end
        -- end
        for _,x in ipairs(pwi:pointsin(a, b)) do
	  str = str..sep..f(x)
	end
        str = str..sep..pwi:xyl(b)
        return str
      end,
    pw = function (pwi, a, b)
        return pictpiecewise(pwi:piecewise(a, b))
      end,
    -- See: (find-LATEX "edrxpict.lua" "Piecewise")
    --      (find-LATEX "edrxpict.lua" "Piecewise" "pictpiecewise =")
    --
    piecewise_pol1 = function (pwi, xc) -- for polygons
        local jumps, xyl, xyc, xyr = pwi:jumps_and_xys(xc)
        if jumps == ""  
        then return xyc
        else return format("%s%s", xyl, xyr)
        end
      end,
    piecewise_pol = function (pwi, a, b)
        local a0, b0 = pwi:xy(a, 0), pwi:xy(b, 0)
        return a0..pwi:piecewise(a, b, "piecewise_pol1", "")..b0
      end,
    pol = function (pwi, a, b, star)
        return "\\polygon"..(star or "")..pwi:piecewise_pol(a, b)
      end,
    --
    inforsup = function (pwi, maxormin, a, b)
        local y = pwi.f(a)
        local consider = function (x) y = maxormin(y, pwi.f(x)) end
        consider(a + pwi.eps)
        for _,x in ipairs(pwi:pointsin(a, b)) do
          consider(x - pwi.eps)
          consider(x)
          consider(x + pwi.eps)
        end
        consider(b - pwi.eps)
        consider(b)
        return y
      end,
    inf = function (pwi, a, b) return pwi:inforsup(min, a, b) end,
    sup = function (pwi, a, b) return pwi:inforsup(max, a, b) end,
    max = function (pwi, a, b) return max(pwi.f(a), pwi.f(b)) end,
    min = function (pwi, a, b) return min(pwi.f(a), pwi.f(b)) end,
    zero = function (pwi) return 0 end,
    method = function (pwi, mname, a, b) return pwi[mname](pwi, a, b) end,
    rct = function (pwi, mname1, mname2, a, b)
        local y1 = pwi:method(mname1, a, b)
        local y2 = pwi:method(mname2 or "zero", a, b)
        return pformat("(%s,%s)(%s,%s)(%s,%s)(%s,%s)", a,y1, a,y2, b,y2, b,y1)
      end,
    rects = function (pwi, ptn, mname1, mname2, star)
        local str = ""
        for i=1,ptn:N() do
          local ai,bi = ptn:ai(i), ptn:bi(i)
          local rct = pwi:rct(mname1, mname2, ai, bi)
          str = str .. format("\\polygon%s%s\n", star or "*", rct)
        end
        return str
      end,
  },
}


-- «Piecewisify-tests»  (to ".Piecewisify-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2021-1-C2-critical-points.lua"

f_parabola_2 = function (x)
    if x <= 4 then return f_parabola_preferida(x) end
    if x <  5 then return 2 end
    if x == 5 then return 3 end
    if x < 6  then return 1 end
    return 0
  end

pwi = Piecewisify {f = f_parabola_2}
pwi:setpoints(2, 3, seq(0, 1, 0.25))

pwi = Piecewisify.new(f_parabola_2, seq(0, 4, 0.25), 5, 6)
pwi = Piecewisify.new(f_parabola_2, seq(0, 4, 1   ), 5, 6)
= pwi.points:ksc(" ")

= pwi:piecewise_m(2)
= pwi:piecewise_m(4)
= pwi:piecewise_m(5)
= pwi:piecewise_m(6)
= pwi:piecewise(0, 7)
= pwi:pw(0, 7)

= pwi:piecewise_pol(0, 7)
= pwi:pol(0, 7)
= pwi:pol(0, 7, "*")

= pwi:sup(0.5, 2.5)
= pwi:inf(0.5, 2.5)
= pwi:rct("sup", "inf", 0.5, 2.5)
= pwi:rects(Partition.new(0, 2):splitn(4), "sup")
= pwi:rects(Partition.new(0, 2):splitn(4), "sup", "inf")

--]]



--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2021-1-C2-critical-points.lua"

dirichlet_incl_Q = SetL.new()
dirichlet_incl   = function (x)
    if dirichlet_incl_Q:has(x) then return x end
    return x+1
  end
for _,x in ipairs(seq(0, 1, 1/16)) do
  dirichlet_incl_Q:add(x)
end
pwid = Piecewisify.new(dirichlet_incl, seq(0, 1, 1/16))

= dirichlet_incl(0.25)
= dirichlet_incl(0.2)

--]]
