#(c) 2012, Ameera X. Patel, University of Cambridge

import numpy as np
from sys import argv
import matplotlib.pyplot as plt
import pylab as p

cloud=np.loadtxt(argv[1])
fit=np.loadtxt(argv[2])

cs=argv[3]
cl=argv[4]

x=[0,180]
y=[0,0]

plt.scatter(cloud[:,0],cloud[:,1],s=4, color=cs, marker='.')
plt.plot(x,y,c=cl)
plt.plot(fit[:,0],fit[:,1],color=cl)
p.axis([0,180,-0.2,0.2])
p.xlabel("Euclidean Distance (mm)")
p.ylabel("delta R")

plt.show()