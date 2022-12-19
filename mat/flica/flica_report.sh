#!/bin/bash
# Note -- the file that was previously here is now flica_html_report.sh


SRCDIR="${0%/*}/" # path to this executable; assume others in same directory.

eval WORKINGDIR=$1  # Expands ~ properly

if ! test -z $WORKINGDIR && cd $WORKINGDIR
then
	echo $0: "Working in directory '$WORKINGDIR'"
else
	echo $0: "Invalid path: '$WORKINGDIR'"
	echo $WORKINGDIR
	ls -ld $WORKINGDIR
	exit 2
fi

FSAV=$($SRCDIR/flica_fsaverage_autodetect.sh $2)
if test -z "$FSAV" && ls -l *.mgh 2>/dev/null
then
	echo  $0: 'No fsaverage link found'
	exit 2
fi

if test -z $2
then
	echo 'Producing report from low-res outputs:'
	$SRCDIR/render_surfaces.sh && \
	$SRCDIR/surfaces_to_volumes_all.sh $FSAV $FSLDIR/data/standard/MNI152_T1_2mm.nii.gz && \
	$SRCDIR/render_lightboxes_all.sh && \
	$SRCDIR/flica_html_report.sh && \
	echo 'Done producing low-res report.'
elif test $2 == _HR
then
	echo 'Producing report from high-res outputs:'
	$SRCDIR/render_surfaces.sh _HR && \
	$SRCDIR/surfaces_to_volumes_all.sh $FSAV $FSLDIR/data/standard/MNI152_T1_2mm.nii.gz _HR && \
	$SRCDIR/render_lightboxes_all.sh _HR && \
	$SRCDIR/flica_html_report.sh && \
	echo 'Done producing high-res report.'
else
	echo $0: "Unrecognized input: '$2'"
	exit 2
fi
	
	
