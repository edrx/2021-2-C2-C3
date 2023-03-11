-- This file:
--   http://angg.twu.net/LATEX/2022pict2e.lua.html
--   http://angg.twu.net/LATEX/2022pict2e.lua
--           (find-angg "LATEX/2022pict2e.lua")
-- Author: Eduardo Ochs <eduardoochs@gmail.com>
--
-- (defun l  () (interactive) (find-angg "LATEX/2022pict2e.lua"))
-- (defun e  () (interactive) (find-angg "LATEX/2022pict2e.tex"))
-- (defun eb () (interactive) (find-angg "LATEX/2022pict2e-body.tex"))
-- (defun o  () (interactive) (find-angg "LATEX/2021pict2e.lua"))
-- (defun v  () (interactive) (find-pdftools-page "~/LATEX/2022pict2e.pdf"))
-- (defun tb () (interactive) (find-ebuffer (eepitch-target-buffer)))
-- (defun etv () (interactive) (find-wset "13o2_o_o" '(tb) '(v)))

-- «.Show»			(to "Show")
-- «.Show-tests»		(to "Show-tests")
--
-- «.Pict2e»			(to "Pict2e")
-- «.Pict2e-tests»		(to "Pict2e-tests")
-- «.Pict2e-test-nums»		(to "Pict2e-test-nums")
-- «.Pict2eVector»		(to "Pict2eVector")
-- «.Pict2eVector-tests»	(to "Pict2eVector-tests")
-- «.Points2»			(to "Points2")
-- «.Points2-tests»		(to "Points2-tests")
-- «.PictBounds»		(to "PictBounds")
-- «.PictBounds-tests»		(to "PictBounds-tests")
--
-- «.PwSpec»			(to "PwSpec")
-- «.PwSpec-tests»		(to "PwSpec-tests")
-- «.PwFunction»		(to "PwFunction")
-- «.PwFunction-Riemann»	(to "PwFunction-Riemann")
-- «.PwFunction-tests»		(to "PwFunction-tests")
--
-- «.Expr»			(to "Expr")
-- «.Expr-tests»		(to "Expr-tests")
--
-- «.V3»			(to "V3")
-- «.V3-tests»			(to "V3-tests")
-- «.Surface0»			(to "Surface0")
-- «.Surface0-tests»		(to "Surface0-tests")
-- «.Surface»			(to "Surface")
-- «.Surface-tests»		(to "Surface-tests")

loaddednat6()




--  _____         _   
-- |_   _|__  ___| |_ 
--   | |/ _ \/ __| __|
--   | |  __/\__ \ |_ 
--   |_|\___||___/\__|
--                    
-- «Show»  (to ".Show")
-- Show a chunk of tex code by saving it to 2022pict2e-body.tex,
-- latexing 2022pict2e.tex, and displaying the resulting PDF.

Show = Class {
  type = "Show",
  new  = function (o) return Show {bigstr = tostring(o)} end,
  try  = function (bigstr) return Show.new(bigstr):write():compile() end,
  __tostring = function (test)
      return format("Show: %s => %s", test.fname_body, test.success or "?")
    end,
  __index = {
    fname_body  = "~/LATEX/2022pict2e-body.tex",
    fname_tex   = "~/LATEX/2022pict2e.tex",
    --        (find-LATEX "2022pict2e.tex")
    --
    write = function (test)
        ee_writefile(test.fname_body, test.bigstr)
        return test
      end,
    cmd = function (test)
        local cmd = "cd ~/LATEX/ && lualatex "..test.fname_tex.." < /dev/null"
        return cmd
      end,
    compile = function (test)
        local log = getoutput(test:cmd())
        local success = log:match "Success!!!"
        Show.log = log
        test.success = success 
        return test
      end,
    print = function (test) print(test); return test end,
  },
}

-- «Show-tests»  (to ".Show-tests")
--[==[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2022pict2e.lua"
= Show.try "Hello"
 (etv)
= Show.try [[$$ \ln x $$]]
 (etv)

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2022pict2e.lua"
 (etv)
= Show.try()
 (etv)

--]==]




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
  unitlength = function (str) return Pict2e.new():Unitlength(str) end,
  --
  sw = v(-2,-1),
  ne = v(6,4),
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
        ab,cd = ab or Pict2e.sw, cd or Pict2e.ne
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
    Line       = function (p, ...) return p:add(Pict2e.Line(...)) end,
    Thick      = function (p, str) return p:add("\\linethickness{"..str.."}") end,
    Unitlength = function (p, str) return p:add("\\unitlength="..str) end,
    put     = function (p, xy, str) return p:add(pformat("\\put%s{%s}", xy, str)) end,
    putcell = function (p, xy, str) return p:put(xy, "\\cell{"..str.."}") end,
    puttext = function (p, xy, str) return p:putcell(xy, "\\text{"..str.."}") end,
    run = function (p, f) f(p); return p end,
    --
    show = function (p) return Show.try(p:tolatex()) end,
    bshow = function (p, sw, ne)
        -- local sw = sw or Pict2e.sw
        -- local ne = ne or Pict2e.ne
        return Pict2e.bounds(sw, ne):grid():axesandticks():add(p):bep():show()
      end,
    b0show = function (p, sw, ne)
        -- local sw = sw or Pict2e.sw
        -- local ne = ne or Pict2e.ne
        return Pict2e.bounds(sw, ne):add(p):bep():show()
      end,
  },
}



-- «Pict2e-tests»  (to ".Pict2e-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2022pict2e.lua"
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
dofile "2022pict2e.lua"

p = Pict2e.bounds(v(0,0), v(3,2))
= p.pb
= p:Line(v(0,1), v(2,3)):color("red")
= p:Line(v(0,1), v(2,3)):color("red").pb

= Pict2e.bounds(v(0,0), v(3,2)):grid():axesandticks()
= Pict2e.bounds(v(0,0), v(3,2)):grid():axesandticks():bep()
= Pict2e.bounds(v(0,0), v(3,2)):grid():axesandticks():bep():show()
 (etv)
= Pict2e.bounds(v(-2,-1), v(6,4)):grid():axesandticks():bep():show()
 (etv)

--]]

-- «Pict2e-test-nums»  (to ".Pict2e-test-nums")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2022pict2e.lua"
Pict2e.sw = v(-3,-3)
Pict2e.nw = v(3,3)
prep  = Pict2e.unitlength("12pt"):add("\\celllower=3pt")
pnums = Pict2e.bounds():axesandticks():color("gray")
pnums:run(function (p)
    p:puttext(v(0,2), "-6")
    p:puttext(v(0,1), "-4")
    p:puttext(v(1,1), "-2")
  end)
=         pnums
=         pnums:bep()
=  prep + pnums:bep()
= (prep + pnums:bep()):show()
 (etv)

--]]



--  ____  _      _   ____    __     __        _             
-- |  _ \(_) ___| |_|___ \ __\ \   / /__  ___| |_ ___  _ __ 
-- | |_) | |/ __| __| __) / _ \ \ / / _ \/ __| __/ _ \| '__|
-- |  __/| | (__| |_ / __/  __/\ V /  __/ (__| || (_) | |   
-- |_|   |_|\___|\__|_____\___| \_/ \___|\___|\__\___/|_|   
--                                                          
-- «Pict2eVector»  (to ".Pict2eVector")
-- Based on: (find-dn6 "picture.lua" "pict2evector-test")

Pict2eVector = Class {
  type     = "Pict2eVector",
  lowlevel = function (x0, y0, x1, y1)
      local dx, dy = x1-x0, y1-y0
      local absdx, absdy = math.abs(dx), math.abs(dy)
      local veryvertical = absdy > 100*absdx
      local f = function (Dx,Dy,len)
          return Dx,Dy, len
          -- pformat("\\put(%s,%s){\\vector(%s,%s){%s}}", x0,y0, Dx,Dy, len)
        end
      if veryvertical then
        if dy > 0 then return f( 0,1,  dy) else return f( 0,-1, -dy) end 
      else
        if dx > 0 then return f(dx,dy, dx) else return f(dx,dy, -dx) end
      end 
    end,
  --
  eps = 1/4,
  latex = function (x0, y0, x1, y1)
      local norm = math.sqrt((x1-x0)^2 + (y1-y0)^2)
      if norm < Pict2eVector.eps then
        return pformat("\\put%s{}", v(x0,y0)) -- if very short draw nothing
      end
      local Dx,Dy, len = Pict2eVector.lowlevel(x0, y0, x1, y1)
      return pformat("\\put%s{\\vector%s{%s}}", v(x0,y0), v(Dx,Dy), len)
    end,
  fromto = function (x0y0, x1y1)
      local x0,y0, x1,y1 = x0y0[1],x0y0[2], x1y1[1],x1y1[2]
      return Pict2e.from(Pict2eVector.latex(x0,y0, x1,y1))
    end,
  fromwalk = function (x0y0, dxdy)
      PP(x0y0, dxdy)
      return Pict2eVector.fromto(x0y0, x0y0+dxdy)
    end,
  __index = {
  },
}

-- «Pict2eVector-tests»  (to ".Pict2eVector-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
loaddednat6()
dofile "2022pict2e.lua"
x0y0 = v(3,2)
= x0y0
f = function (ang, len)
    return Pict2eVector.fromwalk(x0y0, v(math.cos(ang),math.sin(ang))*len)
  end
= f(0, 2)

p = Pict2e.bounds(v(0,0), v(5,4)):grid():axesandticks()
-- for i=0,2,1/8 do p:add(f(i*math.pi, i)) end
-- for i=0,1,1/8 do p:add(f(i*math.pi, i)) end
for i=0,1/2,1/8 do p:add(f(i*math.pi, i)) end
= p
= p:bep():show()
 (etv)

--]]




--  ____       _       _       
-- |  _ \ ___ (_)_ __ | |_ ___ 
-- | |_) / _ \| | '_ \| __/ __|
-- |  __/ (_) | | | | | |_\__ \
-- |_|   \___/|_|_| |_|\__|___/
--                             
-- «Points2»  (to ".Points2")
--
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
dofile "2022pict2e.lua"
pts = Points2 {v(1,2), v(3,4), v(5,2)}
= pts
= pts:Line()
= pts:rev()
= pts:add(pts:rev()):region("red")

pts = Points2 {v(1,2), v(3,4), v(5,2)}
= pts:region("red"):bshow()
 (etv)
