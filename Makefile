#A simple Makefile to create our package

EXECNAME=Mantle
VERSION=0.1
PACKNAME=$(EXECNAME)-$(VERSION).love

all: $(PACKNAME)

$(PACKNAME): *.lua assets platform
	zip -9 -q -r $(PACKNAME) *.lua assets platform
	
run: *.lua assets
	love .

clean:
	rm -f *.love
