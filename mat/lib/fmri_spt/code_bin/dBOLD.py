#(c) 2012, Ameera X. Patel, University of Cambridge

import numpy as np
from sys import argv

#Calculates d%BOLDx10 on parcellated data
fn = argv[1]
dp = np.loadtxt(fn)

dbdt = np.abs(np.diff(dp,n=1,axis=0))+0.0000001

np.savetxt('%s_dbold.txt' % fn.split('.')[0],dbdt)
