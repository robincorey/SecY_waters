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
	filename = "MSD_%s_fit" % i[j]
	## load data in for fitting
	xdata, ydata = np.loadtxt(fname='%s.xvg' % filename, delimiter=',', skiprows=4200, usecols=(0, 1), unpack=True)
	##########
	# Fitting the data -- Least Squares Method
	##########
	# Power-law fitting is best done by first converting
	# to a linear equation and then fitting to a straight line.
	#
	#  y = a * x^b
	#  log(y) = log(a) + b*log(x)
	#
	# adapted from http://scipy-cookbook.readthedocs.io/items/FittingData.html
	powerlaw = lambda x, amp, index: amp * (x**index)
	#yerr = 0
	#yerr = 0.01 * ydata
	logx = np.log10(xdata)
	logy = np.log10(ydata)
	logyerr = 1 #yerr / ydata
	# define our (line) fitting function
	fitfunc = lambda p, x: p[0] + p[1] * x
	errfunc = lambda p, x, y, err: (y - fitfunc(p, x)) / err
	pinit = [1.0, -1.0]
	out = optimize.leastsq(errfunc, pinit,
        	               args=(logx, logy, logyerr), full_output=1)
	pfinal = out[0]
	covar = out[1]
	index = pfinal[1]
	amp = 10.0**pfinal[0]
	with open ("A_values_indv.txt", "a") as myfile:
		myfile.write('%5.2f \n' %  index )
	return

i=[-5.75, -5.25, -4.75, -4.25, -3.75, -3.25, -2.75, -2.25, -1.75, -1.25, -.75, -.25, .25, .75, 1.25, 1.75, 2.25, 2.75, 3.25, 3.75, 4.25, 4.75, 5.25, 5.75]

for j in xrange(0, 24):
        plotfunction(j)
