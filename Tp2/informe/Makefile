PARAMS="-halt-on-error -file-line-error -output-format pdf"

TIKZ = network_paths.pdf \

all: informe

informe: $(TIKZ) informe.tex
	pdflatex $(PARAMS) informe.tex

%.pdf: %.tex
	pdflatex $(PARAMS) $<

clean:
	rm -f $(TIKZ) informe.pdf
