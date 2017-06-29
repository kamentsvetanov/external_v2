#(c) 2012, Ameera X. Patel, University of Cambridge

import numpy as np
from sys import argv
import matplotlib.pyplot as plt
import pylab as p

fd = argv[1]
dbold = argv[2]
curve = argv[3]
cdots = argv[4]
cline = argv[5]

mot = np.loadtxt(fd)
rois = np.loadtxt(dbold)
loess = np.loadtxt(curve)

plt.plot(mot,rois,'o',c=cdots,markersize=1.5)
plt.plot(loess[:,0],loess[:,1],cline)
p.xlabel("Framewise Displacement (mm)")
p.ylabel("|d%BOLDx10|")
plt.show()

