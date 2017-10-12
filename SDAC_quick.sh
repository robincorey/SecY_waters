#!/bin/bash
CD=`pwd`

for i in {0..340..10}; do
	sed 's/^     //g' sdac_${i}2.xvg  -i
	sed 's/^    //g' sdac_${i}2.xvg  -i 
	sed 's/, /,/g' sdac_${i}2.xvg  -i
done
