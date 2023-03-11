-- This file:
-- http://angg.twu.net/LATEX/edrxpict.lua
-- http://angg.twu.net/LATEX/edrxpict.lua.html
--  (find-angg        "LATEX/edrxpict.lua")
--
-- This file contains EXTENSIONS to dednat6. Note that it "require"s
-- edrxtikz.lua, that runs loaddednat6()!
--   See: (find-LATEX "edrxtikz.lua")

-- «.Points»		(to "Points")
-- «.Points-test»	(to "Points-test")
-- «.pictp0-pictp3»	(to "pictp0-pictp3")
-- «.pictbounds»	(to "pictbounds")
-- «.beginpicture»	(to "beginpicture")
-- «.pictaxes»		(to "pictaxes")
-- «.pictgrid»		(to "pictgrid")
-- «.pictpgrid»		(to "pictpgrid")
-- «.pictdots»		(to "pictdots")
-- «.Piecewise»		(to "Piecewise")
-- «.Piecewise-tests»	(to "Piecewise-tests")
-- «.pictFxy»		(to "pictFxy")
-- «.pict2evector»	(to "pict2evector")
-- «.TCG»		(to "TCG")
-- «.TCG-tests»		(to "TCG-tests")
-- «.calcpoints»	(to "calcpoints")
-- «.Pictdotsdef»	(to "Pictdotsdef")
-- «.Wrap»		(to "Wrap")
-- «.Wrap-tests»	(to "Wrap-tests")
-- «.defpictdots»	(to "defpictdots")
-- «.defpictdots-tests»	(to "defpictdots-tests")

-- loaddednat6()  -- (find-angg "LUA/lua50init.lua" "loaddednat6")
require "edrxtikz"  -- (find-LATEX "edrxtikz.lua")




--  ____       _       _       
-- |  _ \ ___ (_)_ __ | |_ ___ 
-- | |_) / _ \| | '_ \| __/ __|
-- |  __/ (_) | | | | | |_\__ \
-- |_|   \___/|_|_| |_|\__|___/
--                             
-- «Points» (to ".Points")
-- A class for sequences of points.
--
Points = Class {
  type  = "Points",
  fromfx = function (a, b, n, f)
      local ps = Points {}
      for i=0,n do
        local x = a + (b-a)*(i/n)
        table.insert(ps, v(x,f(x)))
      end
      return ps
    end,
  fromFt = function (a, b, n, F)
      local ps = Points {}
      for i=0,n do
        local t = a + (b-a)*(i/n)
        table.insert(ps, v(F(t)))
      end
      return ps
    end,
  __tostring = function (li) return li:tostring(" ") end,
  __index = {
    tostring = function (ps, sep) return mapconcat(tostring, ps, sep or "") end,
    add = function (ps, ...)
        for _,p in ipairs({...}) do table.insert(ps, p) end
        return ps
      end,
    copy = function (ps) return Points(shallowcopy(ps)) end,
    polyunder = function (ps)
        local x0, x1 = ps[1][1], ps[#ps][1]
        return ps:copy():add(v(x1,0), v(x0,0))
      end,
    pict = function (ps, pre) return (pre or "")..ps:tostring() end,
    --
    line = function (ps) return ps:pict"\\polyline" end,
    poly = function (ps) return ps:pict"\\polygon" end,
    fill = function (ps) return ps:pict"\\polygon*" end,
  },
}


-- «Points-test» (to ".Points-test")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "edrxpict.lua"
ps = Points.fromfx(2, 3, 5, function (x) return 10*x end)
= ps
= ps:polyunder()
= ps:polyunder():pict"\\polyline"
= ps:polyunder():pict"\\polygon"
= ps:polyunder():pict"\\polygon*"
= Points{v(1,2), v(3,4)}:polyunder():pict"\\polygon*"
= ps:line()
= ps:poly()
= ps:fill()
-- (find-pict2epage 9 "2.4     Extensions")

--]]



--        _      _      _       _       
--  _ __ (_) ___| |_ __| | ___ | |_ ___ 
-- | '_ \| |/ __| __/ _` |/ _ \| __/ __|
-- | |_) | | (__| || (_| | (_) | |_\__ \
-- | .__/|_|\___|\__\__,_|\___/ \__|___/
-- |_|                                  
--
-- «pictdots» (to ".pictdots")
-- Used by: (find-LATEX "edrxgac2.tex" "beginpicture")
--          (find-LATEX "edrxgac2.tex" "beginpicture" "\\pictdots")
--          (find-LATEX "edrxgac2.tex" "beginpicture" "\\picturedots")
-- See: (find-LATEX "2018-1-GA-material.tex" "comprehension-gab")
--      (gam181p 9 "comprehension-gab")
--      (gam181    "comprehension-gab")
pictdots = function (str)
    local bprint, out = makebprint()
    for x,y in str:gmatch("([-.%d]+),([-.%d]+)") do
      local p = v(x+0, y+0)
      bprint("\\put%s{\\circle*{0.5}}", p)
    end
    return out()
  end

--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "edrxpict.lua"
= pictdots "3,1  3,2  3,3"

--]]



--        _      _   _                           _     
--  _ __ (_) ___| |_| |__   ___  _   _ _ __   __| |___ 
-- | '_ \| |/ __| __| '_ \ / _ \| | | | '_ \ / _` / __|
-- | |_) | | (__| |_| |_) | (_) | |_| | | | | (_| \__ \
-- | .__/|_|\___|\__|_.__/ \___/ \__,_|_| |_|\__,_|___/
-- |_|                                                 
--
-- An ugly hack. We store

-- «pictp0-pictp3» (to ".pictp0-pictp3")
-- global variables, sample values
pictp1 = v(-1,-2)           -- lower left,  integer coordinates
pictp2 = v( 3, 5)           -- upper right, integer coordinates
pictp0 = pictp1 - v(.2,.2)  -- lower left
pictp3 = pictp2 + v(.2,.2)  -- upper right

-- «pictbounds» (to ".pictbounds")
pictbounds = function (p1, p2, e)
    e = e or .2
    pictp1 = p1
    pictp2 = p2
    pictp0 = pictp1 - v(e,e)
    pictp3 = pictp2 + v(e,e)
  end

--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "edrxpict.lua"
= pictbounds(v(-1,-2), v(3,5), 0.5)
= pictp1, pictp2
= pictp0, pictp3

--]]




--  _                _             _      _                  
-- | |__   ___  __ _(_)_ __  _ __ (_) ___| |_ _   _ _ __ ___ 
-- | '_ \ / _ \/ _` | | '_ \| '_ \| |/ __| __| | | | '__/ _ \
-- | |_) |  __/ (_| | | | | | |_) | | (__| |_| |_| | | |  __/
-- |_.__/ \___|\__, |_|_| |_| .__/|_|\___|\__|\__,_|_|  \___|
--             |___/        |_|                              
--
-- «beginpicture» (to ".beginpicture")
-- (find-LATEX "edrxgac2.tex" "beginpicture")
-- (find-es "tex" "begin-picture" "(XSIZE,YSIZE)(XORG,YORG)")
-- (find-es "tex" "beginpicture")
beginpicture0 = function ()
    local size   = pictp3 - pictp0
    local origin = pictp0
    return formatt("\\begin{picture}%s%s", size, origin)
  end
beginpicture = function (p1, p2, e)
    pictbounds(p1, p2, e)
    return beginpicture0()
  end

--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "edrxpict.lua"
= beginpicture(v(-1,-2), v(3,5))
= beginpicture(v(-1,-2), v(3,5), 0.5)

--]]




--        _      _                      
--  _ __ (_) ___| |_ __ ___  _____  ___ 
-- | '_ \| |/ __| __/ _` \ \/ / _ \/ __|
-- | |_) | | (__| || (_| |>  <  __/\__ \
-- | .__/|_|\___|\__\__,_/_/\_\___||___/
-- |_|                                  
--
-- «pictaxes» (to ".pictaxes")
-- (find-LATEX "edrxgac2.tex" "beginpicture" "pictaxes")
pictaxes = function (p1, p2)
    p1, p2 = p1 or pictp1, p2 or pictp2
    local xmin, xmax = min(p1[1], p2[1]), max(p1[1], p2[1])
    local ymin, ymax = min(p1[2], p2[2]), max(p1[2], p2[2])
    local bprint, out = makebprint()
    bprint("%% Horizontal axis:")
    bprint("\\Line%s%s", v(xmin-.2,0), v(xmax+.2,0))
    bprint("%% Horizontal axis, ticks:")
    for x=xmin,xmax do
      bprint("\\Line%s%s", v(x,-.2), v(x,.2))
    end
    bprint("%%")
    bprint("%% Vertical axis:")
    bprint("\\Line%s%s", v(0,ymin-.2), v(0,ymax+.2))
    bprint("%% Vertical axis, ticks:")
    for y=ymin,ymax do
      bprint("\\Line%s%s", v(-.2,y), v(.2,y))
    end
    bprint("%%")
    return out()
  end

--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "edrxpict.lua"
= beginpicture(v(-1,-2), v(3,5))
= pictaxes()
= pictaxes(v(-2,-1), v(3,4))

-- \expr{pictsizepos(v(-1.2,-2.2), v(3.2,5.2))}
-- \expr{pictaxes   (v(-1,  -2),   v(3,  5))}

--]]




--        _      _             _     _ 
--  _ __ (_) ___| |_ __ _ _ __(_) __| |
-- | '_ \| |/ __| __/ _` | '__| |/ _` |
-- | |_) | | (__| || (_| | |  | | (_| |
-- | .__/|_|\___|\__\__, |_|  |_|\__,_|
-- |_|              |___/              
--
-- «pictgrid» (to ".pictgrid")
-- (find-LATEX "edrxgac2.tex" "beginpicture" "pictgrid")
-- (find-LATEX "2018-1-GA-material.tex" "varias-coords")
pictgrid = function (p1, p2)
    p1, p2 = p1 or pictp1, p2 or pictp2
    local xmin, xmax = min(p1[1], p2[1]), max(p1[1], p2[1])
    local ymin, ymax = min(p1[2], p2[2]), max(p1[2], p2[2])
    local bprint, out = makebprint()
    bprint("%% Grid")
    bprint("%% Horizontal lines:")
    for y=ymin,ymax do
      bprint("\\Line%s%s", v(xmin-.1,y), v(xmax+.1,y))
    end
    bprint("%% Vertical lines:")
    for x=xmin,xmax do
      bprint("\\Line%s%s", v(x,ymax+.1), v(x,ymin-.1))
    end
    bprint("%%")
    return out()
  end

--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "edrxpict.lua"
= beginpicture(v(-1,-2), v(3,5))
= pictgrid()
= pictgrid(v(-2,-1), v(3,4))

-- \expr{pictsizepos(v(-1.2,-2.2), v(3.2,5.2))}
-- \expr{pictaxes   (v(-1,  -2),   v(3,  5))}

--]]



--        _      _                    _     _ 
--  _ __ (_) ___| |_ _ __   __ _ _ __(_) __| |
-- | '_ \| |/ __| __| '_ \ / _` | '__| |/ _` |
-- | |_) | | (__| |_| |_) | (_| | |  | | (_| |
-- | .__/|_|\___|\__| .__/ \__, |_|  |_|\__,_|
-- |_|              |_|    |___/              
--
-- «pictpgrid» (to ".pictpgrid")
-- This is similar do pictgrid, but it uses the function p and draws
-- slanted grids.
--
-- (find-LATEX "2018-1-GA-material.tex" "pictOuv")
-- (find-LATEX "2018-1-GA-material.tex" "pictOuv" "pictpgrid(0,0,4,4)")
-- (find-LATEX "2018-1-GA-material.tex" "pictOuv" "p = function")
-- (find-LATEX "2018-1-GA-material.tex" "sistemas-de-coordenadas")
-- (find-LATEX "2018-1-GA-material.tex" "sistemas-de-coordenadas" "O,uu,vv =")
--
pictpgrid = function (xmin, ymin, xmax, ymax, e)
    e = e or 0
    local bprint, out = makebprint()
    for y=ymin,ymax do
      bprint("\\Line%s%s", p(xmin-e, y), p(xmax+e, y))
    end
    for x=xmin,xmax do
      bprint("\\Line%s%s", p(x, ymin-e), p(x, ymax+e))
    end
    return out()
  end

--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "edrxpict.lua"
p = function (a, b) return O + a*uu + b*vv end
O, uu, vv = v(1, 1), v(0.1, 0), v(0, 0.1)
= pictpgrid(1, 2, 3, 5)

--]]




