#(c) 2012, Ameera X. Patel, University of Cambridge

import numpy as np
from sys import argv

#Calculates d%BOLDx10 on parcellated data
fn = argv[1]
d = np.loadtxt(fn)

mu=d.mean(0)
db=d-mu
dp=(db/mu)*100

dpdt=np.abs(np.diff(dp,n=1,axis=0))+0.0000001
dpdt=dpdt*10

np.savetxt('%s_dbold.txt' % fn.split('.')[0],dpdt)
