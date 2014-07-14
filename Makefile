#A simple Makefile to create our package

EXECNAME=ColonizationChess
VERSION=0.1
PACKNAME=$(EXECNAME).love

all: $(PACKNAME)

$(PACKNAME): *.lua assets screen maps
	zip -9 -q -r $(PACKNAME) *.lua assets screen maps
	
run: *.lua assets
	love ./

clean:
	rm -f *.love