--  ____  _                        _          
-- |  _ \(_) ___  ___ _____      _(_)___  ___ 
-- | |_) | |/ _ \/ __/ _ \ \ /\ / / / __|/ _ \
-- |  __/| |  __/ (_|  __/\ V  V /| \__ \  __/
-- |_|   |_|\___|\___\___| \_/\_/ |_|___/\___|
--                                            
-- «Piecewise» (to ".Piecewise")
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
        local ps = Points {}
        for k=i,j do ps:add(pw:getpoint(k)) end
        return ps
      end,
    topict = function (pw)
        cmds = {}
        for _,ij in ipairs(pw:getijs()) do
          table.insert(cmds, pw:getpoints(ij[1], ij[2]):line())
        end
        for i,p in ipairs(pw.points) do
          if p.oc == "o" then
            table.insert(cmds, formatt("\\put%s{\\opendot}", pw:getpoint(i)))
          elseif p.oc == "c" then
            table.insert(cmds, formatt("\\put%s{\\closeddot}", pw:getpoint(i)))
          end
        end
        return table.concat(cmds, "\n")
      end,
  },
}

pictpiecewise = function (str)
    return Piecewise.new(str):topict()
  end


--[[
-- «Piecewise-tests» (to ".Piecewise-tests")
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "edrxpict.lua"
str = "(0,1)o--(1,1)o (1,2)c (1,3)o--(2,3)c--(3,2)--(4,2)c"
pw = Piecewise.new(str)
PPV(pw.points)
= pw
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
dofile "edrxpict.lua"
str = "(0,1)o--(1,1)o (1,2)c (1,3)o--(2,3)c--(3,2)--(4,2)c"
pw = Piecewise.new(str)
PPV(pw:getijs())
= pw:topict()
= pictpiecewise(str)

--]]







-- «pictFxy» (to ".pictFxy")
-- (find-angg "LUA/lua50init.lua" "eval-and-L")
-- (find-angg "LUA/lua50init.lua" "lambda")
pictFxy = function (Fstr)
    local p1, p2 = pictp1, pictp2
    local xmin, xmax = min(p1[1], p2[1]), max(p1[1], p2[1])
    local ymin, ymax = min(p1[2], p2[2]), max(p1[2], p2[2])
    local bprint, out = makebprint()
    local F = lambda ("x,y => "..Fstr)
    for y=ymax,ymin,-1 do
      for x=xmin,xmax do
        print(x, y)
        bprint("\\put%s{\\tcell{%s}}", v(x,y), F(x,y))
      end
    end
    -- bprint("%%")
    return out()
  end

--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "edrxpict.lua"
= beginpicture(v(-1,-2), v(3,4))
= beginpicture(v(-1,-2), v(3,4), .7)
= pictFxy("x")

= pictaxes(v(-2,-1), v(3,4))

-- \expr{pictsizepos(v(-1.2,-2.2), v(3.2,5.2))}
-- \expr{pictaxes   (v(-1,  -2),   v(3,  5))}

--]]




-- «pict2evector» (to ".pict2evector")
-- Moved to: (find-dn6 "picture.lua" "pict2e")
-- Used by: (find-LATEX "edrxgac2.tex" "pict-Vector")

--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "edrxpict.lua"
testvector = function (OO, vv, a,b,step)
    local bprint, out = makebprint()
    for angle=a,b,step do bprint("\\Vector%s%s", OO, OO+vv:rot(angle)) end
    return out()
  end
= testvector(v(2,1), v(2,0), 0,180,11)
= testvector(v(2,1), v(2,0), 0,360,22)

sysco = function (OO, xx, yy, OOtext, xxtext, yytext, vtextdist, Otextdist)
    local bprint, out = makebprint()
    local xxpos = OO + xx/2 + xx:rotright():unit(vtextdist)
    local yypos = OO + yy/2 + yy:rotright():unit(vtextdist)
    local OOpos = OO + (-xx-yy):unit(Otextdist or vtextdist)
    local f = function (str) return (str:gsub("!", "\\")) end
    bprint("\\Vector%s%s", OO, OO+xx)
    bprint("\\Vector%s%s", OO, OO+yy)
    bprint("\\put%s{\\cell{%s}}", OOpos, f(OOtext))
    bprint("\\put%s{\\cell{%s}}", xxpos, f(xxtext))
    bprint("\\put%s{\\cell{%s}}", yypos, f(yytext))
    return out()
  end

= sysco(v(0,0), v(1,0), v(0,1), "O", "x", "y", 0.5)
= sysco(v(0,0), v(1,0), v(0,1), "O_{xy}", "!xx", "!yy", 0.5)
= sysco(v(10,10), v(10,0), v(0,10), "O_{xy}", "!xx", "!yy", 0.5)
= sysco(v(10,10), v(10,0), v(0,10), "O_{xy}", "!xx", "!yy", 0.5, 0.5^0.5)

OO = v(2,1)
vv = v(3,0)
for a=0,360,20 do printt("\\Vector%s%s", OO, OO+vv:rot(a)) end

vv = v(3,4)
= vv:unit()
= vv:unit(10)
= vv
= vv:rot(90)
= vv:rot(-90)


-- (find-LATEXfile "edrxtikz.lua" "V.__index.norm")

--]]



