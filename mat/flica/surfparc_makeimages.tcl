# surfparc_makeimages.tcl

set subjectsdir $env(SUBJECTS_DIR)
set subjectdir "${subjectsdir}/${subject}"
#set imagedir "${env(SUBJECTS_DIR)}/report/img/${subject}"
set imagedir "tempdir"

puts "Subject Dir: $subjectdir"
puts "Hemi: $hemi"
puts "Suffix: '$env(SUFFIX)'"

set hemisphereLetter [string trimright $hemi h]
puts "HemisphereLetter: $hemisphereLetter"

#----------------------------------
# Prep
#----------------------------------
# 0 Main vertices 
# 1 Inflated vertices 
# 2 White vertices 
# 3 Pial vertices 
# 4 Orig vertices 

# Supposed to load into pial vertex slots, but appears to load into main instead
# read_pial_vertex_coordinates

read_surface_vertex_set 1 inflated
read_surface_vertex_set 3 pial 

set componentFile $env(COMPONENTS_FILENAME)_${hemisphereLetter}$env(SUFFIX).mgh
set componentCount [exec mri_info --nframes $componentFile]

puts "componentFile = $componentFile"
puts "componentCount = $componentCount"

#sclv_read_from_volume 0 mriOut_mi3_${hemisphereLetter}.mgh 0
sclv_read_from_volume 0 $componentFile 0
## To match new MATLAB range of 3-10:

#puts "Using z-stat threshold range 3-10"
#set fmin 3
#set fmid 6.5
#set fslope 0.142857

puts "Using z-stat threshold range 2.3-10"
set fmin 2.3
set fmid 6.15
set fslope 0.12987012987

#puts "WARNING WARNING Using range 3-20!!!!!!!!!"
#set fmin 3
#set fmid 11.5
#set fslope 0.0588235

##puts "Using range 2-7"
##set fmin 2
##set fmid 4.5
##set fslope 0.2
##set colscalebarflag 1


#puts "Using range 0.01-10.01 for parcellation"
#set fmin 1.00
#set fmid 2.00
#set fslope 0.5


# note: following command wants side omitted
#labl_import_annotation "aparc.annot"

set rotmult 1

if {$hemi == "rh"} {
  set rotmult -1
}

#---------------------------
# Iterate surfaces
#---------------------------
#foreach surfix {3 1} 
foreach surfix {1} {
  set surfname "ERROR"

  switch -exact -- $surfix {
    #1 { set surfname in ; set zoom 1 ; labl_import_annotation "aparc.annot"; set labels_before_overlay_flag 1; set labelstyle 0}
    1 { set surfname in ; set zoom 1 ; set curv fsaverage/surf/${hemi}.curv ; read_binary_curv ; set forcegraycurvatureflag 1 }
    3 { set surfname pl ; set zoom 1.35 }
  }

#    3 { set surfname pl ; set zoom 1.35 ; labl_import_annotation "aparc.annot"; set labels_before_overlay_flag 1; set labelstyle 1}

  #show_surf vertexSet

  set_current_vertex_set $surfix

  #---------------------------
  # Iterate views
  #---------------------------
  #for {set viewix0 0} {$viewix0 < 2} {incr viewix0 1} 
  for {set viewix0 0} {$viewix0 < 4} {incr viewix0 1} {

    switch -exact -- $viewix0 {
      0 { set rot   0                   ; set axis a ; set viewname lat }
      1 { set rot 180                   ; set axis y ; set viewname med }
      2 { set rot 90                   ; set axis x ; set viewname bot }
      3 { set rot -90                   ; set axis x ; set viewname top }
    }

    make_lateral_view

    switch -exact -- $axis {
      x { rotate_brain_x $rot }
      y { rotate_brain_y $rot }
    }

    scale_brain $zoom
     
    for {set componentNumber 0} {$componentNumber < $componentCount} {incr componentNumber 1} { 
	puts "Component: $componentNumber"
	sclv_set_current_timepoint $componentNumber 0
	set invphaseflag 0
	redraw
	# Use braces to avoid tcl's utterly brain-dead catenation inadequacies...
	set imagepath "${imagedir}/${subject}_$env(COMPONENTS_FILENAME)_${componentNumber}_${surfname}_${hemi}_${viewname}.tif"
    	save_tiff $imagepath

# Uncomment the following to also generate sign-flipped images!! Useful for making reports, but obviously makes everything take twice as long.
#	puts "Component: m$componentNumber"
#	sclv_set_current_timepoint $componentNumber 0
#	set invphaseflag 1
#	redraw
#	set imagepath "${imagedir}/${subject}_$env(COMPONENTS_FILENAME)_m${componentNumber}_${surfname}_${hemi}_${viewname}.tif"
#   	save_tiff $imagepath
    }
  }
}

# will cause FS to exit
exit 0
