#(c) 2012, Ameera X. Patel, University of Cambridge

import nibabel as nib
import numpy as np
from sys import argv, exit
from scipy.stats import scoreatpercentile

#Load data
dfn = argv[1]
outp = argv[2]
dv = nib.load(dfn)
nx,ny,nz,nt = dv.get_data().shape
d = dv.get_data().reshape([nx*ny*nz,nt]).T

#Compute mean and mask to remove 0 voxels.
d_mu = d.mean(0) 
d_mask = d_mu!=0 
d_mask = (d_mu > scoreatpercentile(d_mu[d_mask],1))

dp=d[:,d_mask] # 0 voxel removed data.

# fast mode calculation
dpp = dp.reshape(len(dp)*len(dp.T))
drem = dpp!=0
drem = (dpp > scoreatpercentile(dpp[drem],10)) & (dpp < scoreatpercentile(dpp[drem],90)) # removes extremes to speed up calculation

dr=dpp[:,drem] # apply mask

# write fast mode calculator
def modecalc(data):
    counts = {}
    for x in data.flatten():
        counts[x] = counts.get(x,0) + 1
    maxcount = max(counts.values())
    modelist = []
    for x in counts:
        if counts[x] == maxcount:
            modelist.append(x)
    return modelist

modl=modecalc(dr)
mod=np.mean(modl) # if more than one mode found for unimodal data, average.
modarr=np.array([mod])
np.savetxt('%s.txt' % outp,modarr)