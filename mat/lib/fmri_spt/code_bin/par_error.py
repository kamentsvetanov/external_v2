#(c) 2012, Ameera X. Patel, University of Cambridge

import numpy as np
from sys import argv

ts=np.loadtxt(argv[1])
tss=np.sum(ts,axis=0)
zeros=np.where(tss==0)[0]
zeros=zeros+1

if len(zeros)>0:
    np.savetxt('par_error_%s.txt' % argv[2],zeros,delimiter=',',fmt='%.0f')
