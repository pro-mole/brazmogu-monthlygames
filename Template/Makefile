#A simple Makefile to create our package

EXECNAME=EXECNAME
VERSION=0.1
PACKNAME=$(EXECNAME)-$(VERSION).love

all: $(PACKNAME)

$(PACKNAME): *.lua assets
	zip -9 -q -r $(PACKNAME) *.lua assets
	
run: *.lua assets
	love ./

clean:
	rm -f *.love