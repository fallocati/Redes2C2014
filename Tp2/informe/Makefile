PARAMS="-halt-on-error -file-line-error -output-format pdf"

TIKZ = network_paths.pdf \

all: bibliography informe

informe: $(TIKZ) informe.tex
	pdflatex $(PARAMS) informe.tex

%.bcf: %.tex
	pdflatex $(PARAMS) $<

%.pdf: %.tex
	pdflatex $(PARAMS) $<

bibliography: informe.bcf
	biber informe.bcf

clean:
	rm -f $(TIKZ) informe.pdf
