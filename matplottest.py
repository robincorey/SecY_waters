#!/opt/anaconda/bin/python

## Archetype script for plotting using matplotlib

# import
import matplotlib.pyplot as plt
import numpy as np

# load in data
'''
last clause: r/b/g etc -/o
'''
plt.plot([1,2,3,4], [1, 4, 9, 16], 'ro')

# Graph settings
plt.axis([0, 6, 0, 20])  # [xmin, xmax, ymin, ymax]
plt.ylabel('MSD')
plt.xlabel('Time (ns)')


# Make graph
plt.show()
