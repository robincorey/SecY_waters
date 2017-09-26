#!/bin/bash
#Analysing NVE sims
# FOR TOM ONLY!!!

GMX5=/usr/local/gromacs_5/bin
CURRENT_DIR=`pwd`

TIMES=(500 502 504 506 508 510 600 602 604 606 608 610 700 702 704 706 708 710 800 802 804 806 808 810 900 902 904 906 908 910 1000)

TL=${#TIMES[@]}

function resize {
## Find coordinates of 2 pore ring residues
x1=`grep "822ILE     CA" ${GRO} | awk '{print $3}'`
y1=`grep "822ILE     CA" ${GRO} | awk '{print $4}'`
z1=`grep "822ILE     CA" ${GRO} | awk '{print $5}'`
x2=`grep "1149ILE     CA" ${GRO} | awk '{print $3}'`
y2=`grep "1149ILE     CA" ${GRO} | awk '{print $4}'`
z2=`grep "1149ILE     CA" ${GRO} | awk '{print $5}'`

# Apply midpoint formula to get center
xcenter=`echo "scale=4; (${x1} + ${x2}) / 2" | bc`
ycenter=`echo "scale=4; (${y1} + ${y2}) / 2" | bc`
zcenter=`echo "scale=4; (${z1} + ${z2}) / 2" | bc`

# Find clipping factors
xcut1=`echo "scale=2; $xcenter - 2.5" | bc`
xcut2=`echo "scale=2; $xcenter + 2.5" | bc`
ycut1=`echo "scale=2; $ycenter - 2.5" | bc`
ycut2=`echo "scale=2; $ycenter + 2.5" | bc`
zcut1=`echo "scale=2; $zcenter - 6" | bc`
zcut2=`echo "scale=2; $zcenter + 6" | bc`

# Make bespoke gselect input file for 5x5x12 prism
echo "$xcut1<x and x<$xcut2 and $ycut1<y and y<$ycut2 and $zcut1<z and z<$zcut2" > select.dat

# Do clipping
$GMX5/g_select -f ${GRO} -s trim.tpr -sf select.dat -on trim -selrpos whole_res_com -rmpbc
editconf -f ${GRO} -o ${GRO//.gro}_prism.gro -n trim.ndx
mv *\#* Backups/
}

for i in `seq 0 $TL`; do
        cd ${CURRENT_DIR}
        cd NVE_${TIMES[i]}
	## 1 - define square prism: 5 x 5 x 12 around centre
	#can define selection.dat in one go. Do we need to do trr or sep gro files here?	
	GRO=$FILES/${ARRAY[i]}.pbc0.gro
	TOP=~/Desktop/Subs_model_Tom/setup/${ARRAY[i]}/${ARRAY[i]}.top
	if [[ ! -d ${ARRAY[i]}_NPT_analysis ]]; then
		mkdir ${ARRAY[i]}_NPT_analysis
	fi
	#echo System | $GMX5/trjconv -s $FILES/md_tom_*.tpr -f $FILES/${ARRAY[i]}.pbc.center.xtc -skip 50 -sep -o ${ARRAY[i]}_NPT_analysis/${ARRAY[i]}.gro
	ALLGRO=(${ARRAY[i]}_NPT_analysis/*_prism.gro)
	GROLEN=`echo "${#ALLGRO[@]} - 1" | bc`
	#$GMX5/grompp -f emshort.mdp -c ${GRO} -p ${TOP} -o trim.tpr	
	for j in `seq 0 ${GROLEN}`; do
		GRO=${ALLGRO[j]}
		#resize
		## determine water occupancy of each nm bit and plot average (log scale)
		rm temp
		rm ${GRO//.gro}_out
		while IFS='' read -r line || [[ -n "$line" ]]; do
        		zvalue=`echo $line | awk '{print $5}'`
        		echo $zvalue >> temp
		done < ${GRO}
		SLICE=(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20)
		for k in `seq 0 20`; do
        		num=`grep -c "^${SLICE[k]}\." temp`
       			echo $num >> ${GRO//.gro}_out
		done
	paste -d "," ${ARRAY[i]}_NPT_analysis/*${ARRAY[i]}*_out > ${ARRAY[i]}.waters.txt
	done
done
