#A simple Makefile to create our package

EXECNAME=HyperMiner
VERSION=0.8
PACKNAME=$(EXECNAME).love

all: $(PACKNAME)

$(PACKNAME): *.lua assets
	zip -9 -q -r $(PACKNAME) *.lua assets/textures/*.png assets/font
	
run: *.lua assets
	love ./

clean:
	rm -f *.love