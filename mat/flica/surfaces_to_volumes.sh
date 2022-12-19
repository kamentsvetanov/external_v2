#!/bin/bash

SRCDIR="${0%/*}/" # path to this executable; assume others in same directory.
SURF_TEMPLATE=$4
test -z "$SURF_TEMPLATE" && SURF_TEMPLATE=fsaverage5
#VOL_TEMPLATE=/vols/Data/oslo/fsaverages/$SURF_TEMPLATE/mri/orig.mgz
VOL_TEMPLATE=$SURF_TEMPLATE/mri/orig.mgz
FINAL_TEMPLATE=$5
test -z "$FINAL_TEMPLATE" && FINAL_TEMPLATE=/usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz
TEMPDIR=$(mktemp -d /tmp/flicaTEMP.XXXX)
echo Converting surface variables lh="'$1'" and rh="'$2'" to out="'$3'", using templates $SURF_TEMPLATE and $VOL_TEMPLATE, with "TEMPDIR='$TEMPDIR', and FINAL_TEMPLATE='$FINAL_TEMPLATE'."

export SUBJECTS_DIR
test -d $SUBJECTS_DIR/$SURF_TEMPLATE || SUBJECTS_DIR=/vols/Data/oslo/fsaverages 
test -d $SUBJECTS_DIR/$SURF_TEMPLATE || SUBJECTS_DIR=/Users/adriang/Downloads/fsaverages
test -d $SUBJECTS_DIR/$SURF_TEMPLATE || echo "$0: Can't find a valid SUBJECTS_DIR='$SUBJECTS_DIR', SURF_TEMPLATE='$SURF_TEMPLATE'."
test -d $SUBJECTS_DIR/$SURF_TEMPLATE || exit 2 

echo 'Converting LH surface to volume...'
mri_surf2vol --surfval "$1" --template $VOL_TEMPLATE --o $TEMPDIR/lhonly.nii.gz --hemi lh --volregidentity $SURF_TEMPLATE --fillribbon  || exit 1
echo 'Converting RH surface to volume...'
mri_surf2vol --surfval "$2" --template $VOL_TEMPLATE --o $TEMPDIR/rhonly.nii.gz --hemi rh --volregidentity $SURF_TEMPLATE --fillribbon || exit 2
. $SRCDIR/waitfor 0

echo 'Combining hemispheres...'
fslmaths $TEMPDIR/lhonly.nii.gz -add $TEMPDIR/rhonly.nii.gz $TEMPDIR/both.nii.gz || exit 4

if test $SURF_TEMPLATE = fsaverage5
then
  echo 'Dilating highres image...'
    fslmaths $TEMPDIR/both.nii.gz -kernel boxv 3 -dilM $TEMPDIR/both2.nii.gz || exit 5
    #fasterDilate.sh $TEMPDIR/both.nii.gz $TEMPDIR/both2.nii.gz
    #echo 'NOT DILATING (do it in lightbox instead) -- too late, must be before registration!'
    #NO NO NO! cp $TEMPDIR/both.nii.gz $TEMPDIR/both2.nii.gz
else
  echo 'NOT dilating highres image (full fsaverage is high enough)'
  mv $TEMPDIR/both.nii.gz $TEMPDIR/both2.nii.gz
fi

echo 'Converting to 2mm MNI...'
flirt -in $TEMPDIR/both2.nii.gz -ref $FINAL_TEMPLATE -out "$3" -applyxfm -init $SRCDIR/FS_to_stdspace.mat -interp nearestneighbour || exit 3

echo "Cleaning up..."
#rm -v $TEMPDIR/*.nii.gz 
rm -v $TEMPDIR/?honly.nii.gz $TEMPDIR/both.nii.gz

echo "Done! Output was '$3'."
exit 0
