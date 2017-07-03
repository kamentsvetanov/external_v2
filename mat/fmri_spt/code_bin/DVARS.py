#(c) Ameera X. Patel (2012), University of Cambridge

import numpy as np
from sys import argv
import nibabel as nib
import matplotlib.pyplot as plt
import pylab as p

nii=argv[1]
fn=nib.load(nii)
nx,ny,nz,nt = fn.get_data().shape
data = fn.get_data().reshape([nx*ny*nz,nt]).T

d_mu = data.mean(0)
d_mask = d_mu!=0
db=data[:,d_mask]

dbdt = np.abs(np.diff(db,n=1,axis=0))+0.0000001
dvars = np.sqrt(np.mean(dbdt**2,1))

np.savetxt('%s_dvars.txt' % nii.split('.')[0],dvars)

if len(argv)>2:
    col=argv[2]
    plt.plot(dvars,col)
    p.xlabel("Frame #")
    p.ylabel("DVARS (%x10)")
    plt.show()

