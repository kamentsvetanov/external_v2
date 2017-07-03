#(c) 2012, Ameera X. Patel, University of Cambridge

import numpy as np
from sys import argv, exit
import matplotlib.pyplot as plt

m=np.loadtxt(argv[1])

m=np.triu(m)

np.fill_diagonal(m,0)
m=m[np.logical_not(np.isnan(m))]
m=m[m != 0]

plt.hist(m,bins=50,color=[0.1,0.3,0.7],ec=[0.1,0.3,0.7])
plt.show()