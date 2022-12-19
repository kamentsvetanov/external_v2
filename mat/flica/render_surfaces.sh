#!/bin/bash

export SUFFIX=$1

SRCDIR="${0%/*}/" # path to this executable; assume others in same directory.
SRCDIR="$(readlink -f ${0%/*})/" # Better: gives absolute path. Might break if $0 is a link.

test -f $SRCDIR/waitfor || exec echo "Bug: SRCDIR='$SRCDIR' seems wrong (or required file missing)."

echo $SRCDIR | grep '^/' || exec echo "You must run this from an ABSOLUTE path, not relative!"

SURF_NAME=$($SRCDIR/flica_fsaverage_autodetect.sh $SUFFIX)

if ! ls mriOut_mi?_?$SUFFIX.mgh
then
	echo "$0: Note that there are no surfaces to render."
	exit 0
fi

if ! test -L "$SURF_NAME" 
then
	echo $0: 'Failed to link fsaverage*!'; 
	exit 1
fi

SUBJECTS_DIR=$(pwd)

test -L tempdir && rm tempdir
rm -i tempdir 2>/dev/null
ln -s $(mktemp -d /tmp/flicareport.XXXX) tempdir || (echo 'Failed to create tempdir!'; exit 1)
ls -l tempdir

for MI in mi1 mi2 mi3 mi4 mi5 mi6 mi7 mi8 mi9
do
	if test -f mriOut_${MI}_l$SUFFIX.mgh
	then
		export COMPONENTS_FILENAME=mriOut_${MI}
		export SUFFIX
		for HEMI in lh rh
		do
			# Render to TIFF files (both hemispheres in parallel)
			tksurfer $SURF_NAME $HEMI pial -tcl $SRCDIR/surfparc_makeimages.tcl #& Parallel is ok on the mac, but causes rendering problems on jalapeno00
		done
		. $SRCDIR/waitfor_quiet 0
				
		# Convert the TIFF files into a single *_in_all.png (also in tempdir)
		# Note that this can run in the background while we're rending the next modality
		# but must not run in parallel with itself (file name conflicts!)
		$SRCDIR/render_surfaces_assemble.sh $MI 
		# Also: if you care about limiting disk space usage, make sure this finishes before
		# starting the next iteration!
		
	else
		echo No $MI
    fi
done

. $SRCDIR/waitfor 0
echo 'render_surfaces.sh completed'

