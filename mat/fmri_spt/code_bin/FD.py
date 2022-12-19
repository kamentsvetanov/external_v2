#(c) Ameera X. Patel (2012), University of Cambridge

import numpy as np
import math
from sys import argv
import matplotlib.pyplot as plt
import pylab as p

m = np.loadtxt(argv[1])
pi=math.pi

m[:,0]=m[:,0]*(pi*50/180)
m[:,1]=m[:,1]*(pi*50/180)
m[:,2]=m[:,2]*(pi*50/180)

dmdt = np.abs(np.diff(m,n=1,axis=0))
fd=np.sum(dmdt,axis=1)

np.savetxt('%s_fd.txt' % (argv[1].split('.')[0]),fd)

if len(argv)>2:
    col=argv[2]
    plt.plot(fd,col)
    p.xlabel("Frame #")
    p.ylabel("Framewise Displacement (mm)")
    plt.show()