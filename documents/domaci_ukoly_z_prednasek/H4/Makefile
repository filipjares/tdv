# CC=gcc
# CFLAGS=-g -std=c99 -pedantic -Wall

.PHONY: all gv pics grafy kapitoly

all: paper.pdf

gv: paper.ps
	(gv $< &)

paper.pdf: paper.tex init_setup.tex fj.sty
	pdfcslatex $<; bibtex paper; pdfcslatex $<; pdfcslatex $<

paper.ps: paper.dvi
	dvips $<

paper.dvi: paper.tex init_setup.tex fj.sty
	latex -output-format dvi $<; bibtex paper; latex -output-format dvi $<; latex -output-format dvi $<
