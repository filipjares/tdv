# CC=gcc
# CFLAGS=-g -std=c99 -pedantic -Wall

.PHONY: all gv pics grafy kapitoly

all: report.pdf

gv: report1.ps
	(gv $< &)

report.pdf: report.tex pictures 
	pdfcslatex $<; bibtex report; pdfcslatex $<; pdfcslatex $<

report.ps: report.dvi
	dvips $<

report.dvi: report.tex pictures
	latex -output-format dvi $<; bibtex report; latex -output-format dvi $<; latex -output-format dvi $<

report1.pdf: report1.tex pictures 
	pdfcslatex $<; bibtex report1; pdfcslatex $<; pdfcslatex $<

report1.ps: report1.dvi
	dvips $<

report1.dvi: report1.tex pictures
	latex -output-format dvi $<; bibtex report1; latex -output-format dvi $<; latex -output-format dvi $<

pictures:
