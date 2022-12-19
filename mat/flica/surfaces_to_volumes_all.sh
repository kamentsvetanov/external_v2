#!/bin/bash

FSAV=$1
TEMPLATE=$2
SUFFIX=$3

SRCDIR="${0%/*}/" # path to this executable; assume others in same directory.

if test -z "$FSAV"
then
	echo 'Not enough arguments'
	echo 'Usage: surfaces_to_volumes_all.sh fsaverage5 $FSLDIR/data/standard/MNI152_T1_2mm.nii.gz'
	echo 'or: surfaces_to_volumes_all.sh fsaverage $FSLDIR/data/standard/MNI152_T1_2mm.nii.gz _HR'
	exit 2
fi

for MI in $(ls mriOut_mi?_l$SUFFIX.mgh|sed 's/mriOut_mi//' | sed 's/_.*//')
do
	LMGH=mriOut_mi${MI}_l$SUFFIX.mgh
	RMGH=mriOut_mi${MI}_r$SUFFIX.mgh
	NIFTIOUT=niftiOut_mi${MI}$SUFFIX.nii.gz
	$SRCDIR/surfaces_to_volumes.sh $LMGH $RMGH $NIFTIOUT $FSAV $TEMPLATE || exit $?
done
