# This file:
#   http://anggtwu.net/2021-2-C2-C3/Makefile.html
#   http://anggtwu.net/2021-2-C2-C3/Makefile
#          (find-angg "2021-2-C2-C3/Makefile")
# Author: Eduardo Ochs <eduardoochs@gmail.com>

#
# Created by hand from:
#   (find-angg "2021-2-C2-C3/README.org")
#   (find-fline "/tmp/.filest0.tex")
#   (setq last-kbd-macro (kbd "C-a C-q TAB lualatex SPC C-a <down>"))

all: compile_all_texs

compile_basic_texs:
	lualatex 2021-2-C2-MT1.tex
	lualatex 2021-2-C2-MT2.tex
	lualatex 2021-2-C2-MT3.tex
	lualatex 2021-2-C2-P1.tex
	lualatex 2021-2-C2-P2.tex
	lualatex 2021-2-C2-TFC1.tex
	lualatex 2021-2-C2-def-integral.tex
	lualatex 2021-2-C2-edovs.tex
	lualatex 2021-2-C2-fracoes-parciais.tex
	lualatex 2021-2-C2-infs-e-sups.tex
	lualatex 2021-2-C2-int-subst.tex
	lualatex 2021-2-C2-intro.tex
	lualatex 2021-2-C2-mud-var-gamb.tex
	lualatex 2021-2-C2-revisao-pra-P2.tex
	lualatex 2021-2-C2-somas-1.tex
	lualatex 2021-2-C2-somas-2-4.tex
	lualatex 2021-2-C2-somas-2.tex
	lualatex 2021-2-C3-MT1.tex
	lualatex 2021-2-C3-MT2.tex
	lualatex 2021-2-C3-P1.tex
	lualatex 2021-2-C3-P2.tex
	lualatex 2021-2-C3-bezier.tex
	lualatex 2021-2-C3-diag-nums.tex
	lualatex 2021-2-C3-funcoes-homogeneas.tex
	lualatex 2021-2-C3-intro.tex
	lualatex 2021-2-C3-notacao-de-fisicos.tex
	lualatex 2021-2-C3-taylor-R2.tex
	lualatex 2021-2-C3-taylor.tex
	lualatex 2021-2-C3-tipos.tex
	lualatex 2021-2-C3-vetor-tangente.tex

compile_all_texs:
	lualatex 2021-2-C2-MT1.tex
	lualatex 2021-2-C2-MT2.tex
	lualatex 2021-2-C2-MT3.tex
	lualatex 2021-2-C2-P1.tex
	lualatex 2021-2-C2-P2.tex
	lualatex 2021-2-C2-TFC1.tex
	lualatex 2021-2-C2-def-integral.tex
	lualatex 2021-2-C2-edovs.tex
	lualatex 2021-2-C2-fracoes-parciais.tex
	lualatex 2021-2-C2-infs-e-sups.tex
	lualatex 2021-2-C2-int-subst.tex
	lualatex 2021-2-C2-intro.tex
	lualatex 2021-2-C2-mud-var-gamb.tex
	lualatex 2021-2-C2-revisao-pra-P2.tex
	lualatex 2021-2-C2-somas-1.tex
	lualatex 2021-2-C2-somas-2-4.tex
	lualatex 2021-2-C2-somas-2.tex
	lualatex 2021-2-C3-MT1.tex
	lualatex 2021-2-C3-MT2.tex
	lualatex 2021-2-C3-P1.tex
	lualatex 2021-2-C3-P2.tex
	lualatex 2021-2-C3-bezier.tex
	lualatex 2021-2-C3-diag-nums.tex
	lualatex 2021-2-C3-funcoes-homogeneas.tex
	lualatex 2021-2-C3-intro.tex
	lualatex 2021-2-C3-notacao-de-fisicos.tex
	lualatex 2021-2-C3-taylor-R2.tex
	lualatex 2021-2-C3-taylor.tex
	lualatex 2021-2-C3-tipos.tex
	lualatex 2021-2-C3-vetor-tangente.tex
	lualatex 2021-2-C2-tudo.tex
	lualatex 2021-2-C3-tudo.tex

# Local Variables:
# coding:  utf-8-unix
# End:
