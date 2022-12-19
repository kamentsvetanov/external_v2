#!/bin/bash
# RENDER_SURFACES_ASSEMBLE.SH: helper function for render_surfaces.sh
# Takes one argument: $MI = mi#
# Converts all of the fsaverage*_mriOut_${MI}_${i}_*.tif into a single fsaverage*_mriOut_${MI}_${i}_in_all.png

SRCDIR="${0%/*}/" # path to this executable; assume others in same directory.
MI=$1
echo $MI | grep '^mi[1-9]$' || (echo 'Usage: render_surfaces_assemble.sh mi#'; exit 2)

OUTDIR="$(pwd)"

# Convert to PNG and assemble
cd tempdir
for i in $(find . -iname "*_mriOut_${MI}_*_lh_bot.tif" | sed 's/_lh_bot....//')
do
	echo "Converting $i* into combined views..."
	CROPSIDEVIEW1='-crop 477x336+99+162'
	CROPSIDEVIEW2='-crop 477x336+24+162'

	RESIZE='-resize 9999x150'

	# Create all cropped PNGs in parallel:
	convert ${i}_rh_bot.tif -crop 465x180+105+282 -rotate -90 $RESIZE tmp1.png &
	convert ${i}_lh_bot.tif -crop 465x180+30+282 -rotate 90 $RESIZE tmp2.png &
	convert ${i}_rh_top.tif -crop 471x183+102+135 -rotate 90 $RESIZE tmp3.png &
	convert ${i}_lh_top.tif -crop 471x183+27+135 -rotate -90 $RESIZE tmp4.png &
	convert ${i}_lh_lat.tif $CROPSIDEVIEW2 tmp5.png &
	convert ${i}_rh_lat.tif $CROPSIDEVIEW1 tmp6.png &
	convert ${i}_lh_med.tif $CROPSIDEVIEW1 tmp7.png &
	convert ${i}_rh_med.tif $CROPSIDEVIEW2 tmp8.png &
	. waitfor_quiet 0 # Join parallel tasks
	
	rm ${i}_?h_???.tif & # Not urgent -> background
	
	# Next four steps in parallel:
	convert tmp1.png tmp2.png -background '#000000' +append $RESIZE ${i}_both_bot.png &
	convert tmp3.png tmp4.png -background '#000000' +append $RESIZE ${i}_both_top.png &
	convert tmp5.png tmp6.png -background '#000000' +append $RESIZE ${i}_both_lat.png &
	convert tmp7.png tmp8.png -background '#000000' +append $RESIZE ${i}_both_med.png &
	. waitfor_quiet 0 # Join parallel tasks

	rm tmp?.png # Not parallelized (must complete before next iteration!)

	# And one final step, that can run in parallel with everything else:
	(convert ${i}_both_top.png ${i}_both_bot.png ${i}_both_lat.png ${i}_both_med.png +append "$OUTDIR"/${i}_all.png && rm ${i}_both_???.png )&
done
. waitfor_quiet 0 # Join parallel tasks

