#A simple Makefile to create our package

EXECNAME=PixelPopDefenseZone
VERSION=1.1
PACKNAME=$(EXECNAME)-$(VERSION).love

all: $(PACKNAME)

$(PACKNAME): *.lua */*.lua
	zip -9 -q -r $(PACKNAME) *.lua */*.lua assets
	
run: all
	#open -n -a love ./
	love ./

clean:
	rm -f *.love
	rm -rf release
