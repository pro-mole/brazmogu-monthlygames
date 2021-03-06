#Icon Making Script
#USAGE: ./iconmake.sh <game dir>

gamedir=$1

if [ ! -d $gamedir ]
then
	echo "$gamedir not found or not a directory"
	exit 1
fi

# . $gamedir/config.release
icondir=$gamedir/assets/icon

if [ ! -e $icondir/*.iconset ]
then
	echo "No .iconset directory found in $icondir"
	exit 2
fi

cd $icondir
iconName=$(ls -d *.iconset | head -n 1)
iconName=$(basename ${iconName%.iconset})

#ICNS
iconutil --convert icns $iconName.iconset && echo "ICNS file created successfully" || echo "ERROR: ICNS could not be created"

#ICO
convert $iconName.iconset/icon_32x32.png -flatten -colors 256 -background transparent $iconName.ico && echo "ICO file created successfully" || echo "ERROR: ICO could not be created"