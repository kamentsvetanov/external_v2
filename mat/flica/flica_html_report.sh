#!/bin/bash
# Note: This was previously known as flica_report.sh (see CVS history for that one)

INDEXFILE=index.html
rm -v $INDEXFILE 2>/dev/null

echo "<html><body><h1>$(pwd)</h1><br><br>" >>$INDEXFILE


i=0
NUMi=0
LINKS="Components:"
while test -e lightbox_${i}_mi1.png
do
	let NUMi=NUMi+1
	LINKS="$LINKS <a href=comp_$i.html>$i</a>"
	let i=i+1
done

MIFILELIST=""
echo "Making all-in-one page per modality..."
for FILE in $(ls lightbox_0_*)
do
	MI=$(echo $FILE | sed 's/lightbox_0_//' | sed 's/.png//')
	echo "<html><body><h1>Modality $(grep $MI shortNames.txt | sed "s/^$MI:[[:space:]]*//") ($MI) lightboxes</h1>" >$MI.html
	#ls lightbox_?_$MI.png lightbox_??_$MI.png lightbox_???_$MI.png | sed 's/^/<img src=/' | sed 's/$/><br>/' >>$MI.html
	ls lightbox_[0-9]_$MI.png lightbox_[0-9][0-9]_$MI.png lightbox_[0-9][0-9][0-9]_$MI.png 2>/dev/null| sed 's/.*/<img src=\0><br>/g' >>$MI.html
	echo "</body></html>" >>$MI.html
	MIFILELIST="$MIFILELIST <a href=$MI.html>$(grep $MI shortNames.txt | sed "s/^$MI:[[:space:]]*//")</a>"
done

echo "Making all-in-one page per modality of surfaces..."
for FILE in $(ls fsaverage*_mriOut_*_0_in_all.png*)
do
	MI=$(echo $FILE | sed 's/fsaverage[0-9]*_mriOut_//' | sed 's/_0_in_all.png//')
	echo "<html><body><h1>Modality $(grep $MI shortNames.txt | sed "s/^$MI:[[:space:]]*//") ($MI) surfaces</h1>" >surf$MI.html
	ls fsaverage*_mriOut_${MI}_[0-9]_in_all.png fsaverage*_mriOut_${MI}_[0-9][0-9]_in_all.png fsaverage*_mriOut_${MI}_[0-9][0-9][0-9]_in_all.png 2>/dev/null| sed 's/.*/<img src=\0><br>/g' >>surf$MI.html
	echo "</body></html>" >>surf$MI.html
	MIFILELIST="$MIFILELIST <a href=surf$MI.html>surf$(grep $MI shortNames.txt | sed "s/^$MI:[[:space:]]*//")</a>"
done


fsaverage_mriOut_mi5_31_in_all.png

echo "$LINKS <a href=all.html>All in one page</a>$MIFILELIST<br>" >>$INDEXFILE

for AUXFILE in PCbars.png noiseStdev.png subjectDominance.png eigenspectrum.png
do
	test -f "$AUXFILE" && echo "<img src='$AUXFILE' width=33%>" >> $INDEXFILE
done
#test -f PCbars.png && echo "<img src=PCbars.png width=33%>" >> $INDEXFILE
#test -f noiseStdev.png && echo "<img src=noiseStdev.png width=33%>" >> $INDEXFILE
echo '<br><br>' >> $INDEXFILE
cat significantComponents.txt | sed 's!^[^:]*!<hr><b>&</b>!' | sed 's!#\([0-9][0-9]*\)!<a href=comp\_\1.html>#\1</a>!g' >>$INDEXFILE


MIs=''
m=1
while test -e lightbox_0_mi$m.png
do
	MIs="$MIs mi$m"
	let m=m+1
done

echo $MIs

i=0
while test -e lightbox_${i}_mi1.png
do
	echo -n $i' '
	COMPFILE=comp_${i}.html
	test -f $COMPFILE && rm $COMPFILE
	#echo "<a href=$COMPFILE>$i</a> " >>$INDEXFILE
	
	echo "<html><body><h1>Component #$(echo $i|sed 's/m/-/')</h1><br><br>" >>$COMPFILE
	let PREVi=(i-1+NUMi)%NUMi
	let NEXTi=(i+1)%NUMi
	echo "<a href=comp_${PREVi}.html>PREV</a> <a href=index.html>INDEX</a> <a href=comp_$NEXTi.html>NEXT</a><br>" >>$COMPFILE
	echo "$LINKS<br><br>" >>$COMPFILE

	#for MI in $MIs
	#do
	#    grep $MI shortNames.txt | sed "s/^$MI:[[:space:]]*//" >> $COMPFILE
	#    echo "<br>" >>$COMPFILE
	#    for IMG in lightbox_${i}_$MI.png fsaverage*_mriOut_${MI}_${i}_in_all.png
	#    do
	#	test -f $IMG && echo "<img src=$IMG><br>" >> $COMPFILE
	#    done
	#done
	
	echo "Prior: " >> $COMPFILE
	grep "^$i[[:space:]]" subjectCoursesFractions.txt | sed 's/[[:space:]]*$/% weight<br>/' | sed 's/[0-9][0-9]*[[:space:]]//g' >>$COMPFILE

	#for IMG in $(ls lightbox_${i}_*.png fsaverage*_mriOut_*_${i}_in_all.png)#
	for IMG in $(ls lightbox_${i}_mi?.png 2>/dev/null) $(ls fsaverage*_mriOut_mi?_${i}_in_all.png 2>/dev/null)
	do
		m=$(echo $IMG | sed 's/^.*mi//' | head -c1)
		MI=mi$m
		grep $MI shortNames.txt | sed "s/^$MI:[[:space:]]*//" >> $COMPFILE
		echo ": " >>$COMPFILE
		grep "^$i[[:space:]]" subjectCoursesFractions.txt | awk '{print $'"($m+1)}" | sed 's/[[:space:]]*$/% weight<br>/' >>$COMPFILE
		#echo "IMG=$IMG, MI=$MI, m=$m, "
		test -f $IMG && echo "<img src=$IMG><br>" >> $COMPFILE
	done


	echo "<hr><hr>" >> $COMPFILE
	for IMG in $(ls correlation_${i}_*.png 2>/dev/null)
	do
		# PNG files are 504x418
		echo "<img src=$IMG width=252>" >> $COMPFILE
	done
	
	echo "</body></html>" >>$COMPFILE
	let PREVi=i
	let i=i+1
done

echo "</body></html>" >>$INDEXFILE

echo
echo "Making all-in-one page..."
echo "<html><body>" > all.html
cat comp_?.html comp_??.html comp_???.html 2>/dev/null | grep -v href | sed 's/<br><br>//g' | grep -E 'img|h1' | sed 's!</*[hb][to][md][ly]>!!g' | sed 's/<hr>//g' | sed 's/h1>/h3>/g' >>all.html
echo "</body></html>" >> all.html


echo 'Done!'

