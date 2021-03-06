#Release Script
#USAGE: ./love-release.sh <LOVE executable>

#set -x

buildall=true
buildmac=false
buildlinux=false
buildwin32=false
buildwin64=false
ziprelease=true
keepunzipped=false

if [ $# -lt 1 ]
then
	echo "USAGE: love-release.sh [(--mac|--linux|--win32|--win64|--nozip|--keep)...] <LOVE executable>"
	exit 0
fi

while [ $1 ]
	do
	echo $1
	case $1 in
	--usage)
		echo "USAGE: love-release.sh [(--mac|--linux|--win32|--win64|--allwin|--nozip|--keep)...] <LOVE executable>"
		exit 0
		;;
	--mac)
		buildall=false
		buildmac=true
		;;
	--linux)
		buildall=false
		buildlinux=true
		;;
	--win32)
		buildall=false
		buildwin32=true
		;;
	--win64)
		buildall=false
		buildwin64=true
		;;
	--allwin)
		buildall=false
		buildwin32=true
		buildwin64=true
		;;
	--mac)
		buildall=false
		buildmac=true
		;;
	--nozip)
		ziprelease=false
		;;
	--keep)
		keepunzipped=true
		;;
	*)
		lovefile=$1
		;;
	esac
	shift
done

if [ -d $lovefile ]
then
	lovedir=$lovefile
	make -sC $lovedir clean
	make -sC $lovedir
	lovefile=`find $lovedir -maxdepth 1 -name *.love | head -n 1`
	if [ -z $lovefile ]
	then
		echo "Cannot generate .love file in folder $lovedir"
		exit 1
	fi
else
	lovedir=$(dirname $lovefile)
fi

releasedir=$lovedir/release
. $lovedir/config.release
make -sC $lovedir

if [ ! -e $lovefile ]
then
	echo "ERROR: $lovefile not found"
	exit 1
fi

mkdir -p $releasedir
zipname=$(basename ${lovefile%.love})
#echo $zipname

pwd 

function linux {
	if $buildall || $buildlinux
	then
		mkdir tmp
		cp $lovefile tmp/
		cd tmp
		if $ziprelease
		then
			zip -9 -m -q ../$releasedir/$zipname-linux.zip *.love
		else
			mv *.love ../$releasedir/
		fi
		cd ..
		rmdir tmp
		echo "DONE!"
	else
		echo "Nothing done"
	fi
}

function macosx {
	if $buildall || $buildmac
	then
		mkdir tmp
		cp $lovefile tmp/
		find $lovedir/assets/icon -name $icnsName -exec cp {} tmp/ \;
		cd tmp
		unzip -q ../release/macosx/love-macosx.zip
		appname=$zipname.app
		mv love.app $appname
		mv $(basename $lovefile) $appname/Contents/Resources/
		mv *.icns $appname/Contents/Resources
		if [ -e Love.icns ]; then mv Love.icns $appname/Contents/Resources/; fi
		echo $bundleName $bundleIdentifier $icnsName
		sed -i".BACKUP" -e "s/#bundleName/$bundleName/; s/#bundleIdentifier/$bundleIdentifier/; s/#bundleIcon/$icnsName/;" $appname/Contents/Info.plist
		rm $appname/Contents/Info.plist.BACKUP
		chmod -R a+x $appname
		if $ziprelease
		then
			zip -9 -r -m -q ../$releasedir/$zipname-macosx.zip $appname
		else
			rm -rf ../$releasedir/*.app
			mv $appname ../$releasedir/
		fi
		rm -rf $appname
		cd ..
		rmdir tmp
		echo "DONE!"
	else
		echo "Nothing done"
	fi
}

function win32 {
	if $buildall || $buildwin32
	then
		mkdir tmp
		cp $lovefile tmp/
		find $lovedir/assets/icon -name $icoName -exec cp {} tmp/ \;
		cd tmp
		unzip -j -q ../release/win32/love-win32.zip
		appname=$zipname-win32.exe
		cat love.exe $(basename $lovefile) > $appname
		rm love.exe *.love
		chmod a+x *
		if $ziprelease
		then
			zip -9 -m -q ../$releasedir/$zipname-win32.zip *
		else
			mkdir -p ../$releasedir/$zipname-win32
			mv * ../$releasedir/$zipname-win32
		fi
		cd ..
		rmdir tmp
		echo "DONE!"
	else
		echo "Nothing done"
	fi
}

function win64 {
	if $buildall || $buildwin64
		then
		mkdir tmp
		cp $lovefile tmp/
		find $lovedir/assets/icon -name $icoName -exec cp {} tmp/ \;
		cd tmp
		unzip -j -q ../release/win64/love-win64.zip
		appname=$zipname-win64.exe
		cat love.exe $(basename $lovefile) > $appname
		rm love.exe *.love
		chmod a+x *
		if $ziprelease
		then
			zip -9 -m -q ../$releasedir/$zipname-win64.zip *
		else
			mkdir -p ../$releasedir/$zipname-win64
			mv * ../$releasedir/$zipname-win64
		fi
		cd ..
		rmdir tmp
		echo "DONE!"
	else
		echo "Nothing done"
	fi
}

for platform in release/*
do
	platname=`cat $platform/PLATFORM`
	echo "Building $platname release..."
	$(basename $platform) $lovefile
done

#set +x