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
file nam1ge= ave_${slice}.plot.err_trim.xvg
''' 
#os.remove('A_values.txt')

def plotfunction ( str ):
	filename = "%s_dipcorr" % j
	#filename = 'test'
	x, y = np.loadtxt(fname='%s.xvg' % filename, delimiter=' ', skiprows=8, unpack=True) 
        xdata, ydata = np.loadtxt(fname='%s.xvg' % filename, delimiter=' ', skiprows=20, usecols=(0, 1), unpack=True)
        ##########
        # Fitting the data -- exp
        ##########
	# Fast  = A * FastPercent * 0.01
	# Slow = A * (100 - FastPercent( * 0.01
	# Y = Fast * exp(-KfastX) + Slow * exp(-KslowX) + Y0
	#F = lambda xdata, A, FP: A * FP * 0.01
	#S = lambda xdata, A, FP: A * (100 - FP) * 0.01
        double_exp = lambda xdata, A, FP, Kf, Ks, Y0: (A * FP * 0.01) * np.exp(xdata * -Kf) + (A * (100 - FP) * 0.01) * np.exp(xdata * -Ks) + Y0
        # Guess inputs for A, Y0, FP, Kf, Ks
        guess_a, guess_b, guess_c, guess_d, guess_e = 0.5, 31, 1.2, 0.12, 0.5
        guess = [guess_a, guess_b, guess_c, guess_d, guess_e]
        # define parameters
        params, cov = curve_fit(double_exp, xdata, ydata, p0=guess)
        A, FP, Kf, Ks, Y0 = params
	print "A = %s\nY0 = %s\nFP = %s\nKf = %s\nKs = %s\n" % (A, Y0, FP, Kf, Ks)
        #plt.clf()
        #best_fit = lambda xdata: (F * np.exp(xdata * -Kf)) + (S * np.exp(xdata * -Ks)) + Y0 
	best_fit = lambda xdata: (A * FP * 0.01) * np.exp(xdata * -Kf) + (A * (100 - FP) * 0.01) * np.exp(xdata * -Ks) + Y0
	##########
	# Plotting data
	##########
	# This bit builds colour array http://matplotlib.org/examples/color/colormaps_reference.html
	colors = cm.rainbow(np.linspace(0, 1, 24 ))  ## 24=number of datasets
	#plt.title('%s' % filename)
	plt.plot(x, y, color=colors[j], marker='.', markersize=1)
	plt.plot(xdata, best_fit(xdata), color='0', marker='.', markersize=1)
	#plt.plot(xdata, best_fit(xdata), 'k.', markersize=1)
	plt.xlabel('Time (ps)')
	plt.ylabel('Cu(t)')
	plt.xlim(0, 25)
	plt.savefig('Data_test_double.png')
	with open ("tu_double.txt", "a") as myfile:
                value = 0.367879441 # 1 / e 
        	line2d = plt.plot(xdata, best_fit(xdata))
        	#xvalues = line2d[0].get_xdata()
        	yvalues = line2d[0].get_ydata()
        	def find_nearest(yvalues,value):
           	   idx = (np.abs(yvalues-value)).argmin()
             	   return xvalues[idx]
		tu = find_nearest(yvalues,value)
	        #tu = np.log((e - Y0) / A) / Kf  # time at which Cu(t) equals 1/e
                #tu = e / ((A * FP * 0.01)
		myfile.write('%.2f,%5.2f \n' % (i[j], tu ))
        return

i=[-5.75, -5.25, -4.75, -4.25, -3.75, -3.25, -2.75, -2.25, -1.75, -1.25, -.75, -.25, .25, .75, 1.25, 1.75, 2.25, 2.75, 3.25, 3.75, 4.25, 4.75, 5.25, 5.75]

for j in xrange(0, 12):
        plotfunction(j)
