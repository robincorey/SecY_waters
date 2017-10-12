#!/home/birac/anaconda2/bin/python

# python script to plot and fit MSD data

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.cm as cm
from scipy.optimize import curve_fit
from scipy import optimize
import os

## load data in for plot
'''
''' 

def plotfunction ( str ):
	filename = "sdac_%s2" % i[j]
	x, y = np.loadtxt(fname='%s.xvg' % filename, delimiter=',', skiprows=0, usecols=(0, 1), unpack=True)
	## fit exp

	## fit end
	colors = cm.rainbow(np.linspace(0, 1, 35 ))  ## 24=number of datasets
        plt.plot(x, y, color=colors[j], marker='.', markersize=1)
        plt.xlabel('Time (ps)')
        plt.ylabel('C(t)')
        plt.xlim(0, 25)
        plt.savefig('SDAC_water.png')
        #plt.show ()

i=[ 0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200, 210, 220, 230, 240, 250, 260, 270, 280, 290, 300, 310, 320, 330, 340 ]

for j in xrange(0, 35):
        plotfunction(j)
