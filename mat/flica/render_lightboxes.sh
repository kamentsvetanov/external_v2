#!/bin/bash

#set -v


# Parse inputs:
if [[ $# -ge 2 ]] 
then
	COMPFILE=$1
	SUFFIX=$2
	DOSIGN=$3
	if ! test -z $DOSIGN && ! test $DOSIGN == 'm'
	then
		echo "Invalid DOSIGN='$DOSIGN'"
		exit 2
	fi
	echo "$0: COMPFILE='$COMPFILE', SUFFIX='$SUFFIX', DOSIGN='$DOSIGN'"
else
	echo 'Usage: render_lightbox.sh inputfile.nii.gz suffix dosign'
	echo '  Creates a bunch of lightbox_$i$SUFFIX.png files'
	echo '  where i=0, 1, ..., NUMCOMPS, m0, m1, ... mNUMCOMPS.'
	echo '  SUFFIX should be _mi1, etc.. NOT _mi1_HR.'
	echo '  DOSIGN should be "" or "m".'
	exit 2
fi

# Make sure dimensions match (always output 2mm stdspace)
BGFILE=$FSLDIR/data/standard/MNI152_T1_2mm.nii.gz
SLICENUM=$(fslinfo $BGFILE  | grep ^dim3 | sed 's/dim3[[:space:]]*//')
COMPSLICES=$(fslinfo $COMPFILE  | grep ^dim3 | sed 's/dim3[[:space:]]*//')

echo Removing old tempfiles...
rm tmpSplit????.nii.gz 2>/dev/null
rm -v tmp* 2>/dev/null

if [[ $SLICENUM -eq $COMPSLICES ]]
then
	cp $COMPFILE tmpComps1.nii.gz
elif [[ $SLICENUM -eq 91 ]] && [[ $COMPSLICES -eq 182 ]]
then
	echo "Resolution mismatch on '$COMPFILE', downsampling..."
	flirt -in $COMPFILE -ref $COMPFILE -applyisoxfm 2 -interp nearestneighbour -out tmpComps1.nii.gz 
elif [[ $SLICENUM -eq 91 ]] && [[ $COMPSLICES -eq 45 ]]
then
	echo "Resolution mismatch on '$COMPFILE', upsampling..."
	flirt -in $COMPFILE -ref $COMPFILE -applyisoxfm 2 -interp nearestneighbour -out tmpComps1.nii.gz 
else
	echo "Don't know what to do with these dimensions: $BGFILE is $SLICENUM, $COMPFILE is $COMPSLICES"
	exit 3 
fi

# Colour preferences:
BGRANGE="1000 20000"
#ZRANGEMINUS="-3 -10"
ZRANGEMINUS="-2.3 -10" # ALSO change surfparc_makeimages.tcl to adjust surface rendering thresholds
ZRANGE=$(echo $ZRANGEMINUS | sed 's/-//g')

echo "Using Z-stat range: $ZRANGE"

# Drop extra slices:
if [[ $SLICENUM -eq 91 ]]
then
	SLICECROP="10 66"
	SLICESKIP="5"
elif [[ $SLICENUM -eq 182 ]]
then
	SLICECROP="20 132"
	SLICESKIP="10"
elif [[ $SLICENUM -eq 54 ]]
then
	SLICECROP="5 33"
	SLICESKIP="3"
else
	SLICECROP="0 -1"
	SLICESKIP="1"
fi

fslroi $BGFILE tmpBg 0 -1 0 -1 $SLICECROP 
fslroi tmpComps1 tmpComps 0 -1 0 -1 $SLICECROP 0 -1; rm tmpComps1.nii.gz

echo Splitting into components...
fslsplit tmpComps tmpSplit -t

echo -n "Rendering components " 
for ZFILE in tmpSplit*
do
	let i=$(echo $ZFILE | sed 's/[a-zA-Z.]//g' | sed 's/^0*//')+0
	echo -n "$i "

	#fslroi $ZFILE tmpBlah 0 -1 0 -1 $SLICECROP
	cp $ZFILE tmpBlah.nii.gz

	test -z $DOSIGN || fslmaths tmpBlah -mul -1 tmpBlahm
	for SIGN in "" $DOSIGN
	do
		overlay 0 0 tmpBg $BGRANGE tmpBlah$SIGN $ZRANGE tmpBlah$SIGN $ZRANGEMINUS tmpRendered
		slicer tmpRendered -S $SLICESKIP 100000 tmpRendered.ppm
		convert tmpRendered.ppm lightbox_$SIGN$i$SUFFIX.png
		#display lightbox_$SIGN$i$SUFFIX.png
	done

done
echo
echo Removing tempfiles...
rm tmpSplit????.nii.gz
rm tmp*

echo Done.

