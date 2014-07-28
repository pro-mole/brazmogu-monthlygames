#!/bin/bash

# Branch cloning/pulling script
# Add new branches to the BRANCHES array and the corresponding folder name to the list of vars AND the .gitignore file

REMOTE=https://github.com/pro-mole/brazmogu-monthlygames.git
BRANCHES="0414 0514 0614 0714 0814"
BRANCH_0414=0414-PixelPopDefenseZone
BRANCH_0514=0514-Molesweeper
BRANCH_0614=0614-HyperMiner
BRANCH_0714=0714-ColonizationChess
BRANCH_0814=0814-Merchants

for b in $BRANCHES
do
	eval branch_dir=\$BRANCH_$b
	echo "Cloning branch $b into '$branch_dir'..."
	
	mkdir $branch_dir 2> /dev/null
	if [ $? -eq 0 ]
	then
		git clone $REMOTE -b $b $branch_dir
	else
		if [ -d $branch_dir ]
		then
			echo "$branch_dir already exists..."
			rmdir $branch_dir 2> /dev/null
			if [ $? -eq 0 ]
			then
				git clone $REMOTE -b $b $branch_dir
			else
				echo "$branch_dir is not empty. Skipping"
			fi
		else
			echo "Could not create $branch_dir!"
		fi
	fi
done