--  _____ ____ ____     
-- |_   _/ ___/ ___|___ 
--   | || |  | |  _/ __|
--   | || |__| |_| \__ \
--   |_| \____\____|___/
--                      
-- «TCG» (to ".TCG")
-- Two-column graphs, old version.
-- The new version is here:
--   (find-dn6 "tcgs.lua" "TCGQ")
--
-- (find-dn6 "picture.lua" "copyopts")
-- (find-dn6 "picture.lua" "LPicture")
-- (find-LATEX "edrxtikz.lua" "Line")
--
TCG = Class {
  type = "TCG",
  new  = function (opts, def, l, r, lrarrows, rlarrows)
      local dims = opts                   -- was opts.dims
      local lp = LPicture.new(opts)
      lp.def = def
      local tcg = {lp=lp,   dh=dims.dh, dv=dims.dv, eh=dims.eh, ev=dims.ev,
                   l=l+0, r=r+0, lrarrows=lrarrows, rlarrows=rlarrows}
      return TCG(tcg)
    end,
  __tostring = function (tcg) return tcg:tostring() end,
  __index = {
    tostring = function (tcg)
        return format("(%s, %s, %q, %q)", tcg.l, tcg.r, tcg.lrarrows, tcg.rlarrows)
      end,
    tolatex = function (tcg) return tcg.lp:tolatex() end,
    L = function (tcg, y) return v(0,      tcg.dv*y) end,
    R = function (tcg, y) return v(tcg.dh, tcg.dv*y) end,
    arrow = function (tcg, A, B, e)
        tcg.lp:addtex(Line.newAB(A, B, e, 1-e):pictv())
        return tcg
      end,
    lrs = function (tcg)
        for y=1,tcg.l do tcg.lp:put(tcg:L(y), y.."\\_") end
        for y=1,tcg.r do tcg.lp:put(tcg:R(y), "\\_"..y) end
        return tcg
      end,
    bus = function (tcg)
        for y=1,tcg.l do tcg.lp:put(tcg:L(y), "\\bullet") end
        for y=1,tcg.r do tcg.lp:put(tcg:R(y), "\\bullet") end
        return tcg
      end,
    strs = function (tcg, strsl, strsr)
        if type(strsl) == "string" then strsl = split(strsl) end
        if type(strsr) == "string" then strsr = split(strsr) end
        for y,str in ipairs(strsl) do tcg.lp:put(tcg:L(y), str) end
        for y,str in ipairs(strsr) do tcg.lp:put(tcg:R(y), str) end
        return tcg
      end,
    cs = function (tcg, charsl, charsr)
        return tcg:strs(split(charsl, "."), split(charsr, "."))
      end,
    cq = function (tcg, charsl, charsr)
        local lc   = function (y) return charsl:sub(y, y) end
        local rc   = function (y) return charsr:sub(y, y) end
        local lstr = function (y) return lc(y)=="L" and y.."\\_" or lc(y) end
        local rstr = function (y) return rc(y)=="R" and "\\_"..y or rc(y) end
        for y=1,#charsl do tcg.lp:put(tcg:L(y), lstr(y)) end
        for y=1,#charsr do tcg.lp:put(tcg:R(y), rstr(y)) end
        return tcg
      end,
    vs = function (tcg)
        for y=1,tcg.l-1 do tcg:arrow(tcg:L(y+1), tcg:L(y), tcg.ev) end
        for y=1,tcg.r-1 do tcg:arrow(tcg:R(y+1), tcg:R(y), tcg.ev) end
        return tcg
      end,
    hs = function (tcg)
        for l,r in tcg.lrarrows:gmatch("(%d)(%d)") do
          tcg:arrow(tcg:L(l), tcg:R(r), tcg.eh)
        end
        for l,r in tcg.rlarrows:gmatch("(%d)(%d)") do
          tcg:arrow(tcg:R(r), tcg:L(l), tcg.eh)
        end
        return tcg
      end,
    print  = function (tcg) print(tcg); return tcg end,
    lprint = function (tcg) print(tcg:tolatex()); return tcg end,
    output = function (tcg) output(tcg:tolatex()); return tcg end,
  },
}

-- «TCG-tests» (to ".TCG-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "edrxpict.lua"
-- dims = {dv=2, dh=3, ev=0.32, eh=0.2}
opts = {scale="10pt", dims={dv=2, dh=3, ev=0.32, eh=0.2}}
opts = {scale="10pt",       dv=2, dh=3, ev=0.32, eh=0.2 }
tcg = TCG.new(opts, "foo", 4, 6, "12", "23 34"):lrs():vs():hs():lprint()
= tcg
= tcg:tolatex()

--]]









-- «calcpoints» (to ".calcpoints")
-- (find-LATEX "2018-1-GA-material.tex" "calcpoints")
-- (find-LATEX "2018-1-GA-material.tex" "distancia-ponto-reta")
-- (find-LATEX "2018-1-GA-material.tex" "distancia-ponto-reta" "\\CalcPoints")
calcpoints = function (str)
    local result = str:gsub("<(.-)>", pformatexpr):gsub("!", "\\")
    print(result)
    return result
  end

-- \def\Calcpoints#1{\expr{calcpoints("#1")}}



-- __        __               
-- \ \      / / __ __ _ _ __  
--  \ \ /\ / / '__/ _` | '_ \ 
--   \ V  V /| | | (_| | |_) |
--    \_/\_/ |_|  \__,_| .__/ 
--                     |_|    
--
-- «Wrap»  (to ".Wrap")
-- (find-es "lua5" "Wrap")
wr = function (lstr, rstr) return Wrap.new(lstr, rstr or "") end
Wrap = Class {
  type    = "Wrap",
  new = function (left, right)
      return Wrap {left=left, right=right}
    end,
  __tostring = function (o) return mytabletostring(o) end,
  __mul = function (w, o)
      if otype(o) == "Wrap"
      then return Wrap.new(w.left..o.left, o.right..w.right)
      else return w.left .. o .. w.right
      end
    end, 
  __index = {
  },
}

-- «Wrap-tests»  (to ".Wrap-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)

dofile "edrxpict.lua"
wa = Wrap.new ("<a ", " a>")
wb = Wrap.new ("<b ", " b>")
wc = Wrap.new ("<c ", " c>")
= wa
= wa * wb
= wa * wb * "o"

--]]




--      _       __       _      _      _       _       
--   __| | ___ / _|_ __ (_) ___| |_ __| | ___ | |_ ___ 
--  / _` |/ _ \ |_| '_ \| |/ __| __/ _` |/ _ \| __/ __|
-- | (_| |  __/  _| |_) | | (__| || (_| | (_) | |_\__ \
--  \__,_|\___|_| | .__/|_|\___|\__\__,_|\___/ \__|___/
--                |_|                                  
--
-- «defpictdots»  (to ".defpictdots")
-- An emergency hack for the Oxford abstract, used in:
-- (find-LATEX "2019oxford-abs.tex" "defpictdots")
-- (find-LATEX "2017planar-has-defs.tex" "defpido")
-- (find-LATEX "2017planar-has-defs.tex" "picturedotsdef")
--
-- My usual definitions for \beginpicture, \pictdots, etc run the
-- "output" function of dednat6 on just part of the tex code, and they
-- make a big mess in the .dnt file...
--
-- See: (find-dn6 "picture.lua" "makepicture")
--
-- (find-LATEX "edrxgac2.tex" "beginpicture")
-- \def\beginpicture (#1,#2)(#3,#4){\expr{beginpicture(v(#1,#2),v(#3,#4))}}
-- \def\beginpictureb(#1,#2)(#3,#4)#5{\expr{beginpicture(v(#1,#2),v(#3,#4),#5)}}
-- \def\pictaxes{{\linethickness{0.5pt}\expr{pictaxes()}}}
-- \def\picturedots(#1,#2)(#3,#4)#5{%
--   \vcenter{\hbox{%
--   \beginpicture(#1,#2)(#3,#4)%
--   \pictaxes%
--   \pictdots{#5}%
--   \end{picture}%
--   }}%
-- }
--
defpictdots = function (drawaxes, name, x0,y0,x1,y1,e, strdots)
    output(defpictdots0(drawaxes, name, x0,y0,x1,y1,e, strdots))
  end
defpictdots0 = function (drawaxes, name, x0,y0,x1,y1,e, strdots)
    local hasname = name and name ~= ""
    local def = hasname
                and wr("\\defpido{"..name.."}{%\n", "}")
                or wr("", "") 
    local vcb = wr("\\vcenter{\\hbox{%\n", "}}")
    local bpb = wr(beginpicture(v(x0,y0), v(x1,y1), e).."%\n", "\\end{picture}")
    local axs = drawaxes
                and wr("{\\linethickness{0.5pt}%\n"..pictaxes().."\n}", "")
                or wr("", "") 
    local dts = pictdots(strdots).."%\n"
    return def * vcb * bpb * axs * dts
  end

-- «defpictdots-tests»  (to ".defpictdots-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "edrxpict.lua"

= defpictdots0(nil,  "",    1,2, 4,5, nil, " 1,0 1,1 0,1 ")
= defpictdots0(nil,  "foo", 1,2, 4,5, nil, " 1,0 1,1 0,1 ")
= defpictdots0("xy", "foo", 1,2, 4,5, nil, " 1,0 1,1 0,1 ")

--]]









-- Local Variables:
-- coding: utf-8-unix
-- End:

