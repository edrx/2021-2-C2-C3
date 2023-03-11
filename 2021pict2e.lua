-- This file:
--   http://angg.twu.net/LATEX/2021pict2e.lua.html
--   http://angg.twu.net/LATEX/2021pict2e.lua
--           (find-angg "LATEX/2021pict2e.lua")
-- Author: Eduardo Ochs <eduardoochs@gmail.com>
--
-- (defun e () (interactive) (find-angg "LATEX/2021pict2e.tex"))
-- (defun l () (interactive) (find-angg "LATEX/2021pict2e.lua"))

-- See: (find-angg "SRF/srfb.lua" "Pict2e")
--      (find-angg "SRF/srfb.lua" "Pict2e-tests")
--      (find-angg "SRF/srfb.lua" "Points-tests")
--      (find-LATEXfile "2021repl-pict.lua")
--      (find-LATEXfile "2021repl-pict.tex")
--      (find-angg "LATEX/edrxpict.lua")
-- (find-LATEXgrep "grep --color=auto -nH --null -e 2021pict2e.lua *.tex")



loaddednat6("dednat6/")

-- «.Pict2e»			(to "Pict2e")
-- «.Pict2e-tests»		(to "Pict2e-tests")
-- «.Points2»			(to "Points2")
-- «.Points2-tests»		(to "Points2-tests")
-- «.PictBounds»		(to "PictBounds")
-- «.PictBounds-tests»		(to "PictBounds-tests")
-- «.Pict2eVector»		(to "Pict2eVector")
-- «.Pict2eVector-tests»	(to "Pict2eVector-tests")
--
-- «.Piecewise»			(to "Piecewise")
-- «.Piecewise-tests»		(to "Piecewise-tests")
-- «.Piecewisify»		(to "Piecewisify")
-- «.Piecewisify-tests»		(to "Piecewisify-tests")
-- «.Partition»			(to "Partition")
-- «.Partition-tests»		(to "Partition-tests")



--  ____  _      _   ____      
-- |  _ \(_) ___| |_|___ \ ___ 
-- | |_) | |/ __| __| __) / _ \
-- |  __/| | (__| |_ / __/  __/
-- |_|   |_|\___|\__|_____\___|
--                             
-- «Pict2e»  (to ".Pict2e")
--
Pict2e = Class {
  type = "Pict2e",
  new  = function () return Pict2e {lines={}, pb=nil} end,
  from = function (o)
      if otype(o) == "Pict2e" then
        return Pict2e {lines = copy(o.lines), pb = o.pb}
      end
      if type(o)  == "string" then return Pict2e {lines = splitlines(o)} end
      if type(o)  == "table"  then return Pict2e {lines = copy(o)} end
      error("From?")
    end,
  Line   = function (...) return Points2({...}):Line() end,
  bounds = function (...) return Pict2e.new():setbounds(...) end,
  bgat   = function (...) return Pict2e.bounds(...):grid():axesandticks() end,
  --
  __tostring = function (p) return p:tostring() end,
  --
  __mul = function (prefix, p)
      local f = function (li) return prefix..li end
      return Pict2e {lines = map(f, p.lines), pb = p.pb}
    end,
  __add = function (a, b)
      a = Pict2e.from(a)
      b = Pict2e.from(b)
      a.pb = a.pb or b.pb
      for _,li in ipairs(b.lines) do
        table.insert(a.lines, li)
      end
      return a
    end,
  --
  __index = {
    --
    -- Functions to convert a Pict2e object to a string.
    -- Inside dednat6 it is better to make suffix = "%".
    --
    suffix = "",
    tolatex = function (p) return p:tostring("%") end,
    tostring = function (p, suffix)
        local f = function (li) return li..(suffix or p.suffix) end
        return mapconcat(f, p.lines, "\n")
      end,
    output = function (p) output(p:tolatex()); return p end,
    --
    -- Append lines.
    add = function (p, p2)
        for _,line in ipairs(Pict2e.from(p2).lines) do
          table.insert(p.lines, line)
        end
        return p
      end,
    --
    beginend = function (p, str1, str2) return str1 + ("  " * p) + str2   end,
    wrapin   = function (p, str1, str2) return str1 + ("  " * (p + str2)) end,
    as     = function (p, str) return p:wrapin("{"..str, "}") end,
    color  = function (p, color) return p:as("\\color{"..color.."}") end,
    grid_  = "\\color{GrayPale}\\linethickness{0.3pt}",
    axes_  = "\\linethickness{0.5pt}",
    asgrid = function (p) return p:as(p.grid_) end,
    asaxes = function (p) return p:as(p.axes_) end,
    def    = function (p, name) return p:wrapin("\\def\\"..name.."{", "}") end,
    --
    bep    = function (p) return p:beginend(p.pb:beginpicture(), "\\end{picture}") end,
    bepc   = function (p) return p:bep():wrapin("\\myvcenter{", "}") end,
    bepcb  = function (p) return p:bepc():wrapin("\\bhbox{$", "$}") end,
    --
    -- Set or change the PictBounds field.
    setbounds = function (p, ab, cd, e)
        p.pb = PictBounds.new(ab, cd, e)
        return p
      end,
    --
    -- Append grids, axes, and ticks to an existing Pict2e object.
    grid0         = function (p) return p.pb:grid() end,
    grid          = function (p) return p:add(p:grid0():asgrid()) end,
    axesandticks0 = function (p) return p.pb:axesandticks() end,
    axesandticks  = function (p) return p:add(p:axesandticks0():asaxes()) end,
    grat          = function (p) return p:grid():axesandticks() end,
    --
    -- Append other things.
    Line  = function (p, ...) return p:add(Pict2e.Line(...)) end,
    Thick = function (p, str) return p:add("\\linethickness{"..str.."}") end,
    put   = function (p, xy, str) return p:add(pformat("\\put%s{%s}", xy, str)) end,
    putcell = function (p, xy, str) return p:put(xy, "\\cell{"..str.."}") end,
    puttext = function (p, xy, str) return p:putcell(xy, "\\text{"..str.."}") end,
    run = function (p, f) f(p); return p end,
  },
}


--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2021pict2e.lua"

= mapconcat(function (n) return "#"..n end, seq(2, 5))

--]]


-- «Pict2e-tests»  (to ".Pict2e-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2021pict2e.lua"
= Pict2e.from               "A"
= Pict2e.from              {"A", "B"}
= Pict2e.from( Pict2e.from {"A", "B"} )

p = Pict2e.from({"aa", "bbb"})
=              p
=              p :tostring("%!")
=       "  " * p
=          p + p
=              p + "cccc"
=              p + {"cccc", "dd"}
=      "00"  + p
= {"1", "2"} + p

= p:beginend("\\begin{foo}", "\\end{foo}")
= p:wrapin  ("\\begin{foo}", "\\end{foo}")
= p:color("red")
= p:asgrid()
= p:asaxes()

p = Pict2e.from({"aa", "bbb", "cccc"})
PPPV(p)
= p:tostring("%")
= p:tostring("")
= p
= p:color("red")
= p

= Pict2e.Line(v(1,2), v(3,4)):Line(v(0,1), v(2,3), v(4,5))

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2021pict2e.lua"

p = Pict2e.bounds(v(0,0), v(3,2))
= p.pb
= p:Line(v(0,1), v(2,3)):color("red")
= p:Line(v(0,1), v(2,3)):color("red").pb

= Pict2e.bounds(v(0,0), v(3,2)):grid():axesandticks()
= Pict2e.bounds(v(0,0), v(3,2)):grid():axesandticks():bep()

--]]


--  ____       _       _       
-- |  _ \ ___ (_)_ __ | |_ ___ 
-- | |_) / _ \| | '_ \| __/ __|
-- |  __/ (_) | | | | | |_\__ \
-- |_|   \___/|_|_| |_|\__|___/
--                             
-- «Points2»  (to ".Points2")
Points2 = Class {
  type = "Points2",
  new  = function () return Points2 {} end,
  __tostring = function (pts) return pts:tostring() end,
  __index = {
    tostring = function (pts, sep)
        return mapconcat(tostring, pts, sep or "")
      end,
    add = function (pts, pt)
        table.insert(pts, pt)
        return pts
      end,
    adds = function (pts, pts2)
        for _,pt in ipairs(pts2) do table.insert(pts, pt) end
        return pts
      end,
    rev = function (pts)
        local pr = Points2.new()
        for i=#pts,1,-1 do
          table.insert(pr, pts[i])
        end
        return pr
      end,
    --
    pict2e = function (pts, prefix)
        return Pict2e.from(prefix .. tostring(pts))
      end,
    Line    = function (pts) return pts:pict2e("\\Line") end,
    polygon = function (pts) return pts:pict2e("\\polygon") end,
    region0 = function (pts) return pts:pict2e("\\polygon*") end,
    region  = function (pts, color) return pts:region0():color(color) end,
    --
    polygon = function (pts, s) return pts:pict2e("\\polygon"..(s or "")) end,
  },
}

-- «Points2-tests»  (to ".Points2-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2021pict2e.lua"
pts = Points2 {v(1,2), v(3,4), v(5,6)}
= pts
= pts:Line()
= pts:rev()
= pts:add(pts:rev()):region("red")
= pts

--]]



--  ____  _      _   ____                        _     
-- |  _ \(_) ___| |_| __ )  ___  _   _ _ __   __| |___ 
-- | |_) | |/ __| __|  _ \ / _ \| | | | '_ \ / _` / __|
-- |  __/| | (__| |_| |_) | (_) | |_| | | | | (_| \__ \
-- |_|   |_|\___|\__|____/ \___/ \__,_|_| |_|\__,_|___/
--                                                     
-- «PictBounds»  (to ".PictBounds")
-- (find-LATEX "edrxpict.lua" "pictp0-pictp3")
-- (find-es "pict2e" "picture-mode")
-- (find-kopkadaly4page (+ 12 288) "\\begin{picture}(x dimen,y dimen)")
-- (find-kopkadaly4text (+ 12 288) "\\begin{picture}(x dimen,y dimen)")
-- (find-kopkadaly4page (+ 12 301) "13.1.6 Shifting a picture environment")
-- (find-kopkadaly4text (+ 12 301) "13.1.6 Shifting a picture environment")
-- (find-kopkadaly4page (+ 12 302) "\\begin{picture}(x dimen,y dimen)(x offset,y offset)")
-- (find-kopkadaly4text (+ 12 302) "\\begin{picture}(x dimen,y dimen)(x offset,y offset)")

PictBounds = Class {
  type = "PictBounds",
  new  = function (ab, cd, e)
      local a,b = ab[1], ab[2]
      local c,d = cd[1], cd[2]
      local x1,x2 = min(a,c), max(a,c)
      local y1,y2 = min(b,d), max(b,d)
      return PictBounds {x1=x1, y1=y1, x2=x2, y2=y2, e=e or .2}
    end,
  __tostring = function (pb) return pb:tostring() end,
  __index = {
    x0 = function (pb) return pb.x1 - pb.e end,
    x3 = function (pb) return pb.x2 + pb.e end,
    y0 = function (pb) return pb.y1 - pb.e end,
    y3 = function (pb) return pb.y2 + pb.e end,
    p0 = function (pb) return v(pb.x1 - pb.e, pb.y1 - pb.e) end,
    p1 = function (pb) return v(pb.x1,        pb.y1       ) end,
    p2 = function (pb) return v(pb.x2,        pb.y2       ) end,
    p3 = function (pb) return v(pb.x2 + pb.e, pb.y2 + pb.e) end,
    tostring = function (pb)
        return pformat("LL=(%s,%s) UR=(%s,%s) e=%s",
          pb.x1, pb.y1, pb.x2, pb.y2, pb.e)
      end,
    --
    beginpicture = function (pb)
        local dimen  =  pb:p3() - pb:p0()
        local center = (pb:p3() + pb:p0()) * 0.5
        local offset =  pb:p0()
        return pformat("\\begin{picture}%s%s", dimen, offset)
      end,
    --
    grid = function (pb)
        local p = Pict2e.from {"% Grid", "% Horizontal lines:"}
        for y=pb.y1,pb.y2 do p:Line(v(pb:x0(), y), v(pb:x3(), y)) end
        p:add("% Vertical lines:")
        for x=pb.x1,pb.x2 do p:Line(v(x, pb:y0()), v(x, pb:y3())) end
        return p
      end,
    ticks = function (pb, e)
        e = e or .2
        local p = Pict2e.from {"% Ticks", "% On the vertical axis:"}
        for y=pb.y1,pb.y2 do p:Line(v(-e, y), v(e, y)) end
        p:add("% On the horizontal axis: ")
        for x=pb.x1,pb.x2 do p:Line(v(x, -e), v(x, e)) end
        return p
      end,
    axes = function (pb)
        return "% Axes"
             + Pict2e.Line(v(pb:x0(), 0), v(pb:x3(), 0))
             + Pict2e.Line(v(0, pb:y0()), v(0, pb:y3()))
      end,
    axesandticks = function (pb)
        return pb:axes() + pb:ticks()
      end,
  },
}

-- «PictBounds-tests»  (to ".PictBounds-tests")
-- (find-LATEX "edrxpict.lua" "pictp0-pictp3")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2021pict2e.lua"

= PictBounds.new(v(-1,-2), v( 3, 5))
= PictBounds.new(v( 3, 5), v(-1,-2))
= PictBounds.new(v( 3, 5), v(-1,-2), 0.5)
pb = PictBounds.new(v(-1,-2), v( 3, 5))
= pb:p0()
= pb:p1()
= pb:p2()
= pb:p3()

= pb:grid()
= pb:ticks()
= pb:axes()

= pb
= pb:beginpicture()

= pb:p0()
= (pb:p0() + pb:p3())
= (pb:p0() + pb:p3()) * 0.5

--]]




--  ____  _      _   ____    __     __        _             
-- |  _ \(_) ___| |_|___ \ __\ \   / /__  ___| |_ ___  _ __ 
-- | |_) | |/ __| __| __) / _ \ \ / / _ \/ __| __/ _ \| '__|
-- |  __/| | (__| |_ / __/  __/\ V /  __/ (__| || (_) | |   
-- |_|   |_|\___|\__|_____\___| \_/ \___|\___|\__\___/|_|   
--                                                          
-- «Pict2eVector»  (to ".Pict2eVector")
-- See: (find-LATEX "edrxpict.lua" "pict2evector")
--      (find-LATEX "edrxgac2.tex" "pict-Vector")
--
Pict2eVector = Class {
  type    = "Pict2eVector",
  __index = {
  },
}

-- «Pict2eVector-tests»  (to ".Pict2eVector-tests")





--  ____  _                        _          
-- |  _ \(_) ___  ___ _____      _(_)___  ___ 
-- | |_) | |/ _ \/ __/ _ \ \ /\ / / / __|/ _ \
-- |  __/| |  __/ (_|  __/\ V  V /| \__ \  __/
-- |_|   |_|\___|\___\___| \_/\_/ |_|___/\___|
--                                            
-- «Piecewise»  (to ".Piecewise")
-- From: (find-LATEX "edrxpict.lua" "Piecewise")
--
Piecewise = Class {
  new = function (str)
      return Piecewise{points={}, pictlines={}, pictdots={}}:add(str)
    end,
  type = "Piecewise",
  __tostring = function (pw) return pw:pointstrs() end,
  __index = {
    npoints = function (pw) return #pw.points end,
    tostring = function (pw) return pw:pointstrs() end,
    pointstrs = function (pws, sep)
        local strs = {}
        for i=1,#pw.points do
          local p = pw.points[i]
          local conn,x,y,oc = p.conn or "  ", p.x, p.y, p.oc or ""
          table.insert(strs, format("%s(%s,%s)%s", conn, x, y, oc))
        end
        return table.concat(strs, sep or " ")
      end,
    --
    -- Add points and segments.
    -- Example: pw:add("(0,1)o--(1,1)o (1,2)c (1,3)o--(2,3)c--(3,2)--(4,2)c")
    add = function (pw, str)
        local pat = "([- ]*)%(([-%d.]+),([-%d.]+)%)([oc]?)"
        for conn,x,y,oc in str:gmatch(pat) do
          conn, x, y = (conn:match"-" and "--"), x+0, y+0
          table.insert(pw.points, {conn=conn, x=x, y=y, oc=oc})
          -- pw:pushpoint(conn, x, y, oc)
        end
        return pw
      end,
    --
    -- Express a piecewise function as a Lua function.
    condstbl = function (pw)
        local conds = {}
        for i=1,#pw.points do
          local P0,P1,P2 = pw.points[i], pw.points[i+1], pw.points[i+2]
          local p0,p1,p2 = P0, P1 or {}, P2 or {}
          local x0,y0,oc0       = p0.x, p0.y, p0.oc
          local x1,y1,oc1,conn1 = p1.x, p1.y, p1.oc, p1.conn
          local x2,y2,oc2,conn2 = p2.x, p2.y, p2.oc, p2.conn
          -- PP(oc0, conn1)
          if oc0 ~= "o" then
            local cond = format("(%s == x)          and %s", x0, y0)
            table.insert(conds, cond)
          end
          if conn1 then
            local cond = format("(%s < x and x < %s)", x0, x1)
            if y1 == y0 then
              cond = format("%s and %s", cond, y0)
            else
              cond = format("%s and (%s + (x - %s)/(%s - %s) * (%s - %s))",
                             cond,   y0,       x0,  x1,  x0,    y1,  y0     )
            end
            table.insert(conds, cond)
          end
        end
        return conds
      end,
    conds = function (pw) return table.concat(pw:condstbl(), "  or\n") end,
    fun0 = function (pw) return "function (x) return (\n"..pw:conds().."\n) end" end,
    fun = function (pw) return expr(pw:fun0()) end,
    --
    -- Get lines and open/closed points, for drawing.
    getj = function (pw, i)
        return (pw.points[i+1] and pw.points[i+1].conn and pw:getj(i+1)) or i
      end,
    getijs = function (pw)
        local i, j, ijs = 1, pw:getj(1), {}
        while true do
          if i < j then table.insert(ijs, {i, j}) end
          i = j + 1
          j = pw:getj(i)
          if pw:npoints() < i then return ijs end
        end
      end,
    getpoint = function (pw, i) return v(pw.points[i].x, pw.points[i].y) end,
    getpoints = function (pw, i, j)
        local ps = Points2.new()
        for k=i,j do ps:add(pw:getpoint(k)) end
        return ps
      end,
    topict = function (pw)
        cmds = Pict2e.new()
        for _,ij in ipairs(pw:getijs()) do
          cmds:add(pw:getpoints(ij[1], ij[2]):Line())
        end
        for i,p in ipairs(pw.points) do
          if p.oc == "o" then
            cmds:add(formatt("\\put%s{\\opendot}", pw:getpoint(i)))
          elseif p.oc == "c" then
            cmds:add(formatt("\\put%s{\\closeddot}", pw:getpoint(i)))
          end
        end
        return cmds
      end,
  },
}

pictpiecewise = function (str)
    return Piecewise.new(str):topict()
  end




-- «Piecewise-tests»  (to ".Piecewise-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2021pict2e.lua"
Pict2e.__index.suffix = "%"

str = "(0,1)o--(1,1)o (1,2)c (1,3)o--(2,3)c--(3,2)--(4,2)c"
pw = Piecewise.new(str)
PPV(pw.points)
= pw
= pw:pointstrs("")
= pw:pointstrs(" ")
= pw:conds()
= pw:fun0()
= pw:fun()
= pw:fun()(1)
= pw:fun()(2)
= pw:fun()(2.5)

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2021pict2e.lua"
Pict2e.__index.suffix = "%"

str = "(0,1)o--(1,1)o (1,2)c (1,3)o--(2,3)c--(3,2)--(4,2)c"
pw = Piecewise.new(str)
PPV(pw:getijs())
= pw:topict()
= pictpiecewise(str)

--]]





--  ____  _                        _     _  __       
-- |  _ \(_) ___  ___ _____      _(_)___(_)/ _|_   _ 
-- | |_) | |/ _ \/ __/ _ \ \ /\ / / / __| | |_| | | |
-- |  __/| |  __/ (_|  __/\ V  V /| \__ \ |  _| |_| |
-- |_|   |_|\___|\___\___| \_/\_/ |_|___/_|_|  \__, |
--                                             |___/ 
--
-- «Piecewisify»  (to ".Piecewisify")
-- From: (find-LATEX "2021-1-C2-critical-points.lua" "Piecewisify")

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
    --
    lineify = function (pwi, a, b)
        return "\\Line"..pwi:piecewise(a, b, nil, "")
      end,
    --
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
        -- return "\\polygon"..(star or "")..pwi:piecewise_pol(a, b)
        return Pict2e.from("\\polygon"..(star or "")..pwi:piecewise_pol(a, b))
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
        local p = Pict2e.new()
        for i=1,ptn:N() do
          local ai,bi = ptn:ai(i), ptn:bi(i)
          local rct = pwi:rct(mname1, mname2, ai, bi)
          p:add(format("\\polygon%s%s\n", star or "*", rct))
        end
        return p
      end,
  },
}



-- «Piecewisify-tests»  (to ".Piecewisify-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2021pict2e.lua"
Pict2e.__index.suffix = "%"

-- (find-LATEX "2021-1-C2-critical-points.lua" "f_parabola_preferida")
f_parabola_preferida = function (x) return 4 - (x-2)^2 end

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



--  ____            _   _ _   _             
-- |  _ \ __ _ _ __| |_(_) |_(_) ___  _ __  
-- | |_) / _` | '__| __| | __| |/ _ \| '_ \ 
-- |  __/ (_| | |  | |_| | |_| | (_) | | | |
-- |_|   \__,_|_|   \__|_|\__|_|\___/|_| |_|
--                                          
-- «Partition»  (to ".Partition")
-- From: (find-LATEX "2021-1-C2-critical-points.lua" "Partition")
--
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
dofile "2021pict2e.lua"

ptn = Partition.new(2, 10)
PPV(ptn)
PPV(ptn:splitn(4))

ptn = Partition.new(2, 10):splitn(4)
for i=1,ptn:N() do
  print(i, ptn:ai(i), ptn:bi(i))
end

--]]








-- Local Variables:
-- coding:  utf-8-unix
-- End:

