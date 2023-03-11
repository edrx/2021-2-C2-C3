-- This file:
-- http://angg.twu.net/LATEX/edrxtikz.lua
-- http://angg.twu.net/LATEX/edrxtikz.lua.html
--  (find-angg        "LATEX/edrxtikz.lua")
--
-- This is a mess.
-- Version: 2021feb08

-- «.Line»		(to "Line")
-- «.Line-test»		(to "Line-test")
-- «.Ellipse»		(to "Ellipse")
-- «.Ellipse-test»	(to "Ellipse-test")
-- «.Hyperbole»		(to "Hyperbole")
-- «.Hyperbole-test»	(to "Hyperbole-test")
-- «.Hyperbole.fromOxe»	(to "Hyperbole.fromOxe")
-- «.Parabola»		(to "Parabola")
-- «.Parabola-test»	(to "Parabola-test")
-- «.drawdots0»		(to "drawdots0")

loaddednat6("dednat6/")  -- (find-angg "LUA/lua50init.lua" "loaddednat6")
seqndraw = function (a, b, n, f, sep)
    local A = {}
    for i=0,n do table.insert(A, tostring(f(a + (b-a)*(i/n)))) end
    return table.concat(A, sep or " -- ")
  end

-- (find-dn6 "picture.lua" "V")
-- Add several methods for Analytic Geometry to the class V.
V.__div        = function (v, k) return v*(1/k) end
V.__index.proj = function (u, v) return ((u*v)/(u*u))*u end
V.__index.tow  = function (A, B, t) return A+(B-A)*t   end  -- towards
V.__index.mid  = function (A, B)    return A+(B-A)*0.5 end  -- midpoint
V.__index.norm = function (v) return math.sqrt(v[1]*v[1] + v[2]*v[2]) end
V.__index.rotleft  = function (vv) return v(-vv[2], vv[1]) end -- 90 degrees
V.__index.rotright = function (vv) return v(vv[2], -vv[1]) end -- 90 degrees

V.__index.unit = function (v, len)      -- unitarize (and multiply by len)
    return v*((len or 1)/v:norm())
  end
V.__index.rot  = function (v, angle)    -- rotate left angle degrees
    local c, s = math.cos(math.rad(angle)), math.sin(math.rad(angle))
    return v*c + v:rotleft()*s
  end

-- (find-dn6 "output.lua" "formatt")




--  _     _            
-- | |   (_)_ __   ___ 
-- | |   | | '_ \ / _ \
-- | |___| | | | |  __/
-- |_____|_|_| |_|\___|
--                     
-- «Line» (to ".Line")
-- Parametrized lines.
Line = Class {
  new   = function (A, v, mint, maxt)
      return Line {A=A, v=v, mint=mint, maxt=maxt}
    end,
  newAB = function (A, B, mint, maxt) return Line.new(A, B-A, mint, maxt) end,
  type  = "Line",
  __tostring = function (li) return li:tostring() end,
  __index = {
    t = function (li, t) return li.A + t * li.v end,
    draw = function (li) return formatt("%s -- %s", li:t(li.mint), li:t(li.maxt)) end,
    tostring = function (li) return formatt("%s + t%s", li.A, li.v) end,
    proj = function (li, P) return li.A + li.v:proj(P - li.A) end,
    sym = function (li, P) return P + 2*(li:proj(P) - P) end,
    --
    pict = function (li) return formatt("\\Line%s%s", li:t(li.mint), li:t(li.maxt)) end,
    --
    -- (find-dn6 "picture.lua" "pict2e" "pict2evector =")
    pictv = function (li)
        local x0,y0 = li:t(li.mint):to_x_y()
        local x1,y1 = li:t(li.maxt):to_x_y()
        return pict2evector(x0, y0, x1, y1)
      end,
  },
}

-- «Line-test» (to ".Line-test")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "edrxtikz.lua"
r = Line.new(v(0, 1), v(3, 2), -1, 2)
= r
= r:t(0)
= r:t(0.1)
= r:t(1)
= r:draw()
= r:pict()

= r:proj(v(0, 1))
= r:proj(v(-2, 4))
= r:sym(v(0, 1))
= r:sym(v(-2, 4))

--]]



