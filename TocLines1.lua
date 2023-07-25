-- This file:
--   http://anggtwu.net/LUA/TocLines1.lua.html
--   http://anggtwu.net/LUA/TocLines1.lua
--          (find-angg "LUA/TocLines1.lua")
-- Author: Eduardo Ochs <eduardoochs@gmail.com>
--
-- (defun e () (interactive) (find-angg "LUA/TocLines1.lua"))
-- This is a replacement for: (find-angg "LUA/Comissao1.lua")
-- (find-LATEX "2022-2-C2-C3-ajuda.tex" "Docs-class")

-- Used by:
-- (find-LATEX "2022-2-C2-C3-ajuda.tex" "defs-toclines")

-- (find-Deps1-links "TocLines1")
-- (find-Deps1-cps   "TocLines1")
-- (find-Deps1-anggs "TocLines1")

-- «.TocLines»		(to "TocLines")
-- «.TocLines-tests»	(to "TocLines-tests")
-- «.texdefs»		(to "texdefs")



--  _____          _     _                 
-- |_   _|__   ___| |   (_)_ __   ___  ___ 
--   | |/ _ \ / __| |   | | '_ \ / _ \/ __|
--   | | (_) | (__| |___| | | | |  __/\__ \
--   |_|\___/ \___|_____|_|_| |_|\___||___/
--                                         
-- «TocLines»  (to ".TocLines")

TocLines = Class {
  type = "TocLines",
  new = function (fname)
      return TocLines {n=0, entries=VTable{}, fname=fname}
    end,
  readmytoc = function (fname)
      return TocLines.new(fname):readmytoc():hashnames()
    end,
  __tostring = function (tl) return "n="..tl.n.."\n"..tostring(tl.entries) end,
  __index = {
    incrn = function (tl) tl.n = tl.n + 1; return tl.n end,
    addentry = function (tl, o) table.insert(tl. entries, o); return tl end,
    addnamepageentry = function (tl, name, page)
        return tl:addentry({n=tl:incrn(), name=name, page=page})
      end,
    --
    sethead = function (tl)
        local e = tl.entries[#tl.entries]
        return format("\\fancyhead[C]{%s %s}", e.n, e.name)
      end,
    --
    tabletotex = function (tl, T)
        return format("\\mytocline{%s}{%s}{%s}", T.n, T.name, T.page)
      end,
    totex = function (tl)
        local f = function (o)
            return type(o) == "string" and o or tl:tabletotex(o)
          end
        return mapconcat(f, tl.entries, "\n")
      end,
    --
    readmytoclines = function (tl, fname)
        local bigstr = ee_readfile(fname)
        local pat = "\n\\mytocline{(.-)}{(.-)}{(.-)}"
        for n,name,page in bigstr:gmatch(pat) do
          local entry = {n=n, name=name, page=page}
          tl:addentry(entry)
        end
        return tl
      end,
    --
    hashnames = function (tl)
        for _,o in ipairs(tl.entries) do
          if type(o) == "table" then tl.entries[o.name] = o end
        end
        return tl
      end,
    nametopage = function (tl, name) return tl.entries[name].page end,
    --
    addyear = function (tl, yyyy) return tl:addentry("\n"..yyyy..":") end,
    adddoc  = function (tl, name, page) return tl:addnamepageentry(name, page) end,
    incl    = function (tl, name, page) return tl:addnamepageentry(name, page) end,
    --
    fnamestem  = function (tl)
        return (tl.fname:gsub("%.tex$", ""):gsub("%.mytoc$", ""))
      end,
    tocfname   = function (tl) return tl:fnamestem()..".mytoc" end,
    readmytoc  = function (tl) return tl:readmytoclines(tl:tocfname()) end,
    writemytoc = function (tl)
        ee_writefile(tl:tocfname(), "\n"..tl:totex().."\n")
        print("Writing: "..tl:tocfname())
        return tl
      end,
    writetoc   = function (tl) return tl:writemytoc() end,
    --
    sortednames = function (tl)
        local names = VTable {}
        for i,entry in ipairs(tl.entries) do table.insert(names, entry.name) end
        table.sort(names)
        return names
      end,
    revnamesandpages = function (tl)
        local names = tl:sortednames()
        local f = function (i)
            return format("  %-30s -> %s", names[i], tl.entries[names[i]].page)
          end
        return mapconcat(f, seq(#names,1,-1), "\n")
      end,
  },
}

-- «TocLines-tests»  (to ".TocLines-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "TocLines1.lua"

tl = TocLines.new()
tl = TocLines.new("/tmp/foo.tex")
= tl
= tl:addentry "foo"
= tl:addentry "bar"
= tl:addnamepageentry("blep", 20)
= tl:addnamepageentry("flop", 42)
= tl:sethead()
= tl:addentry "plic"
= tl:addentry "\nYear of the ploc"
= tl:totex()
= tl:hashnames()
= tl:nametopage("flop")
= tl.fname
= tl:tocfname()
 (find-sh0 "rm -fv /tmp/foo.mytoc")
= tl:writetoc()
 (find-sh0 "cat    /tmp/foo.mytoc")

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "TocLines1.lua"
fname = "~/LATEX/2022-2-C2-C3-ajuda.tex"
tl = TocLines.new()
tl = TocLines.readmytoc(fname)
= tl:readmytoclines(tl.fname)
= tl:totex()
= tl:hashnames()
  tl:writetoc()
= tl

-- (find-sh0 "rm -fv ~/LATEX/2022-2-C2-C3-ajuda.mytoc")
-- (find-fline      "~/LATEX/2022-2-C2-C3-ajuda.mytoc")
-- (find-LATEXsh "ls *mytoc")
-- (find-LATEXsh "ls *tudo*mytoc")

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "TocLines1.lua"
fname = "~/LATEX/2022-2-C2-tudo.mytoc"
tl = TocLines.readmytoc(fname)
= tl

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "TocLines1.lua"
fname = "~/LATEX/2022-2-C2-C3-ajuda.tex"
tl = TocLines.readmytoc(fname)
= tl:sortednames()
= tl:revnamesandpages()

--]]


-- «texdefs»  (to ".texdefs")
TocLines.texdefs = [[
  \def\addyear#1{\directlua{toclines:addyear(#1)}}
  \def\adddoc #1{\directlua{
    toclines:adddoc("#1", \thepage)
    output(toclines:sethead())
  }}
  \def\luaincl  #1{\directlua{toclines:incl("#1", \thepage)}}
  \def\basicincl#1{\includepdf[pages=-]{#1.pdf}}
  \def\incl     #1{\luaincl{#1}\basicincl{#1}}
  \def\writetoc{\directlua{
    print()
    toclines:writetoc()
  }}
]]




--[[

%L require "TocLines1"
%L toclines = TocLines.new(status.filename)

\def\addyear#1{\directlua{toclines:addyear(#1)}}
\def\adddoc #1{\directlua{
  toclines:adddoc("#1", \thepage)
  output(toclines:sethead())
}}
\def\writetoclines{\directlua{
  print()
  print(toclines:awritetoc(#1))
}

--]]





Comissao = Class {
  type = "Comissao",
  readtex = function ()
      local bigstr = ee_readfile "~/LATEX/2022-2-C2-C3-ajuda.tex"
      local pat = "\n\\mytocline{(.-) (.-)}{(.-)}"
      local entries = VTable {}
      local secpage = VTable {}
      for n,sec,page in bigstr:gmatch(pat) do
        local entry = {n=n, page=page, sec=sec}
        table.insert(entries, entry)
        entries[sec] = entry
      end
      return entries
    end,
  initialize = function ()
      Comissao.entries = Comissao.readtex()
    end,
  pat = nil,    -- defined after the class
  parse = function (str)
      local o = Comissao.pat:match(str)
      if not o then return end
      local entry = Comissao.entries[o.secname]
      if not entry then return end
      o.initpage = entry.page
      o.realpage = o.subpage and (o.initpage + o.subpage - 1) or o.initpage
      o.sexp  = format("(ajup %d)", o.realpage)
      o.sexpt = format("(ajut %d)", o.realpage)
      return o
    end,
  pagesexp = function (head, str)
      local o = Comissao.parse(str)
      local p = o and o.realpage
      return o and format("(%s %s)", head, p)
    end,
  texsection = function (str)
      local o = str and Comissao.parse(str)
      local s = (o and o.secname) or "toc"
      return format('(ajua "%s")', s)
    end,
  sexp  = function (str) return Comissao.pagesexp("-sexp", str) end,
  sexpt = function (str) return Comissao.pagesexp("-sexpt", str) end,
  sexpt = function (str)
      local o = Comissao.parse(str)
      return o and o.sexpt
    end,
  __index = {
  },
}




-- Local Variables:
-- coding:  utf-8-unix
-- End:
