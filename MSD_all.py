#!/home/birac/anaconda2/bin/python

# python script to plot and fit MSD data

import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit
from scipy import optimize
import os

## load data in for plot
'''
file nam1ge= ave_${slice}.plot.err_trim.xvg
''' 

### This bit builds colour array from black to grey and back
plotStyle = ['0.05', '0.1', '0.15', '0.2', '0.25', '0.3', '0.35', '0.4', '0.45', '0.5', '0.55', '0.6', '0.6', '0.55', '0.5', '0.45', '0.4', '0.35', '0.3', '0.25', '0.2', '0.15', '0.1', '0.05' ]

# This bit builds colour array http://matplotlib.org/examples/color/colormaps_reference.html
# Need to get working
cmaps = [('Miscellaneous', ['rainbow'])]


#os.remove('A_values.txt')

def plotfunction ( str ):
        #val = '%.2f' % i[j]
	#print '%s' % val
	filename = "ave_%s.plot.err_trim" % i[j]
	x, y, err = np.loadtxt(fname='../%s.xvg' % filename, delimiter=' ', skiprows=4, usecols=(0, 1, 2), unpack=True) 
	## load data in for fitting
	xdata, ydata, yerr = np.loadtxt(fname='../%s.xvg' % filename, delimiter=' ', skiprows=4000, usecols=(0, 1, 2), unpack=True)
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
	logyerr = yerr / ydata
	#define our (line) fitting function
	#fitfunc = lambda p, x: p[0] + p[1] * x
	#errfunc = lambda p, x, y: (y - fitfunc(p, x))
	#pinit = [1.0, -1.0]
	#out = optimize.leastsq(fitfunc, pinit,
	#                       args=(logx, logy), full_output=1)
	# define our (line) fitting function
	fitfunc = lambda p, x: p[0] + p[1] * x
	errfunc = lambda p, x, y, err: (y - fitfunc(p, x)) / err
	pinit = [1.0, -1.0]
	out = optimize.leastsq(errfunc, pinit,
        	               args=(logx, logy, logyerr), full_output=1)
	pfinal = out[0]
	covar = out[1]
	#print pfinal
	#print covar
	index = pfinal[1]
	amp = 10.0**pfinal[0]
	#print index
	#print amp
	indexErr = np.sqrt( covar[0][0] )
	#ampErr = np.sqrt( covar[1][1] ) * amp
	##########
	# Plotting data
	##########
	#plt.title('%s' % filename)
	plt.plot(x, y, color='%s' % plotStyle[j], marker='.', markersize=2)
	#plt.plot(x, y, color='%s' % plotStyle[j], marker='.', markersize=2)
	#plt.text(5, 6.5, 'a = %5.2f' % index)
	#plt.text(5, 4.5, 'k = %5.2f' % amp)
	#plt.errorbar(x, y, yerr=err, fmt='k.')
	plt.loglog(xdata, powerlaw(xdata, amp, index), 'r-', alpha=0)
	plt.xlabel('Time (ps)')
	plt.ylabel('MSD (nm)')
	plt.xlim(0, 50)
	plt.savefig('All.png')
	#plt.show ()
	#with open ("A_values.txt", "a") as myfile:
	#	myfile.write('%.2f,%5.2f,%5.2f \n' % (i[j], index, indexErr ))
	#return

#i=np.arange(-5.75,6.25,0.5)                     # need numpy for decimal looping

i=[-5.75, -5.25, -4.75, -4.25, -3.75, -3.25, -2.75, -2.25, -1.75, -1.25, -.75, -.25, .25, .75, 1.25, 1.75, 2.25, 2.75, 3.25, 3.75, 4.25, 4.75, 5.25, 5.75]

#i=[1, 2]

for j in xrange(0, 24):
        plotfunction(j)
