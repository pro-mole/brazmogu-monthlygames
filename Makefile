#A simple Makefile to create our package

EXECNAME=Molesweeper
VERSION=0.1
PACKNAME=$(EXECNAME)-$(VERSION).love

all: $(PACKNAME)

$(PACKNAME): main.lua conf.lua molesweeper assets
	zip -9 -q -r $(PACKNAME) conf.lua main.lua molesweeper assets
	
run:
	love ./

clean:
	rm -f *.love