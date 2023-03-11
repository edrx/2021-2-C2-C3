-- This file:
--   http://angg.twu.net/LATEX/2021-2-C2-def-integral.lua.html
--   http://angg.twu.net/LATEX/2021-2-C2-def-integral.lua
--           (find-angg "LATEX/2021-2-C2-def-integral.lua")
-- Author: Eduardo Ochs <eduardoochs@gmail.com>
--
-- (defun e () (interactive) (find-LATEX "2021-2-C2-def-integral.tex"))
-- (defun l () (interactive) (find-LATEX "2021-2-C2-def-integral.lua"))
-- (defun o () (interactive) (find-LATEX "2021-1-C2-propriedades-da-integral.tex"))
-- (defun p () (interactive) (find-LATEX "2021pict2e.lua"))

-- «.ParCoWith»	(to "ParCoWith")


dofile "2021pict2e.lua"           -- (find-LATEX "2021pict2e.lua")

if not tf then output = print end

-- (c2m211prp 5 "parabola-complicada")
-- (c2m211pra   "parabola-complicada")
--
f_parabola_preferida = function (x)
    return 4 - (x-2)^2
  end
f_parabola_complicada = function (x)
    if x <= 4 then return f_parabola_preferida(x) end
    if x <  5 then return 5 - x end
    if x <  6 then return 7 - x end
    if x <  7 then return 3 end
    if x == 7 then return 4 end
    return 0.5
  end
f_funcao_complicada = f_parabola_complicada

pwi = Piecewisify.new(f_funcao_complicada, seq(0, 4, 0.25), 5, 6, 7)


-- «ParCoWith»  (to ".ParCoWith")
-- Based on: (c2m212isp 8 "programa-2")
--           (c2m212isa   "programa-2")
--
Pict2e.new()
  :setbounds(v(0,0), v(8,5))
    :grid()
    :add("#1")
    :axesandticks()
    :add(pwi:pw(0, 8))  -- f
  :bepc()
  :def("ParCoWith#1")
  :output()


--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2021-2-C2-def-integral.lua"

pwi:setpoints(2, 3, seq(0, 1, 0.25))

f_test = f_parabola_complicada

pwi = Piecewisify.new(f_test, seq(0, 4, 0.25), 5, 6)
pwi = Piecewisify.new(f_test, seq(0, 4, 1   ), 5, 6)
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








-- Local Variables:
-- coding:  utf-8-unix
-- End:
