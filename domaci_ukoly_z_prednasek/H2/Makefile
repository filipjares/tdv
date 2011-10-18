# CC=gcc
# CFLAGS=-g -std=c99 -pedantic -Wall

.PHONY: all gv pics grafy kapitoly

all: paper.ps

gv: paper.ps
	(gv $< &)

paper.pdf: paper.tex init_setup.tex fj.sty pictures 
	pdfcslatex $<; bibtex paper; pdfcslatex $<; pdfcslatex $<

paper.ps: paper.dvi
	dvips $<

paper.dvi: paper.tex init_setup.tex fj.sty pictures
	latex -output-format dvi $<; bibtex paper; latex -output-format dvi $<; latex -output-format dvi $<

pictures: scene_scheme.png
