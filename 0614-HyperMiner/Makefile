#A simple Makefile to create our package

EXECNAME=HyperMiner
VERSION=0.1
PACKNAME=$(EXECNAME).love

all: $(PACKNAME)

$(PACKNAME): *.lua assets
	zip -9 -q -r $(PACKNAME) *.lua assets
	
run: *.lua assets
	open -n -a love ./

clean:
	rm -f *.love