#!/bin/bash
CD=`pwd`

for i in {0..340..10}; do
	cd $CD
	cd water_${i}K
	echo ${i}K > sdac_${i}_data.xvg
	rm -f sdac_${i}.xvg
	echo SOL | $GMX51 dipoles -f md_${i}K.trr -s md_${i}K.tpr -corr mol -c sdac_${i} -temp ${i} >& sdac
	if [[ -f sdac_${i}.xvg ]]; then
		echo ${i}K done!
	else
		echo sdac_${i}K failed
	fi
	egrep -v '\#|\@|\&' sdac_${i}.xvg > sdac_${i}2.xvg
	awk '{print $2}' sdac_${i}2.xvg  >> sdac_${i}_data.xvg 
done

for i in {0..0..1}; do
        cd $CD
        cd water_${i}K
        egrep -v '\#|\@|\&' sdac_${i}.xvg > sdac_${i}2.xvg
	echo "Time (ps)" > ../sdac_times.xvg
        awk '{print $1}' sdac_${i}2.xvg  >> ../sdac_times.xvg
done
paste -d ',' sdac_times.xvg */sdac*_data.xvg > sdac_all.xvg

