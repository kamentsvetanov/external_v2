#!/usr/bin/env python

# SpeedyPP v1.1
# Last update: 24-04-13 (AXP)

# Core Image Processing adapted from http://dx.doi.org/10.1016/j.neuroimage.2011.12.028
# Kundu, P., Inati, S.J., Evans, J.W., Luh, W.M. & Bandettini, P.A. Differentiating
#   BOLD and non-BOLD signals in fMRI time series using multi-echo EPI. NeuroImage (2012).

# De-noising module adapted for motion artifact removal by Patel, AX. (2013)

# Script maintained and updated by Patel, AX. (2013). Email: ap531@cam.ac.uk

import sys
from re import split as resplit
import re
from os import system,getcwd,mkdir,chdir,popen
import os.path
from string import rstrip,split
from optparse import OptionParser,OptionGroup

#Filename parser for NIFTI and AFNI files
def dsprefix(idn):
    def prefix(datasetname):
        return split(datasetname,'+')[0]
    if len(split(idn,'.'))!=0:
        if split(idn,'.')[-1]=='HEAD' or split(idn,'.')[-1]=='BRIK' or split(idn,'.')[-2:]==['BRIK','gz']:
            return prefix(idn)
        elif split(idn,'.')[-1]=='nii' and not split(idn,'.')[-1]=='nii.gz':
            return '.'.join(split(idn,'.')[:-1])
        elif split(idn,'.')[-2:]==['nii','gz']:
            return '.'.join(split(idn,'.')[:-2])
        else:
            return prefix(idn)
    else:
        return prefix(idn)

def dssuffix(idna):
    suffix = idna.split(dsprefix(idna))[-1]
    spl_suffix=suffix.split('.')
    if len(spl_suffix[0])!=0 and spl_suffix[0][0] == '+': return spl_suffix[0]
    else: return suffix


#Configure options and help dialog
parser=OptionParser()
parser.add_option('-d',"",dest='dsinput',help="Input dataset. ex: -d PREFIX.nii.gz  ",default='')
parser.add_option('-f',"",dest='FWHM',help="Target smoothness (3dBlurToFWHM). ex: -f 8mm (default 5mm.) ",default='5mm')
parser.add_option('-a',"",dest='anat',help="Anatomical dataset. ex: -a mprage.nii.gz",default='')
parser.add_option('-o',"",action="store_true",dest='oblique',help="Oblique acqusition",default=False)
regropts=OptionGroup(parser,"Denoising (baseline regression) options, can specify multiple options. Requires anatomical.")
regropts.add_option('',"--rall", action="store_true",dest='rall',help="Regress all (except white matter).",default=False)
regropts.add_option('',"--rmot", action="store_true",dest='rmot',help="Regress motion.",default=False)
regropts.add_option('',"--rmotd", action="store_true",dest='rmotd',help="Regress motion derivatives.",default=False)
regropts.add_option('',"--rcsf", action="store_true",dest='rcsf',help="Regress CSF signal.",default=False)
regropts.add_option('',"--rwm", action="store_true",dest='rwm',help="Regress white matter signal (not recommended).",default=False)
regropts.add_option('',"--lowpass",dest='lowpass',help="Low pass frequencey. ex: -l 0.1 (default none)",default='99')
parser.add_option_group(regropts)
extopts=OptionGroup(parser,"Extended preprocessing options")
extopts.add_option('',"--basetime",dest='basetime',help="Time to steady-state equilibration in seconds. Default 0. ex: --basetime 10 ",default=0)
extopts.add_option('',"--betmask",dest='betmask',action='store_true',help="More lenient functional masking (using BET).",default=False)
extopts.add_option('',"--skullstrip",action="store_true",dest='skullstrip',help="Skullstrip anatomical",default=False)
extopts.add_option('',"--tlrc",dest='tlrc',help="Normalize to Talairach space, specify base (DO NOT use this option if you are using the fmri_spt), ex: --tlrc TT_N27+tlrc",default=False)
extopts.add_option('',"--despike",action="store_true",dest='despike',help="Despike data. Good for datasets with spikey motion artifact",default=False)
extopts.add_option('',"--TR",dest='TR',help="The TR. Default is to read from input dataset",default='')
extopts.add_option('',"--tpattern",dest='tpattern',help="Slice timing (i.e. alt+z, see 3dTshift --help). Default from header. Correction skipped if not found.",default='')
extopts.add_option('',"--zeropad",dest='zeropad',help="Zeropadding options. -z N means add N slabs in all directions. Default 15 (N.B. autoboxed after coregistration)",default="15")
extopts.add_option('',"--highpass",dest='highpass',help="Highpass filter in Hz (default 0.02)",default=0.02)
extopts.add_option('',"--align_base",dest='align_base',help="Base EPI for allineation",default='')
extopts.add_option('',"--align_interp",dest='align_interp',help="Interpolation method for allineation",default='cubic')
extopts.add_option('',"--align_args",dest='align_args',help="Additional arguments for 3dAllineate EPI-anatomical alignment",default='')
extopts.add_option('',"--label",dest='label',help="Extra label to tag this SpeedyPP folder",default='')
extopts.add_option('',"--keep_int",action="store_true",dest='keep_int',help="Keep preprocessing intermediates. Default is delete to save space.",default=False)
extopts.add_option('',"--OVERWRITE",dest='overwrite',action="store_true",help="If spp.xyz directory exists, overwrite. ",default=False)
extopts.add_option('',"--CLUSTER",dest='cluster',action="store_true",help="Cluster mode (disables greedy multithreading). ",default=False)
extopts.add_option('',"--exit",action="store_true",dest='exit',help="Generate script and exit",default=0)
parser.add_option_group(extopts)
(options,args) = parser.parse_args()

#Parse dataset input names
if options.dsinput=='':
    print "Need at least input dataset. Try SpeedyPP.py -h"
    sys.exit()
if os.path.abspath(os.path.curdir).__contains__('spp.'):
    print "You are inside a SpeedyPP directory! Please leave this directory and rerun."
    sys.exit()
if options.tlrc and options.anat=='': 
	print "You specified standard space normalization without an anatomical reference. This is disabled, exiting."
	sys.exit()
if (options.rwm or options.rcsf or options.rall) and options.anat=='':
	print "You specified WM or CSF regression without an anatomical reference. Exiting."
	sys.exit()
	
#Parse prefix and suffix
dsinput=dsprefix(options.dsinput)
prefix=dsprefix(options.dsinput)
isf =dssuffix(options.dsinput)

#Parse timing arguments
if options.TR!='' : tr=float(options.TR)
else: 
    #print '3dinfo -tr %s%s' % (prefix,isf)
    tr=float(os.popen('3dinfo -tr %s%s' % (prefix,isf)).readlines()[0].strip())
    options.TR=str(tr)
timetoclip=float(options.basetime)
basebrik=int(timetoclip/tr)
highpass = float(options.highpass)
highpass_ind = 1/(highpass*tr)

#Prepare script variables
sppdir=os.path.dirname(sys.argv[0])
sl = []                 #Script command list
sl.append('#'+" ".join(sys.argv).replace('"',r"\""))

osf='.nii.gz'               #Using NIFTI outputs

vrbase=prefix
if options.align_base == '':
    align_base = basebrik
else: 
    align_base = options.align_base
setname=prefix+options.label
startdir=rstrip(popen('pwd').readlines()[0])
combstr=""; allcombstr=""

if options.overwrite: 
    system('rm -rf spp.%s' % (setname))
else: 
    sl.append("if [[ -e spp.%s/stage ]]; then echo SpeedyPP directory exists, exiting \(try --OVERWRITE\).; exit; fi" % (setname))

sl.append("starttime=`date +%s`")

system('mkdir -p spp.%s' % (setname))

sl.append("cp _spp_%s.sh spp.%s/" % (setname,setname))
sl.append("cd spp.%s" % setname)
thecwd= "%s/spp.%s" % (getcwd(),setname)

if len(split(options.zeropad))==1 :
    zeropad_opts=" -I %s -S %s -A %s -P %s -L %s -R %s " % (tuple([options.zeropad]*6))
elif options.zeropad!='':
    zeropad_opts=options.zeropad
else:
    zeropad_opts=''

if options.despike:
    despike_opt = "-despike"
else:
    despike_opt = ""
if options.cluster: sl.append("export OMP_NUM_THREADS=1")
sl.append("echo; echo; echo SpeedyPP preprocessing script for resting state fMRI!;echo; echo")
sl.append("#SpeedyPP preprocessing script. Prantik Kundu (2012). See http://dx.doi.org/10.1016/j.neuroimage.2011.12.028. ")

#Parse anatomical processing options, process anatomical
if options.anat != '':
    nsmprage = options.anat
    anatprefix=dsprefix(nsmprage)
    pathanatprefix="%s/%s" % (startdir,anatprefix)
    if options.oblique:
        sl.append("if [ ! -e %s_spp_do.nii.gz ]; then 3dWarp -overwrite -prefix %s_sppdo.nii.gz -deoblique %s/%s; fi" % (pathanatprefix,pathanatprefix,startdir,nsmprage))
        nsmprage="%s_sppdo.nii.gz" % (anatprefix)
    if options.skullstrip: 
        sl.append("if [ ! -e %s_ns.nii.gz ]; then 3dSkullStrip -overwrite -prefix %s_ns.nii.gz -input %s/%s; fi" % (pathanatprefix,pathanatprefix,startdir,nsmprage))
        nsmprage="%s_ns.nii.gz" % (anatprefix)

# Calculate rigid body alignment
sl.append("echo 1 > stage" )
vrAinput = "%s/%s%s" % (startdir,vrbase,isf)
sl.append("3dvolreg -quintic -prefix ./%s_vrA%s -base %s[%s] -dfile ./%s_vrA.1D -1Dmatrix_save ./%s_vrmat.aff12.1D %s" % \
          (vrbase,isf,vrAinput,basebrik,vrbase,prefix,vrAinput))
vrAinput = "./%s_vrA%s" % (vrbase,isf)
if options.oblique: 
    if options.anat!='': 
		sl.append("3dWarp -verb -card2oblique %s[0] -overwrite  -newgrid 1.000000 -prefix ./%s_ob.nii.gz %s/%s | \grep  -A 4 '# mat44 Obliquity Transformation ::'  > %s_obla2e_mat.1D" % (vrAinput,anatprefix,startdir,nsmprage,prefix))
    else: sl.append("3dWarp -overwrite -prefix %s -deoblique %s" % (vrAinput,vrAinput))
sl.append("1dcat './%s_vrA.1D[1..6]{%s..$}' > %s/%s_motion.1D " % (vrbase,basebrik,startdir,prefix))
sl.append("3dcalc -expr 'a' -a %s[%s] -prefix ./_eBmask%s" % (vrAinput,align_base,osf))
sl.append("bet _eBmask%s eBmask%s" % (osf,osf))
sl.append("fast -t 2 -n 3 -H 0.1 -I 4 -l 20.0 -b -o eBmask eBmask%s" % (osf))
sl.append("3dcalc -a eBmask%s -b eBmask_bias%s -expr 'a/b' -prefix eBbase%s" % ( osf, osf, osf))

# Calculate affine anatomical warp if anatomical provided, then combine motion correction and coregistration parameters 
if options.anat!='':
    sl.append("cp %s/%s* ." % (startdir,nsmprage))
	
    if options.tlrc:
        sl.append("afnibinloc=`which 3dSkullStrip`")
        sl.append("templateloc=${afnibinloc%/*}")
        atnsmprage = "%s_at.nii" % (dsprefix(nsmprage))
        if not dssuffix(nsmprage).__contains__('nii'): sl.append("3dcalc -a %s -expr 'a' -prefix %s.nii.gz" % (nsmprage,dsprefix(nsmprage)))
        sl.append("if [ ! -e %s ]; then \@auto_tlrc -no_ss -base ${templateloc}/%s -input %s.nii.gz -suffix _at; fi " % (atnsmprage,options.tlrc,dsprefix(nsmprage)))
        sl.append("3dcopy %s* %s+tlrc" % (atnsmprage,dsprefix(atnsmprage)))
        sl.append("3drefit -view orig %s+tlrc " % dsprefix(atnsmprage) )
	
    align_args=""
    if options.align_args!="": align_args=options.align_args
    elif options.oblique: align_args = " -cmass -maxrot 30 -maxshf 30 "
    else: align_args=" -maxrot 20 -maxshf 20 -parfix 7 1  -parang 9 0.83 1.0 "
    if options.oblique: alnsmprage = "./%s_ob.nii.gz" % (anatprefix)
    else: alnsmprage = "%s/%s" % (startdir,nsmprage)
    sl.append("3dAllineate -weight_frac 1.0 -VERB -warp aff -weight eBmask_pve_0.nii.gz -lpc -base eBbase.nii.gz -master SOURCE -source %s -prefix ./%s_al -1Dmatrix_save %s_al_mat %s" % (alnsmprage, anatprefix,anatprefix,align_args))
    if options.tlrc: tlrc_opt = "%s::WARP_DATA -I" % (atnsmprage)
    else: tlrc_opt = ""
    if options.oblique: oblique_opt = "%s_obla2e_mat.1D" % prefix
    else: oblique_opt = ""
    sl.append("cat_matvec -ONELINE  %s %s %s_al_mat.aff12.1D -I  %s_vrmat.aff12.1D  > %s_wmat.aff12.1D" % (tlrc_opt,oblique_opt,anatprefix,prefix,prefix))
else: sl.append("cp %s_vrmat.aff12.1D %s_wmat.aff12.1D" % (prefix,prefix))

#Preprocess datasets
dsin = prefix
if options.tpattern!='':
	tpat_opt = ' -tpattern %s ' % options.tpattern
else:
	tpat_opt = ''
sl.append("3dTshift -heptic %s -prefix ./%s_ts+orig %s/%s%s" % (tpat_opt,dsin,startdir,prefix,isf) )
if options.oblique and options.anat=="":
	sl.append("3dWarp -overwrite -deoblique -prefix ./%s_ts ./%s_ts+orig" % (dsin,osf,dsin))
sl.append("3drefit -deoblique -TR %s %s_ts+orig" % (options.TR,dsin))
if zeropad_opts!="" : sl.append("3dZeropad %s -prefix _eBvrmask.nii.gz %s_ts+orig[%s]" % (zeropad_opts,dsin,basebrik))
sl.append("3dAllineate -overwrite -final %s -%s -float -1Dmatrix_apply %s_wmat.aff12.1D -base _eBvrmask.nii.gz -input _eBvrmask.nii.gz -prefix ./_eBvrmask.nii.gz" % \
	(options.align_interp,options.align_interp,prefix))
if options.betmask: sl.append("bet _eBvrmask%s eBvrmask%s " % (osf,osf ))
else: sl.append("3dAutomask -overwrite -prefix eBvrmask%s _eBvrmask%s" % (osf,osf))
sl.append("3dBrickStat -mask eBvrmask.nii.gz -percentile 50 1 50  _eBvrmask.nii.gz > gms.1D" )
sl.append("3dAutobox -overwrite -prefix eBvrmask%s eBvrmask%s" % (osf,osf) )
sl.append("3dcalc -a eBvrmask.nii.gz -expr 'notzero(a)' -overwrite -prefix eBvrmask.nii.gz")
sl.append("3dAllineate -final %s -%s -float -1Dmatrix_apply %s_wmat.aff12.1D -base eBvrmask%s -input  %s_ts+orig -prefix ./%s_vr%s" % \
	(options.align_interp,options.align_interp,prefix,osf,dsin,dsin,osf))
if options.FWHM=='0mm' or str(options.FWHM)=='0': 
	sl.append("3dcalc -prefix ./%s_sm%s -a ./%s_vr%s[%i..$] -b eBvrmask.nii.gz -expr 'a*notzero(b)' " % (dsin,osf,dsin,osf,basebrik))
else: 
	sl.append("3dBlurInMask -fwhm %s -mask eBvrmask%s -prefix ./%s_sm%s ./%s_vr%s[%i..$]" % (options.FWHM,osf,dsin,osf,dsin,osf,basebrik))
sl.append("gms=`cat gms.1D`; gmsa=($gms); p50=${gmsa[1]}")
sl.append("3dcalc -overwrite -a ./%s_sm%s -expr \"a*1000/${p50}\" -prefix ./%s_sm%s" % (dsin,osf,dsin,osf))
sl.append("3dTstat -prefix ./%s_mean%s ./%s_sm%s" % (dsin,osf,dsin,osf))
sl.append("3dBandpass %s -prefix ./%s_in%s %f 99 ./%s_sm%s " % (despike_opt,dsin,osf,float(options.highpass),dsin,osf) )
sl.append("3dcalc -overwrite -a ./%s_in%s -b ./%s_mean%s -expr 'a+b' -prefix ./%s_in%s" % (dsin,osf,dsin,osf,dsin,osf))
sl.append("3dTstat -stdev -prefix ./%s_std%s ./%s_in%s" % (dsin,osf,dsin,osf))
if not options.keep_int: sl.append("rm %s_ts+orig* %s_vr%s %s_sm%s" % (dsin,dsin,osf,dsin,osf))

#Build denoising regressors
regs = []
if options.rall or options.rmot: 
	sl.append("1d_tool.py -demean -infile %s/%s_motion.1D -write motion_dm.1D" % (startdir,prefix))
	regs.append("motion_dm.1D")
if options.rall or options.rmotd:
	sl.append("1d_tool.py -demean -derivative -infile %s/%s_motion.1D -write motion_deriv.1D" % (startdir,prefix))
	regs.append("motion_deriv.1D")
if options.rall or options.rcsf:
	sl.append("1dcat %s > %s_reg_baseline_pre.1D " % (' '.join(regs),prefix))
	sl.append("3dBandpass -ort %s_reg_baseline_pre.1D -prefix ./%s_pppre.nii.gz %s 99 ./%s_in.nii.gz" % (prefix,prefix,options.highpass,prefix))
	sl.append("echo Downsampling anatomical and segmenting with FSL FAST...")
	sl.append("3dresample -rmode Li -master eBvrmask.nii.gz -inset %s -prefix %s_epi.nii.gz" % (nsmprage,dsprefix(nsmprage)))	
	sl.append("fast -t 1 -n 3 -H 0.1 -I 4 -l 20.0 -g -b -o %s_epi %s_epi.nii.gz" % (dsprefix(nsmprage),dsprefix(nsmprage)))	
	if options.rall or options.rcsf:
		sl.append("tempdir=$HOME/fmri_spt/templates")
		sl.append("tempstr='TT_avg152T1+tlrc'")
		sl.append("\@auto_tlrc -suffix _at -base ${tempdir}/standard/${tempstr} -input %s -no_ss -ok_notice" % (nsmprage))
		sl.append("cat_matvec %s_at.Xat.1D -I -ONELINE > %s_at_inv.1D" % (dsprefix(nsmprage),dsprefix(nsmprage)))
		sl.append("3dAllineate -1Dmatrix_apply %s_at_inv.1D -base %s_in.nii.gz -input ${tempdir}/mask/TT_avg152T1_csf_mask.nii.gz -prefix TT_avg152T1_csf_mask_%s_native.nii.gz -interp NN" % (dsprefix(nsmprage),prefix,prefix))
        sl.append("3dcalc -a %s_epi_seg.nii.gz -b TT_avg152T1_csf_mask_%s_native.nii.gz -expr 'notzero(b)*(equals((a+b),1)+equals((a+b),2))' -prefix %s_csfmask.nii.gz  " % (dsprefix(nsmprage),prefix,prefix) )
        sl.append("3dcalc -overwrite -prefix %s_csfmask.nii.gz -a %s_csfmask.nii.gz -b eBvrmask.nii.gz -expr 'a*b'" % (prefix,prefix))
        sl.append("3dmaskave -quiet -mask %s_csfmask.nii.gz %s_pppre.nii.gz > %s_csf.1D" % (prefix,prefix,prefix))
        regs.append("%s_csf.1D" % (prefix))
if options.rwm:
	sl.append("3dcalc -a %s_epi_seg.nii.gz -b eBvrmask.nii.gz -expr 'notzero(b)*(equals((a+b),4))' -prefix %s_wmmask.nii.gz  " % (dsprefix(nsmprage),prefix) )
	sl.append("3dmaskave -quiet -mask %s_wmmask.nii.gz %s_pppre.nii.gz > %s_wm.1D" % (prefix,prefix,prefix))
	regs.append("%s_wm.1D" % (prefix))
		
if regs!=[]:
	sl.append("1dcat %s > %s_reg_baseline.1D" % (' '.join(regs), prefix) )
	sl.append("3dBandpass -ort %s_reg_baseline.1D -prefix ./%s_pp.nii.gz %f %f ./%s_in.nii.gz" % (prefix,prefix,float(options.highpass),float(options.lowpass),prefix))

#Copy processed files into start directory and compute time taken
if regs!=[] : sl.append("cp %s_pp.nii.gz %s_in.nii.gz %s" % (prefix,prefix,startdir))
sl.append("stoptime=`date +%s`")
sl.append("echo; echo; echo Preprocessing required `ccalc -form cint ${stoptime}-${starttime}` seconds.; echo; echo;")

#Write the preproc script and execute it
ofh = open('_spp_%s.sh' % setname ,'w')
#print "\n".join(sl)+"\n" #DEBUG
ofh.write("\n".join(sl)+"\n")
ofh.close()
if not options.exit: system('bash _spp_%s.sh' % setname)