= pts:Line():bshow()
 (etv)

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







--  ____            ____                  
-- |  _ \__      __/ ___| _ __   ___  ___ 
-- | |_) \ \ /\ / /\___ \| '_ \ / _ \/ __|
-- |  __/ \ V  V /  ___) | |_) |  __/ (__ 
-- |_|     \_/\_/  |____/| .__/ \___|\___|
--                       |_|              
--
-- «PwSpec»  (to ".PwSpec")
-- A "spec" for a piecewise function is something like this:
--
--   "(0,1)c--(2,3)o (2,2)c (2,1)o--(4,1)--(5,2)"
--
-- Note that its segments can be non-horizontal.
--
-- An object of this class starts with a spec, immediately calculates
-- its lists of "dxyoc"s, and from that it can generate lots of other
-- data. The list of "dxyoc"s for the spec above is:
--
--   PwSpec.from("(0,1)c--(2,3)o (2,2)c (2,1)o--(4,1)--(5,2)").dxyocs
--     = { {"dash"="" , "x"=0, "y"=1, "oc"="c"},
--         {"dash"="-", "x"=2, "y"=3, "oc"="o"},
--         {"dash"="" , "x"=2, "y"=2, "oc"="c"},
--         {"dash"="" , "x"=2, "y"=1, "oc"="o"},
--         {"dash"="-", "x"=4, "y"=1, "oc"="" },
--         {"dash"="-", "x"=5, "y"=2, "oc"="" } }
--
PwSpec = Class {
  type = "PwSpec",
  from = function (src)
      return PwSpec({src=src, dxyocs={}}):add(src)
    end,
  dxyoc_to_string = function (dxyoc)
      return format("%s(%s,%s)%s",
                    (dxyoc.dash == "-" and "--" or " "),
                    dxyoc.x, dxyoc.y, dxyoc.oc or "")
    end,
  __tostring = function (pws) return pws:tostring() end,
  __index = {
    npoints = function (pw) return #pw.points end,
    --
    -- Add points and segments.
    -- Example: pws:add("(0,1)o--(1,1)o (1,2)c (1,3)o--(2,3)c--(3,2)--(4,2)c")
    add = function (pws, str)
        local patn = "%s*([-+.%d]+)%s*"
        local pat = "(%-?)%("..patn..","..patn.."%)([oc]?)"
        for dash,x,y,oc in str:gfind(pat) do
          table.insert(pws.dxyocs, {dash=dash, x=x+0, y=y+0, oc=oc})
        end
        return pws
      end,
    --
    tostring = function (pws)
        return mapconcat(PwSpec.dxyoc_to_string, pws.dxyocs, "")
      end,
    --
    -- Express a piecewise function as a Lua function.
    conds_tbl = function (pws)
        local conds = {}
        for i=1,#pws.dxyocs do
          local P0,P1,P2 = pws.dxyocs[i], pws.dxyocs[i+1], pws.dxyocs[i+2]
          local p0,p1,p2 = P0, P1 or {}, P2 or {}
          local x0,y0,oc0       = p0.x, p0.y, p0.oc
          local x1,y1,oc1,dash1 = p1.x, p1.y, p1.oc, p1.dash
          local x2,y2,oc2,dash2 = p2.x, p2.y, p2.oc, p2.dash
          if oc0 ~= "o" then
            local cond = format("(%s == x)          and %s", x0, y0)
            table.insert(conds, cond)
          end
          if dash1 == "-" then
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
    conds = function (pws) return table.concat(pws:conds_tbl(), "  or\n") end,
    fun0 = function (pws) return "function (x) return (\n"..pws:conds().."\n) end" end,
    fun = function (pws) return expr(pws:fun0()) end,
    --
    -- Get lines and open/closed points, for drawing.
    getj = function (pws, i)
        return (pws.dxyocs[i+1]
                and (pws.dxyocs[i+1].dash == "-")
                and pws:getj(i+1)) or i
      end,
    getijs = function (pws)
        local i, j, ijs = 1, pws:getj(1), {}
        while true do
          if i < j then table.insert(ijs, {i, j}) end
          i = j + 1
          j = pws:getj(i)
          if #pws.dxyocs < i then return ijs end
        end
      end,
    getpoint = function (pws, i) return v(pws.dxyocs[i].x, pws.dxyocs[i].y) end,
    getpoints = function (pws, i, j)
        local ps = Points2.new()
        for k=i,j do ps:add(pws:getpoint(k)) end
        return ps
      end,
    topict = function (pws)
        cmds = Pict2e.new()
        for _,ij in ipairs(pws:getijs()) do
          cmds:add(pws:getpoints(ij[1], ij[2]):Line())
        end
        for i,p in ipairs(pws.dxyocs) do
          if p.oc == "o" then
            cmds:add(formatt("\\put%s{\\opendot}", pws:getpoint(i)))
          elseif p.oc == "c" then
            cmds:add(formatt("\\put%s{\\closeddot}", pws:getpoint(i)))
          end
        end
        return cmds
      end,
  },
}

-- «PwSpec-tests»  (to ".PwSpec-tests")
--[==[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2022pict2e.lua"
spec = "(0,1)c--(2,3)o (2,2)c (2,1)o--(4,1)--(5,2)"
PPPV(PwSpec.from(spec).dxyocs)

spec = "(0,1)o--(1,1)o (1,4)c (1,3)o--(2,3)c--(3,2)--(4,2)c"
spec = "(0,1)c--(2,3)o (2,2)c (2,1)o--(4,1)c"
pws = PwSpec.from(spec)
= pws
= pws:conds()
= pws:fun0()
= pws:topict()
= pws:topict():bshow()
 (etv)

f = pws:fun()
= f(0.1)
= f(1.9)
= f(2)
= f(2.1)
= f(2.2)

--]==]



--  ____           _____                 _   _             
-- |  _ \__      _|  ___|   _ _ __   ___| |_(_) ___  _ __  
-- | |_) \ \ /\ / / |_ | | | | '_ \ / __| __| |/ _ \| '_ \ 
-- |  __/ \ V  V /|  _|| |_| | | | | (__| |_| | (_) | | | |
-- |_|     \_/\_/ |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|
--                                                         
-- «PwFunction»  (to ".PwFunction")
-- An object of the class PwFunction starts with a function and with
-- its sets of "important points", and it can produce lots of data
-- from that.
--
-- The most typical use of "PwFunction" is like this:
--
--   f = function (x) if x < 2 then return x^2 else return 2 end end
--   pwf = PwFunction.from(f, seq(0, 2, 0.5), 4)
--   pict = pwf:pw(1, 3)
--   pict:bshow()
--
-- We convert the function f (plus its important points) to a
-- PwFunction, and then we generate a PwSpec that draws its graph in a
-- certain interval, and we convert that PwSpec to a Pict2e object and
-- we draw it. Note that the method ":pw(...)" does two conversions:
--
--   PwFunction -> PwSpec -> Pict2e
--
PwFunction = Class {
  type = "PwFunction",
  from = function (f, ...)
      return PwFunction({f=f}):setpoints(...)
    end,
  __index = {
    --
    -- The "important points" are stored in a "Set".
    -- Example: pwf:setpoints(seq(0, 4, 0.25), 5, 6, 7)
    setpoints = function (pwf, ...)
        pwf.points = Set.new()  -- (find-angg "LUA/lua50init.lua" "Set")
        return pwf:addpoints(...)
      end,
    addpoints = function (pwf, ...)
        for _,o in ipairs({...}) do
          if     type(o) == "number" then pwf:addpoint(o)
          elseif type(o) == "table"  then pwf:addlistofpoints(o) 
          else   PP("not a point or a list of points:", o); error()
          end
        end
        return pwf
      end,
    addpoint = function (pwf, p)
        if type(p) ~= "number" then PP("Not a number:", p); error() end
        pwf.points:add(p)
        return pwf
      end,
    addlistofpoints = function (pwf, A)
        for _,p in ipairs(A) do pwf:addpoint(p) end
        return pwf
      end,
    --
    -- All important points in the interval (a,b).
    pointsin = function (pwf, a, b)
        local A = {}
        for _,x in ipairs(pwf.points:ks()) do
          if a < x and x < b then table.insert(A, x) end
        end
        return A
      end,
    --
    -- Detect discontinuities using a heuristic.
    eps = 1/32768,
    delta = 1/128,
    hasjump = function (pwf, x0, x1)
        local y0,y1 = pwf.f(x0), pwf.f(x1)
        return math.abs(y1-y0) > pwf.delta
      end,
    hasjumpl = function (pwf, x) return pwf:hasjump(x - pwf.eps, x) end,
    hasjumpr = function (pwf, x) return pwf:hasjump(x, x + pwf.eps) end,
    --
    xy = function (pwf, x, y) return pformat("(%s,%s)", x, y or pwf.f(x)) end,
    xyl = function (pwf, xc) return pwf:xy(xc - pwf.eps) end,
    xyr = function (pwf, xc) return pwf:xy(xc + pwf.eps) end,
    jumps_and_xys = function (pwf, xc)
        local xyl, xyc, xyr = pwf:xyl(xc), pwf:xy(xc), pwf:xyr(xc)
        local jumpl = pwf:hasjumpl(xc) and "l" or ""
        local jumpr = pwf:hasjumpr(xc) and "r" or ""
        local jumps = jumpl..jumpr      -- "lr", "l", "r", or ""
        return jumps, xyl, xyc, xyr
      end,
    --
    xym = function (pwf, xc)
        local jumps, xyl, xyc, xyr = pwf:jumps_and_xys(xc)
        if     jumps == ""   then str = xyc
        elseif jumps == "l"  then str = format("%so %sc",     xyl, xyc)
        elseif jumps == "r"  then str = format(    "%sc %so",      xyc, xyr)
        elseif jumps == "lr" then str = format("%so %sc %so", xyl, xyc, xyr)
        end
        return str
      end,
    --
    -- pwf:pwspec(a, b) converts a pwf to a "piecewise spec".
    -- This is tricky, so let's see an example. Suppose that:
    --
    --   pwf:pointsin(a, b) = {c}.
    --
    -- Then in the simplest case pwf:piecewise(a, b) would generate a
    -- piecewise spec like this,
    --
    --   "(a,f(a))--(c,f(c))--(b,f(b))"
    --
    -- but we have tricks for dealing with discontinuites and drawing
    -- closed dots and open dots... for example, we can generate
    -- something like this:
    --
    --   "(a,f(a))--(c-eps,f(c-eps))o (c,f(c))c--(b,f(b))"
    --
    -- The hard work to convert c to 
    --
    --             "(c-eps,f(c-eps))o (c,f(c))c"
    --
    -- is done by the function xym, defined above; the case "_o _c"
    -- corresponds to jumps == "l". Note that the "eps"s usually
    -- disappear when each coordinate of the "(x,y)"s is rounded to at
    -- most three decimals.
    --
    -- Btw, I think that the extremities are "(a+eps,f(a+eps))" and
    -- "(b-eps,f(b+eps))", not "(a,f(a))" and "(b,f(b))"... TODO:
    -- check that.
    --
    -- Btw 2: pwf:pwspec(...) can generate other kinds of output if
    -- it is called with the right hackish optional arguments.
    --
    pwspec = function (pwf, a, b, method, sep)
        local method = method or "xym"
        local sep = sep or "--"
        local xym = function (x) return pwf[method](pwf, x) end
        local str
	--
	-- Add points (including discontinuities) and "--"s to str.
        str = pwf:xyr(a)
        for _,x in ipairs(pwf:pointsin(a, b)) do str = str..sep..xym(x) end
        str = str..sep..pwf:xyl(b)
        return str
      end,
    --
    -- :pw(a,b) generates a Pict2e object that
    -- draws f in the interval [a,b].
    pw = function (pwf, a, b)
        return PwSpec.from(pwf:pwspec(a, b)):topict()
      end,
    --
    --
    --
    -- Methods that call pwspec in hackish ways.
    -- TODO: fix names, write tests.
    --
    -- :lineify(...) only works when there are no discontinuities.
    --
    lineify = function (pwi, a, b)
        return "\\Line"..pwi:piecewise(a, b, nil, "")
      end,
    --
    --  ____  _                                                            
    -- |  _ \(_) ___ _ __ ___   __ _ _ __  _ __    ___ _   _ _ __ ___  ___ 
    -- | |_) | |/ _ \ '_ ` _ \ / _` | '_ \| '_ \  / __| | | | '_ ` _ \/ __|
    -- |  _ <| |  __/ | | | | | (_| | | | | | | | \__ \ |_| | | | | | \__ \
    -- |_| \_\_|\___|_| |_| |_|\__,_|_| |_|_| |_| |___/\__,_|_| |_| |_|___/
    --                                                                     
    -- «PwFunction-Riemann»  (to ".PwFunction-Riemann")
    -- The methods below are used to draw several kinds (or "methods")
    -- of Riemann sums as rectangles touching the x axis, and to draw
    -- the differences between two methods as rectangles "floating in
    -- the air".
    -- See: (find-LATEX "2021pict2e.lua" "Piecewisify")
    --      (find-LATEX "2021pict2e.lua" "Piecewisify" "pol1")
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

-- «PwFunction-tests»  (to ".PwFunction-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2022pict2e.lua"
f = function (x) if x < 2 then return x^2 else return 2 end end
pwf  = PwFunction.from(f, seq(0, 2, 0.5), 4)
PPPV(pwf)
spec = pwf:pwspec(0, 4)
PPPV(spec)
spec = pwf:pwspec(1, 3)
PPPV(spec)
pws = PwSpec.from(spec)
PPPV(pws)
pict = pws:topict()
PPPV(pict)
= pict

f = function (x) if x < 2 then return x^2 else return 2 end end
pwf  = PwFunction.from(f, seq(0, 2, 0.5), 4)
= pwf:pwspec(0, 4)
= pwf:pw    (0, 4)
= pwf:pwspec(1, 3)
= pwf:pw    (1, 3)
= pwf:pw    (1, 3):bshow()
 (etv)
= pwf:pw    (0, 4):bshow()
 (etv)

--]]




--  _____                 
-- | ____|_  ___ __  _ __ 
-- |  _| \ \/ / '_ \| '__|
-- | |___ >  <| |_) | |   
-- |_____/_/\_\ .__/|_|   
--            |_|         
--
-- «Expr»  (to ".Expr")

Expr = Class {
  type     = "Expr",
  __tostring = function (expr) return expr:tostring() end,
  __index = {
    expandskel1 = function (expr, str)
        local key = tonumber(str) or str
        return expr[key]
      end,
    expandskel = function (expr, skel)
        local expand1 = function (akey)
            local strkey = akey:sub(2,-2)
            local key = tonumber(strkey) or strkey
            PP(akey, strkey, key)
            return expr[key]
          end
        return (skel:gsub("%b<>", expand1))
      end,
    tostring = function (expr)
        return expr:expandskel(expr.skel)
      end,
  },
}


-- «Expr-tests»  (to ".Expr-tests")
--[==[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2022pict2e.lua"


PP(tonumber("aaa"))
PP(tonumber("123") or "123")

skel = [[∫<1>\,d<v>]]
= skel
PP(skel:match("%b<>"))
PP(skel:match("%b<>"):sub(2,-2))

e = Expr {skel = [[∫<1>\,d<v>]], v="x", [1]="foo"}
= e
= e:expandskel1("1")
= e:expandskel1("v")
PPPV(e)



--]==]




-- (c3m212dnp 9 "point-of-view")
-- (c3m212dna   "point-of-view")
-- (find-LATEX "2021-1-C3-3D.lua")
-- V3.__index.tostring = function (v) return v:v2string() end


-- __     _______ 
-- \ \   / /___ / 
--  \ \ / /  |_ \ 
--   \ V /  ___) |
--    \_/  |____/ 
--                
-- «V3»  (to ".V3")
-- (find-es "dednat" "V3")
--
V3 = Class {
  type       = "V3",
  --
  output     = "3D",
  output2D   = function () V3.output = "2D" end,
  output3D   = function () V3.output = "3D" end,
  p1 = V{2,-1},
  p2 = V{2,1},
  p3 = V{0,2},
  --
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
    tostring = function (v)
        if V3.output == "3D"
        then return v:v3string()
	else return v:v2string()
        end
      end,
    v3string = function (v) return pformat("(%s,%s,%s)", v[1], v[2], v[3]) end,
    v2string = function (v) return tostring(v:tov2()) end,
    --
    -- Convert v3 to v2 using a primitive kind of perspective.
    -- Adjust p1, p2, p3 to change the perspective.
    tov2 = function (v) return v[1]*V3.p1 + v[2]*V3.p2 + v[3]*V3.p3 end,
    --
    Line = function (A, v) return pformat("\\Line%s%s", A, A+v) end,
    -- Lines = function (A, v, w, i, j)
    --     local bprint, out = makebprint()
    --     for k=i,j do bprint((A+k*w):Line(v)) end
    --     return out()
    --   end,
    Lines = function (A, v, w, i, j)
        local out = Pict2e.new()
        for k=i,j do out = out + (A+k*w):Line(v) end
        return out
      end,
    --
    xticks = function (o,n,eps)
        eps = eps or 0.15
        return v3(0,-eps,0):Lines(v3(0,2*eps,0), v3(1,0,0), 0, n)
      end,
    yticks = function (o,n,eps)
        eps = eps or 0.15
        return v3(-eps,0,0):Lines(v3(2*eps,0,0), v3(0,1,0), 0, n)
      end,
    zticks = function (o,n,eps)
        eps = eps or 0.15
        return v3(-eps,0,0):Lines(v3(2*eps,0,0), v3(0,0,1), 0, n)
      end,
    axeswithticks = function (o,x,y,z)
        out = Pict2e.new()
        out = out + v3(0,0,0):Line(v3(x+0.5, 0, 0))
        out = out + v3(0,0,0):Line(v3(0, y+0.5, 0))
        out = out + v3(0,0,0):Line(v3(0, 0, z+0.5))
        out = out + o:xticks(x)
        out = out + o:yticks(y)
        out = out + o:zticks(z)
        return out
      end,
    xygrid = function (o,x,y)
        out = Pict2e.new()
        out = out + v3(0,0,0):Lines(v3(0,y,0), v3(1,0,0), 0, x)
        out = out + v3(0,0,0):Lines(v3(x,0,0), v3(0,1,0), 0, y)
        return out
      end,
    gridandticks = function (o,x,y,z)
        return o:xygrid(x,y):color("gray")
             + o:axeswithticks(x,y,z)
      end,
  },
}

v3 = function (x,y,z) return V3{x,y,z} end

-- Old way:
-- V3.__index.tostring = function (v) return v:v2string() end
-- V3.__index.tostring = function (v) return v:v3string() end

-- «V3-tests»  (to ".V3-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2022pict2e.lua"

o = v3(2,3,4)
= o
= o:v3string()
= o:v2string()

V3.output2D(); print(o)
V3.output3D(); print(o)
V3.output3D(); print(o:xticks(4, 0.2))
V3.output3D(); print(o:axeswithticks(2, 3, 4))
V3.output2D(); print(o:axeswithticks(2, 3, 4))
V3.output2D(); print(o:xygrid(2, 3))
V3.output2D(); print(o:xygrid(2, 3):color("gray"))
V3.output2D(); print(o:axeswithticks(2, 3, 4):bshow())
 (etv)
Pict2e.sw = v(-1,-3); Pict2e.ne = v(7,9)
V3.output2D(); print(o:axeswithticks(2, 3, 4):bshow())
 (etv)
V3.output2D(); print(o:axeswithticks(2, 3, 4):b0show())
 (etv)
V3.output2D(); print((o:xygrid(2, 3):color("gray") +
                      o:axeswithticks(2, 3, 4)
                     ):b0show())
 (etv)
V3.output2D(); print(o:gridandticks(2, 3, 4):b0show())
 (etv)

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2022pict2e.lua"
Pict2e.sw = v(-1,-3); Pict2e.ne = v(7,9)
V3.output2D();

gt = v3(0,0,0):gridandticks(2, 3, 4)
pu = Pict2e.new()
pu = Pict2e.new():Unitlength("2.5pt")
pu = Pict2e.unitlength("2.5pt")
= pu
= gt
= pu + gt
V3.output2D(); print((pu + gt):b0show())
 (etv)

--]]




--  ____              __                
-- / ___| _   _ _ __ / _| __ _  ___ ___ 
-- \___ \| | | | '__| |_ / _` |/ __/ _ \
--  ___) | |_| | |  |  _| (_| | (_|  __/
-- |____/ \__,_|_|  |_|  \__,_|\___\___|
--                                      
-- «Surface0»  (to ".Surface0")
-- (find-dn6 "picture.lua" "V")
-- (find-dn6 "diagforth.lua" "newnode:at:")
--
Surface0 = Class {
  type = "Surface0",
  new  = function (f, x0, y0)
      return Surface0 {f=f, x0=x0, y0=y0, xy0=v(x0, y0),
                      p=Pict2e.bounds()}
    end,
  __index = {
    xyz = function (s, xy, zvalue)
        return v3(xy[1], xy[2], zvalue or s.f(xy[1], xy[2]))
      end,
    xyztow = function (s, xy1, xy2, zvalue, k)
        return s:xyz(tow(xy1, xy2, k), zvalue)
      end,
    segment = function (s, xy1, xy2, zvalue, n)
        local pts = Points2.new()
        for i=0,n do pts:add(s:xyztow(xy1, xy2, zvalue, i/n)) end
        return pts:Line()
      end,
    pillar = function (s, xy)
        return Points2 {s:xyz(xy, 0), s:xyz(xy, nil)} :Line()
      end,
    pillars = function (s, xy1, xy2, n)
        local str = Pict2e.new()
        for i=0,n do str = str + s:pillar(tow(xy1, xy2, i/n)) end
        return str
      end,
    segmentstuff = function (s, xy1, xy2, n, what)
        local str = Pict2e.new()
        if what:match"0" then str = str + s:segment(xy1, xy2, 0,   1) end
        if what:match"c" then str = str + s:segment(xy1, xy2, nil, n) end
        if what:match"p" then str = str + s:pillars(xy1, xy2,      n) end
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
        local xy2 = s.xy0 + dxy1
        return s:segmentstuff(xy1, xy2, n, what)
      end,
    squarestuffp = function (s, n, what, pair)
        local dxy0,dxy1 = unpack(split(pair))
	return s:squarestuff(dxy0, dxy1, n, what)
      end,
    squarestuffps = function (s, n, what, listofpairs)
        local str = Pict2e.new()
        for _,pair in ipairs(listofpairs) do
          str = str + s:squarestuffp(n, what, pair)
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
             + s:verticals  (n, what)
      end,
  },
}

-- «Surface0-tests»  (to ".Surface0-tests")
-- (defun st () (interactive) (find-LATEXfile "2022pict2e.lua" "Surface0-tests"))
--
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2022pict2e.lua"
V3.output2D();
Pict2e.sw = v(-1,-3); Pict2e.ne = v(7,9)
pu = Pict2e.unitlength("10pt")
gt = v3():gridandticks(5, 4, 3)

= pu + gt
V3.output2D(); print((pu + gt):b0show())
= Show.log
 (etv)

fun = function (x, y) return (x-4)^2+(y-3)^2 end
srf = Surface0.new(fun, 4, 3)
fig = srf:segment(v(3,2), v(5,2), 0,   2)
fig = srf:segment(v(3,2), v(5,2), nil, 16)
fig = srf:segmentstuff(v(3,2), v(5,2), 16, "0cp")
print((pu + gt + fig):b0show())
 (etv)

= srf:xyz(v(3, 2))
= srf:xyz(v(3, 2), 0)
= srf:xyz(v(3, 3))
= srf:xyz(v(3, 3), 0)




 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2022pict2e.lua"

F = function (x, y) return 10*x + y end
F = function (x, y) return math.sin(x) * math.sin(y) + 2 end
srf = Surface0.new(F, 3, 4)
= srf:xyz(v(2, 5))
= srf:xyz(v(2, 5), 0)

= srf:xyztow(v(2,5), v(22,25), nil,  0.5)
= srf:xyztow(v(2,5), v(22,25), 0,    0.5)
= srf:segment(v(2,5), v(22,25), 0,   2)
= srf:segment(v(2,5), v(22,25), nil, 2)
= srf:pillar(v(2,5))
= srf:segmentstuff(v(2,5), v(22,25), 2, "0cp")

V3.output2D()
= srf:segmentstuff(v(2,5), v(22,25), 2, "0cp")
= srf:segmentstuff(v(2,5), v(22,25), 2, "0cp"):show()
V3.output3D()
 (etv)

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
sP = Surface0.new(FP, 4, 4)
= sP:segment(v(0,4), v(6,4), nil, 6)

-- Pict2e.sw = v();
-- Pict2e.ne = v();


-- ^ Used by:
-- (c3m211cnp 15 "figura-piramide")
-- (c3m211cna    "figura-piramide")
-- (c3m211cnp 16 "cruz")
-- (c3m211cna    "cruz")

--]]




--  ____              __                
-- / ___| _   _ _ __ / _| __ _  ___ ___ 
-- \___ \| | | | '__| |_ / _` |/ __/ _ \
--  ___) | |_| | |  |  _| (_| | (_|  __/
-- |____/ \__,_|_|  |_|  \__,_|\___\___|
--                                      
-- «Surface»  (to ".Surface")

Surface_fmt = [[
Pict2e:  <unitlength:nv> <sw:nv> <ne:nv>
V3:      <p1:nv> <p2:nv> <p3:nv>
Surface: <maxx:nv> <maxy:nv> <maxz:nv>
         <x0:nv> <y0:nv>
         <f:nv>
         <xya:nv> <xyb:nv> <nsteps:nv>
]]

Surface = Class {
  type = "Surface",
  new  = function (A) return Surface(copy(A)) end,
  __tostring = function (s2) return s2:tostring() end,
  __index = {
    mod = function (df, A)   -- returns a modified copy
        df = copy(df)
        for key,val in pairs(A) do df[key] = val end
        return Surface(df)
      end,
    --
    fmt = function () return Surface_fmt end,
    --
    tostring = function (df, fmt)
        local angtostring = function (name, how)
	    if how == "nv"  then return df:nv(name) end
	    if how == "n2D" then return df:nmethod("v3string", name) end
	    if how == "n3D" then return df:nmethod("v2string", name) end
            return format("[%s by %s]", name, how)
          end
        local pat = "<([!-~]-):([!-~]-)>"
        local out = (fmt or df:fmt()):gsub(pat, angtostring)
        return out
      end,
    nv = function (df, name)
        return format("%s=%s", name, tostring(df[name]))
      end,
    nmethod = function (df, methodname, name)
        local o = df[name]
        local f = (type(o) == "table") and o[methodname]
        return format("%s=%s", name, (f and f(o)) or tostring(o))
      end,
    --
    setbounds = function (s2)
        Pict2e.sw = s2.sw
        Pict2e.ne = s2.ne
      end,
    setperspective = function (s2)
        V3.p1 = s2.p1
        V3.p2 = s2.p2
        V3.p3 = s2.p3
      end,
    pu = function (s2) return Pict2e.unitlength(s2.unitlength) end,
    gt = function (s2) return v3():gridandticks(s2.maxx, s2.maxy, s2.maxz) end,
    xy0 = function (s2) return v(s2.x0, s2.y0) end,
    xyz = function (s2, xy, zspec)
        local x,y = xy[1], xy[2]
        local z = (type(zspec) == "number") and zspec or s2.f(x,y)
        return v3(x,y,z)
      end,
    xyab = function (s2, alpha) return tow(s2.xya, s2.xyb, alpha) end,
    xyzab = function (s2, alpha, zspec) return s2:xyz(s2:xyab(alpha), zspec) end,
    curve = function (s2, zspec)
        local pts = Points2.new()
        for k=0,s2.nsteps do
          local alpha = k/s2.nsteps
          pts:add(s2:xyzab(alpha, zspec))
        end
        return pts:Line()
      end,
    curverelative = function (s2, zspec, Dxya, Dxyb)
        local s2alt = s2:mod {xya=s2:xy0()+Dxya, xyb=s2:xy0()+Dxyb}
        return s2alt:curve(zspec)
      end,
    --
    sixcurves = function (s2, zspec)
        local out = Pict2e.new()
        out = out + s2:curverelative(zspec, v(-1,-1), v(1,-1))
        out = out + s2:curverelative(zspec, v(-1, 0), v(1, 0))
        out = out + s2:curverelative(zspec, v(-1, 1), v(1, 1))
        out = out + s2:curverelative(zspec, v(-1,-1), v(-1,1))
        out = out + s2:curverelative(zspec, v( 0,-1), v( 0,1))
        out = out + s2:curverelative(zspec, v( 1,-1), v( 1,1))
        return out
      end,
    pillar = function (s2, xy) return Points2({s2:xyz(xy,0), s2:xyz(xy,nil)}):Line() end,
    pillars0 = function (s2, xa, xb, xstep, ya, yb, ystep)
        local out = Pict2e.new()
        for y=ya,yb,ystep do
          for x=xa,xb,xstep do
            out = out + s2:pillar(v(x,y))
          end
        end
        return out
      end,
    pillars = function (s2)
        return s2:pillars0(s2.x0-1, s2.x0+1, 1, s2.y0-1, s2.y0+1, 1)
      end,
    --
    base = function (s2)
        s2:setbounds()
        s2:setperspective()
        V3:output2D()
        return s2:pu() + s2:gt()
      end,
    twoDgrid = function (s2)
        s2:setbounds()
        return Pict2e.bounds():grid():axesandticks()
      end,
    fig = function (s2, what)
        what = what or "0pc"
        local out = Pict2e.new()
        if what:match"0" then out = out + s2:sixcurves(0)   end
        if what:match"p" then out = out + s2:pillars(0)     end
        if what:match"c" then out = out + s2:sixcurves(nil) end
        return out
      end,
  },
}

-- «Surface-tests»  (to ".Surface-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2022pict2e.lua"
s2 = Surface {
     unitlength="10pt", sw=v(-1,-3), ne=v(7,9),
     p1=v(2,-0.5), p2=v(0.5,1.5), p3=v(0,0.5),
     maxx=5, maxy=4, maxz=3,
     x0=4, y0=3, nsteps=16,
     -- f = function (x, y) return (x-4)^2 + (y-3)^2 end,
     f = function (x, y) return (x-3) + (y-2) end,
  }
s2b = s2:mod {xya=v(1,2), xyb=v(3,4)}
= s2b
= s2

print((                s2:base() + s2:fig()):b0show())
print((s2:twoDgrid() + s2:base() + s2:fig()):b0show())
 (etv)
= Show.log

--]]





-- Local Variables:
-- coding:  utf-8-unix
-- ee-tla: "p22"
-- End:


