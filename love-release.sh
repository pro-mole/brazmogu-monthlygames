#Release Script
#USAGE: ./love-release.sh <LOVE executable>

#set -x

if [ $# -lt 1 ]
then
	echo "USAGE: love-release.sh <LOVE executable>"
	exit 0
fi

lovefile=$1
releasedir=$(dirname $1)/release

if [ ! -e $lovefile ]
then
	echo "ERROR: $lovefile no found"
	exit 1
fi

mkdir -p $releasedir
zipname=$(basename ${lovefile%.love})
#echo $zipname

pwd 

function linux {
	mkdir tmp
	cp $1 tmp/
	cd tmp
	zip -9 -m -q ../$releasedir/$zipname-linux.zip *.love
	cd ..
	rmdir tmp
	echo "DONE!"
}

function macosx {
	mkdir tmp
	cp $1 tmp/
	cd tmp
	unzip -q ../release/macosx/love-macosx.zip
	appname=$zipname.app
	mv love.app $appname
	mv $(basename $1) $appname/Contents/Resources/
	zip -9 -r -m -q ../$releasedir/$zipname-macosx.zip $appname
	rm -rf $appname
	cd ..
	rmdir tmp
	echo "DONE!"
}

function win32 {
	mkdir tmp
	cp $1 tmp/
	cd tmp
	unzip -j -q ../release/win32/love-win32.zip
	appname=$zipname-win32.exe
	cat love.exe $(basename $1) > $appname
	rm love.exe *.love
	zip -9 -m -q ../$releasedir/$zipname-win32.zip *
	cd ..
	rmdir tmp
	echo "DONE!"
}

function win64 {
	mkdir tmp
	cp $1 tmp/
	cd tmp
	unzip -j -q ../release/win64/love-win64.zip
	appname=$zipname-win64.exe
	cat love.exe $(basename $1) > $appname
	rm love.exe *.love
	zip -9 -m -q ../$releasedir/$zipname-win64.zip *
	cd ..
	rmdir tmp
	echo "DONE!"
}

for platform in release/*
do
	platname=`cat $platform/PLATFORM`
	echo "Building $platname release..."
	$(basename $platform) $lovefile
done

#set +x