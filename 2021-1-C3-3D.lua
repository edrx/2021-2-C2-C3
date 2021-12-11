-- This file:
--   http://angg.twu.net/LATEX/2021-1-C3-3D.lua.html
--   http://angg.twu.net/LATEX/2021-1-C3-3D.lua
--           (find-angg "LATEX/2021-1-C3-3D.lua")
-- Author: Eduardo Ochs <eduardoochs@gmail.com>
--
-- (defun e () (interactive) (find-LATEX "2021-1-C3-notacao-de-fisicos.tex"))
-- (defun l () (interactive) (find-angg "LATEX/2021-1-C3-3D.lua"))
--
-- Based on:
-- (find-LATEX "2020-2-C3-plano-tang.lua" "V3")
-- (find-LATEX "2020-2-C3-plano-tang.lua" "pictreplace")



-- «.V3»			(to "V3")
-- «.pictreplace»		(to "pictreplace")
-- «.Surface»			(to "Surface")
-- «.Surface-tests»		(to "Surface-tests")
-- «.QuadraticFunction»		(to "QuadraticFunction")
-- «.QuadraticFunction-tests»	(to "QuadraticFunction-tests")

loaddednat6()


-- «V3»  (to ".V3")
-- (find-es "dednat" "V3")
--
V3 = Class {
  type    = "V3",
  __tostring = function (v) return v:tostring() end,
  __add      = function (v, w) return V3{v[1]+w[1], v[2]+w[2], v[3]+w[3]} end,
  __sub      = function (v, w) return V3{v[1]-w[1], v[2]-w[2], v[3]-w[3]} end,
  __unm      = function (v) return v*-1 end,
  __mul      = function (v, w)
      local ktimesv   = function (k, v) return V3{k*v[1], k*v[2], k*v[3]} end
      local innerprod = function (v, w) return v[1]*w[1] + v[2]*w[2] + v[3]*w[3] end
      if     type(v) == "number" and type(w) == "table" then return ktimesv(v, w)
      elseif type(v) == "table" and type(w) == "number" then return ktimesv(w, v)
      elseif type(v) == "table" and type(w) == "table"  then return innerprod(v, w)
      else error("Can't multiply "..tostring(v).."*"..tostring(w))
      end
    end,
  __index = {
    tostring = function (v) return v:v3string() end,
    v3string = function (v) return pformat("(%s,%s,%s)", v[1], v[2], v[3]) end,
    v2string = function (v) return tostring(v:tov2()) end,
    --
    -- Convert v3 to v2 using a primitive kind of perspective.
    -- Adjust p1, p2, p3 to change the perspective.
    tov2 = function (v) return v[1]*v.p1 + v[2]*v.p2 + v[3]*v.p3 end,
    p1 = V{2,-1},
    p2 = V{2,1},
    p3 = V{0,2},
    --
    Line = function (A, v) return pformat("\\Line%s%s", A, A+v) end,
    Lines = function (A, v, w, i, j)
        local bprint, out = makebprint()
        for k=i,j do bprint((A+k*w):Line(v)) end
        return out()
      end,
    --
    xticks = function (_,n,eps)
        eps = eps or 0.15
        return v3(0,-eps,0):Lines(v3(0,2*eps,0), v3(1,0,0), 0, n)
      end,
    yticks = function (_,n,eps)
        eps = eps or 0.15
        return v3(-eps,0,0):Lines(v3(2*eps,0,0), v3(0,1,0), 0, n)
      end,
    zticks = function (_,n,eps)
        eps = eps or 0.15
        return v3(-eps,0,0):Lines(v3(2*eps,0,0), v3(0,0,1), 0, n)
      end,
    axeswithticks = function (_,x,y,z)
        local bprint, out = makebprint()
	bprint(v3(0,0,0):Line(v3(x+0.5, 0, 0)))
	bprint(v3(0,0,0):Line(v3(0, y+0.5, 0)))
	bprint(v3(0,0,0):Line(v3(0, 0, z+0.5)))
        bprint(_:xticks(x))
        bprint(_:yticks(y))
        bprint(_:zticks(z))
        return out()
      end,
    xygrid = function (_,x,y)
        local bprint, out = makebprint()
        bprint(v3(0,0,0):Lines(v3(0,y,0), v3(1,0,0), 0, x))
        bprint(v3(0,0,0):Lines(v3(x,0,0), v3(0,1,0), 0, y))
        return out()
      end,
  },
}

v3 = function (x,y,z) return V3{x,y,z} end

-- Choose one:
V3.__index.tostring = function (v) return v:v2string() end
V3.__index.tostring = function (v) return v:v3string() end




-- «pictreplace»  (to ".pictreplace")
-- (find-es "dednat" "pictreplace")
--
pictreplace = function (bigstr)
    -- local f = function (code) return tostring(expr(code)) end
    local f = function (code) return deletecomments(tostring(expr(code))) end
    local g = function (line) return (line:gsub("<([^<>]+)>", f)) end
    return (bigstr:gsub("[^\n]+", g))
  end

registerhead "%P" {
  name   = "pictreplace",
  action = function ()
      local i,j,pictcode = tf:getblockstr(3)
      output(pictreplace(pictcode))
    end,
}



-- «Surface»  (to ".Surface")
-- (find-dn6 "picture.lua" "V")
-- (find-dn6 "diagforth.lua" "newnode:at:")
--
Surface = Class {
  type = "Surface",
  new  = function (f, x0, y0)
      return Surface {f=f, x0=x0, y0=y0, xy0=v(x0, y0)}
    end,
  __index = {
    xyz = function (s, xy, zvalue)
        return v3(xy[1], xy[2], zvalue or s.f(xy[1], xy[2]))
      end,
    xyztow = function (s, xy1, xy2, zvalue, k)
        return s:xyz(tow(xy1, xy2, k), zvalue)
      end,
    segment = function (s, xy1, xy2, zvalue, n)
        local str = ""
        for i=0,n do
          str = str .. s:xyztow(xy1, xy2, zvalue, i/n):tostring()
        end
        return "\\Line"..str
      end,
    pillar = function (s, xy)
        return "\\Line" ..
	  s:xyz(xy,   0):tostring() ..
	  s:xyz(xy, nil):tostring()
      end,
    pillars = function (s, xy1, xy2, n)
        local str = ""
        for i=0,n do str = str..s:pillar(tow(xy1, xy2, i/n)).."%\n" end
        return str
      end,
    segmentstuff = function (s, xy1, xy2, n, what)
        local str = ""
        if what:match"0" then str = str..s:segment(xy1, xy2, 0,   1).."%\n" end
        if what:match"c" then str = str..s:segment(xy1, xy2, nil, n).."%\n" end
        if what:match"p" then str = str..s:pillars(xy1, xy2,      n)      end
        return str
      end,
    --
    stoxy = function (s, str)
        expr(format("v(%s)", str))
      end,
    squarestuff = function (s, dxy0s, dxy1s, n, what)
        local dxy0 = expr(format("v(%s)", dxy0s))
        local dxy1 = expr(format("v(%s)", dxy1s))
        local xy1 = s.xy0 + dxy0
        local xy2 = s.xy0+dxy1
        return s:segmentstuff(xy1, xy2, n, what)
      end,
    squarestuffp = function (s, n, what, pair)
        local dxy0,dxy1 = unpack(split(pair))
	return s:squarestuff(dxy0, dxy1, n, what)
      end,
    squarestuffps = function (s, n, what, listofpairs)
        local str = ""
        for _,pair in ipairs(listofpairs) do
          str = str .. s:squarestuffp(n, what, pair)
        end
        return str
      end,
    --
    horizontals = function (s, n, what)
        return s:squarestuffps(n, what, {
          "-1,-1 1,-1", "-1,0 1,0", "-1,1 1,1"
          })
      end,
    verticals = function (s, n, what)
        return s:squarestuffps(n, what, {
          "-1,-1 -1,1", "0,-1 0,1", "1,-1 1,1"
          })
      end,
    diagonals = function (s, n, what)
        return s:squarestuffps(n, what, {
          "-1,-1 1,1", "-1,1 1,-1"
          })
      end,
    square = function (s, n, what)
        return s:horizontals(n, what)
             ..s:verticals  (n, what)
      end,
  },
}

-- «Surface-tests»  (to ".Surface-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2021-1-C3-3D.lua"

F = function (x, y) return 10*x + y end
srf = Surface.new(F, 3, 4)
= srf:xyz(v(2, 5))
= srf:xyz(v(2, 5), 0)

= srf:xyztow(v(2,5), v(22,25), nil,  0.5)
= srf:xyztow(v(2,5), v(22,25), 0,    0.5)
= srf:segment(v(2,5), v(22,25), 0,   2)
= srf:segment(v(2,5), v(22,25), nil, 2)
= srf:pillar(v(2,5))
= srf:segmentstuff(v(2,5), v(22,25), 2, "0cp")

= srf:squarestuff("0,0", "2,2", 2, "0")
= srf:squarestuff("0,0", "2,2", 2, "c")
= srf:squarestuff("0,0", "2,2", 2, "p")
= srf:squarestuffp(             2, "p", "0,0 2,2")

= srf:square   (2, "p")
= srf:square   (4, "p")
= srf:square   (2, "c")
= srf:square   (4, "c")
= srf:square   (8, "c")
= srf:diagonals(2, "p")

fw = function (x) return max(min(x-2, 6-x), 0) end
FP = function (x,y) return min(fw(x), fw(y)) end
FC = function (x,y) return max(fw(x), fw(y)) end
sP = Surface.new(FP, 4, 4)
= sP:segment(v(0,4), v(6,4), nil, 6)

-- ^ Used by:
-- (c3m211cnp 15 "figura-piramide")
-- (c3m211cna    "figura-piramide")
-- (c3m211cnp 16 "cruz")
-- (c3m211cna    "cruz")

--]]


-- «QuadraticFunction»  (to ".QuadraticFunction")
--
QuadraticFunction = Class {
  type   = "QuadraticFunction",
  __call = function (q, ...) return q:f(...) end,
  __index = {
    f = function (q, x, y)
        local dx,dy = x - (q.x0 or 0), y - (q.y0 or 0)
        return (q.a or 0)
             + (q.Dx  or 0) * dx    + (q.Dy  or 0) * dy
             + (q.Dxx or 0) * dx*dx + (q.Dyy or 0) * dy*dy
             + (q.Dxy or 0) * dx*dy
      end,
  },
}

-- «QuadraticFunction-tests»  (to ".QuadraticFunction-tests")
-- Used by: (c3m211qp 2 "figuras-3D")
--          (c3m211qa   "figuras-3D")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2021-1-C3-3D.lua"

qf = QuadraticFunction {x0=3, y0=2, a=100, Dx=0, Dy=0, Dxx=1, Dyy=1, Dxy=0}
= qf(3, 2)
= qf(3 + 1, 2)
= qf(3 + 1, 2 + 1)

qf = QuadraticFunction {Dx=10, Dy=1}
= qf(2, 3)

qf = QuadraticFunction {Dx=10, Dy=1, x0=20, y0=30, a=100}
= qf(20, 30)
= qf(22, 33)

qf = QuadraticFunction {Dxx=100, Dxy=10, Dyy=1}
= qf(2, 3)
= qf(2, 0)
= qf(0, 3)

--]]

