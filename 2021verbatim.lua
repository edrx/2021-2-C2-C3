-- This file:
--   http://angg.twu.net/LATEX/2021verbatim.lua.html
--   http://angg.twu.net/LATEX/2021verbatim.lua
--           (find-angg "LATEX/2021verbatim.lua")
-- Author: Eduardo Ochs <eduardoochs@gmail.com>
--
-- (defun e () (interactive) (find-LATEX "2021verbatim.tex"))
-- (defun l () (interactive) (find-LATEX "2021verbatim.lua"))
-- (defun o () (interactive) (find-dednat6 "myverbatim.lua"))

-- «.Verbatim»		(to "Verbatim")
-- «.Verbatim-tests»	(to "Verbatim-tests")
-- «.vbt-head»		(to "vbt-head")
-- «.defvbt»		(to "defvbt")



-- «Verbatim»  (to ".Verbatim")
Verbatim = Class {
  type    = "Verbatim",
  from    = function (o) return Verbatim {o = o} end,
  __tostring = function (vb)
      if type(vb.o) == "string" then return vb.o end
      return mytostringv(vb.o)
    end,
  __index = {
    --
    -- g is a shorthand for global.
    -- vb:e(str) expands some (non-utf8) characters in str.
    e_pat  = "[\n #$%%&\\^_{}~]",
    e_dict = VTable {["\n"]="\\\\\n"},
    index  = function (vb, g) return (g and Verbatim.__index) or vb end,
    edict  = function (vb, g) return vb:index(g).e_dict end,
    e_add_b = function (vb, c, g)
        vb:edict(g)[c] = "\\"..c
      end,
    e_add_c = function (vb, c, g)
        vb:edict(g)[c] = "\\char"..string.byte(c).." "
      end,
    e_add_bs = function (vb, cs, g) 
        for c in cs:gmatch(".") do vb:e_add_b(c, g) end
      end,
    e_add_cs = function (vb, cs, g)
        for c in cs:gmatch(".") do vb:e_add_c(c, g) end
      end,
    e = function (vb, str)
        return (string.gsub(str, vb.e_pat, vb.e_dict))
      end,
    --
    -- Some functions that are not methods
    f = {
      e  = function (s) return Verbatim({}):e(s) end,
      v  = function (s) return format("\\vbox{%%\n%s%%\n}", s) end,
      h1 = function (s) return format("\\vbthbox{%s}", s) end,
      bg = function (s) return format("\\vbtbgbox{%s}", s) end,
    },
    --
    prefix = "  ",
    actions = {
      h  = function (vb) vb.o = map(vb.f.h1, vb.o) end,
      c  = function (vb) vb.o = table.concat(vb.o, "%\n"..vb.prefix) end,
      p  = function (vb) vb.o = vb.prefix..vb.o end,
      e  = function (vb) vb.o = map(vb.f.e, vb.o) end,
      v  = function (vb) vb.o = vb.f.v (vb.o) end,
      bg = function (vb) vb.o = vb.f.bg(vb.o) end,
      o  = function (vb) output(vb.o) end,
      P  = function (vb) print(vb) end,
      def = function (vb, name)
	  vb.o = format("\\def\\%s{%s}", name, vb.o)
        end,
      defvbt = function (vb, name)
          vb.o = format("\\defvbt{%s}{%s}", name, vb.o)
        end,
    },
    act = function (vb, str)
        for _,actionarg in ipairs(split(str)) do
	  local action,arg = actionarg:match("^([^:]+):?(.*)$")
	  if not vb.actions[action] then
	    error("Unrecognized action: "..action)
	  end
	  vb.actions[action](vb, arg)
	end
	return vb
      end,
    defvbt = function (vb, name)
        return vb:act("e h c p v bg defvbt:"..name)
      end,
  },
}

Verbatim({}):e_add_cs(" \\%&^_{}~", "global")
Verbatim({}):e_add_bs("#$",         "global")


-- «Verbatim-tests»  (to ".Verbatim-tests")
-- See: (find-LATEX "edrx21.sty" "defvbt")
--[==[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "2021verbatim.lua"
output = print

  Verbatim.__index.e_dict = VTable {["\n"]="\\\\\n"}
= Verbatim.__index.e_dict
Verbatim({}):e_add_cs(" \\%&^_{}~", "global")
Verbatim({}):e_add_bs("#$",         "global")
= Verbatim.__index.e_dict

= Verbatim({}):e "Hello #$\n%&\\^_{}~!!!\n  Hey  hey"

Verbatim.from({"a", "bb", "ccc"}):act("P")
Verbatim.from({"a", "bb", "ccc"}):act("c P")
Verbatim.from({"a", "bb", "ccc"}):act("e h c P")
Verbatim.from({"a", "bb", "ccc"}):act("e h c p P")
Verbatim.from({"a", "bb", "ccc"}):act("e h c v P")
Verbatim.from({"a", "bb", "ccc"}):act("e h c p v P")
Verbatim.from({"a", "bb", "ccc"}):act("e h c p v bg P")
Verbatim.from({"a", "bb", "ccc"}):act("e h c p v bg def:foo P")
Verbatim.from({"a", "bb", "ccc"}):act("e h c p v bg defvbt:foo P")
Verbatim.from({"a", "bb", "ccc"}):defvbt("foo"):act("o")

--]==]


-- «vbt-head»  (to ".vbt-head")
-- (find-LATEX "2021fitch.lua" "fitch-head")
registerhead = registerhead or function () return nop end
registerhead "%V" {
  name   = "vbt",
  action = function ()
      local i,j,origlines = tf:getblock()
      vbt_lines = origlines
    end,
}

-- «defvbt»  (to ".defvbt")
defvbt = function (name)
    Verbatim.from(vbt_lines):defvbt(name):act("o")
  end






-- Local Variables:
-- coding:  utf-8-unix
-- End:
