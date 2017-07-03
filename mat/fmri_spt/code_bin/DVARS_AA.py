# (c) 2012, Prantik Kundu, University of Cambridge
# (c) 2012, Ameera X. Patel, University of Cambridge

import numpy as np
from sys import argv
import nibabel as nib
from scipy.stats import scoreatpercentile
import matplotlib.pyplot as plt
import pylab as p

nii = argv[1]
dv = nib.load(nii)
nx,ny,nz,nt = dv.get_data().shape
d = dv.get_data().reshape([nx*ny*nz,nt]).T

d_mu = d.mean(0)
d_beta=d-d_mu

d_mask = d_mu!=0
d_mask = (d_mu > scoreatpercentile(d_mu[d_mask],3)) & (d_mu < scoreatpercentile(d_mu[d_mask],98))
db =   (d_beta[:,d_mask]/d_mu[d_mask])*100
dbdt = np.abs(np.diff(db,n=1,axis=0))+0.0000001

dbdt_thr = np.log10(dbdt).mean(0)
dbdt_max = pow(10,scoreatpercentile(dbdt_thr,98))
dbdt_mask = dbdt.mean(0) < dbdt_max

dvars = np.sqrt(np.mean(dbdt[:,dbdt_mask]**2,1))
dvars = dvars*10

np.savetxt('%s_dvars.txt' % nii.split('.')[0],dvars)

if len(argv)>2:
    col=argv[2]
    plt.plot(dvars,col)
    p.xlabel("Frame #")
    p.ylabel("DVARS (%x10)")
    plt.show()