--  _____ _ _ _                
-- | ____| | (_)_ __  ___  ___ 
-- |  _| | | | | '_ \/ __|/ _ \
-- | |___| | | | |_) \__ \  __/
-- |_____|_|_|_| .__/|___/\___|
--             |_|             
--
-- «Ellipse» (to ".Ellipse")
Ellipse = Class {
  type    = "Ellipse",
  new = function (C0, u, v) return Ellipse {C0=C0, u=u, v=v} end,
  newcircle = function (C0, R) return Ellipse {C0=C0, u=v(R, 0), v=v(0, R), R=R} end,
  __tostring = function (e) return e:tostring() end,
  __index = {
    tostring = function (e)
        return format("%s + c%s + s%s", tostring(e.C0), tostring(e.u), tostring(e.v))
      end,
    rad = function (e, rads)
        local c, s = math.cos(rads), math.sin(rads)
        return e.C0 + c*e.u + s*e.v
      end,
    deg = function (e, degs) return e:rad(math.rad(degs)) end,
    draw = function (e, n)
        return seqndraw(0, 2*math.pi, n or 40, function (rads) return e:rad(rads) end)
      end,
    --
    points = function (e, n, a, b)
        local F = function (t) return e:deg(t) end
        return Points.fromFt(a or 0, b or 360, n or 24, F)
      end,
    pict = function (e, n, a, b) return e:points(n, a, b):line() end,
  },
}

-- «Ellipse-test»  (to ".Ellipse-test")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "edrxtikz.lua"
e = Ellipse.new(v(2,3), v(4,0), v(0,5))
PP(e)
= e 
= e:deg(0)
= e:deg(90)
= e:deg(180)
= e:draw(4)
= e:draw()

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "edrxpict.lua"
e = Ellipse.new(v(2,3), v(4,0), v(0,5))
= e:points()
= e:pict()

--]]



--  _   _                       _           _      
-- | | | |_   _ _ __   ___ _ __| |__   ___ | | ___ 
-- | |_| | | | | '_ \ / _ \ '__| '_ \ / _ \| |/ _ \
-- |  _  | |_| | |_) |  __/ |  | |_) | (_) | |  __/
-- |_| |_|\__, | .__/ \___|_|  |_.__/ \___/|_|\___|
--        |___/|_|                                 
--
-- «Hyperbole» (to ".Hyperbole")
Hyperbole = Class {
  type    = "Hyperbole",
  new = function (H0, u, v, maxt) return Hyperbole {H0=H0, u=u, v=v, maxt=maxt} end,
  __tostring = function (h) return h:tostring() end,
  __index = {
    tostring = function (h)
        return formatt("%s + t%s + (1/t)%s", h.H0, h.u, h.v)
      end,
    t = function (h, t)
        return h.H0 + t*h.u + (1/t)*h.v
      end,
    draw = function (h, n)
        n = n or 5
        local f = function (t) return h:t(t)   end
        local g = function (t) return h:t(1/t) end
        local part1 = seqndraw(-h.maxt, -1, n, f)
        local part2 = seqndraw(-h.maxt, -1, n, g)
        local part3 = seqndraw(1,   h.maxt, n, g)
        local part4 = seqndraw(1,   h.maxt, n, f)
        PP(part1, part2, part3, part4)
        return format("%s  %s  %s  %s", part1, part2, part3, part4)
      end,
    drawau = function (h, a, b)
        return formatt("%s -- %s", h.H0 + a*h.u, h.H0 + b*h.u)
      end,
    drawav = function (h, a, b)
        return formatt("%s -- %s", h.H0 + a*h.v, h.H0 + b*h.v)
      end,
    --
    points = function (h, n, t1, t2)
        local F = function (ti) return h:t(ti) end
        return Points.fromFt(t1, t2, n, F)
      end,
    pict = function (h, n, t1, t2, t3, t4)
        return h:points(n, t1, t2):line().."\n"..h:points(n, t3, t4):line()
      end,
  },
}

-- «Hyperbole-test»  (to ".Hyperbole-test")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "edrxtikz.lua"
h = Hyperbole.new(v(0,0), v(1,0), v(0,1), 4)
= h:t(1)
= h:t(2)
= h:draw(3)
= h
= h:drawau(-2, 2)
= h:drawav(-2, 2)

--]]


-- «Hyperbole.fromOxe» (to ".Hyperbole.fromOxe")
Hyperbole.fromOxe = function (O, xx, e, maxt)
    local yy = xx:rotleft()
    local ee = e*e - 1
    local es = math.sqrt(e*e - 1)
    local a  = xx:norm()/2
    local b  = es * a
    local c  = e  * a
    local u  = a*xx - b*yy
    local v  = a*xx + b*yy
    local P1, P2 = O -   xx, O + xx
    local F1, F2 = O - e*xx, O + e*xx
    local D1, D2 = O - xx/e, O + xx/e
    local P3, P4 = F1 + ee*yy, F2 + ee*yy 
    local P5, P6 = F1 - ee*yy, F2 - ee*yy 
    local D0 = O
    local d0 = Line.new(D0, yy, -maxt, maxt)
    local d1 = Line.new(D1, yy, -maxt, maxt)
    local d2 = Line.new(D2, yy, -maxt, maxt)
    local au = Line.new( O,  u, -maxt, maxt)
    local av = Line.new( O,  v, -maxt, maxt)
    local data = {O=O, xx=xx, yy=yy, e=e, a=a, b=b, c=c, u=u, v=v,
                  F1=F1, F2=F2, P1=P1, P2=P2, P3=P3, P4=P4, P5=P5, P6=P6,
                  D0=D0, D1=D1, D2=D2, d0=d0, d1=d1, d2=d2, au=au, av=av,
                  H0=O, maxt=maxt}
    return Hyperbole(data)
  end

--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "edrxtikz.lua"
H = Hyperbole.fromOxe(v(0,0), v(1,0), 2, 4)
H = Hyperbole.fromOxe(v(0,0), v(1,0), 3, 6)
PP(H)

--]]





--  ____                 _           _       
-- |  _ \ __ _ _ __ __ _| |__   ___ | | __ _ 
-- | |_) / _` | '__/ _` | '_ \ / _ \| |/ _` |
-- |  __/ (_| | | | (_| | |_) | (_) | | (_| |
-- |_|   \__,_|_|  \__,_|_.__/ \___/|_|\__,_|
--                                           
-- «Parabola» (to ".Parabola")
Parabola = Class {
  type    = "Parabola",
  new = function (P0, u, v, maxt) return Parabola {P0=P0, u=u, v=v, maxt=maxt} end,
  __tostring = function (p) return p:tostring() end,
  __index = {
    tostring = function (p)
        return formatt("%s + t%s + t^2%s", p.P0, p.u, p.v)
      end,
    t = function (p, t)
        return p.P0 + t*p.u + t*t*p.v
      end,
    draw = function (p, n)
        return seqndraw(-p.maxt, p.maxt, n or 10, function (t) return p:t(t) end)
      end,
    --
    points = function (p, n, t1, t2)
        local F = function (ti) return p:t(ti) end
        return Points.fromFt(t1, t2, n, F)
      end,
    pict = function (p, n, t1, t2)
        return p:points(n, t1, t2):line()
      end,
  },
}

-- «Parabola-test»  (to ".Parabola-test")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "edrxtikz.lua"
p = Parabola.new(v(0,0), v(1,0), v(0,1), 3)
= p:t(0)
= p:t(1)
= p:t(2)
= p:draw(6)
= p

--]]



--      _                       _       _        ___  
--   __| |_ __ __ ___      ____| | ___ | |_ ___ / _ \ 
--  / _` | '__/ _` \ \ /\ / / _` |/ _ \| __/ __| | | |
-- | (_| | | | (_| |\ V  V / (_| | (_) | |_\__ \ |_| |
--  \__,_|_|  \__,_| \_/\_/ \__,_|\___/ \__|___/\___/ 
--                                                    
-- «drawdots0» (to ".drawdots0")
-- (find-LATEXfile "2015-2-C2-material.tex" "drawdots")
drawdots0 = function (str)
    local str0 = str:gsub("(%b())[oc]", "%1")
    local str1 = "\\draw[mycurve] "..str0..";\n"
    local str2 = ""
    for a,b in str:gmatch("(%b())([oc])") do
      str2 = str2 .. format("\\node at %s [%s] {};\n", a, b=="o" and "opdot" or "cldot")
    end
    return str1..str2
  end

--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "edrxtikz.lua"
= drawdots0 " (1,2)o -- (2,3)c -- (3,3) "

--]]





--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "edrxtikz.lua"

--]]


-- Local Variables:
-- coding: raw-text-unix
-- End:

