#!/bin/bash
#Analysing NVE sims

GMX5=/usr/local/gromacs_5/bin
CURRENT_DIR=`pwd`

TIMES=(500 502 504 506 508 510 600 602 604 606 608 610 700 702 704 706 708 710 800 802 804 806 808 810 900 902 904 906 908 910 1000 1005)

TL=`echo ${#TIMES[@]} - 1 | bc`

function resize {
if [[ ! -d Backups ]]; then
	mkdir Backups
fi 

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
zcut1=`echo "scale=2; $zcenter + ${slice2}" | bc`
zcut2=`echo "scale=2; $zcenter + ${slice1}" | bc`

# Make bespoke gselect input file for 5x5x12 prism
echo "resname SOL and $xcut1<x and x<$xcut2 and $ycut1<y and y<$ycut2 and $zcut1<z and z<$zcut2" > select_${slice}.dat

rm trim_${slice}.ndx
$GMX5/g_select -f ${GRO} -s ${TPR} -sf select_${slice}.dat -on trim_${slice} -selrpos whole_res_com -rmpbc
#$GMX5/g_msd -f ${TRR} -s trim_${slice}.tpr -o msd_${slice} -n trim_${slice}.ndx
mv *\#* Backups/
}

for i in `seq 0 $TL`; do
        cd ${CURRENT_DIR}
        cd NVE_${TIMES[i]}
	## 1 - define square prism: 5 x 5 x 12 around centre
	#can define selection.dat in one go. Do we need to do trr or sep gro files here?	
	TPR=NVE_${TIMES[i]}.tpr
	#if [[ ! -f NVE_${TIMES[i]}input0.gro ]]; then
		echo System | $GMX5/trjconv -s ${TPR} -f NVE_${TIMES[i]}.trr -sep -b 0 -e 0 -o NVE_${TIMES[i]}input.gro
	#fi
	GRO=NVE_${TIMES[i]}input0.gro	# CHANGED
	TRR=NVE_${TIMES[i]}.trr
	SLICE=(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23)
	for j in `seq 0 23`; do
		slice1=`echo "scale=4; ${SLICE[j]} * 0.5 - 5.5" | bc`
		slice2=`echo "scale=4;${slice1} - 0.5" | bc`
		slice=`echo "scale=4;${slice1} - 0.25" | bc`
		#echo $slice $slice1 $slice2 
		resize
		if [[ ! -d MSD ]]; then
			mkdir MSD
		fi
		#sed "s/#NUM#/$SOL/g" TOP.top > NVE_${TIMES}_${slice}.top
		#echo 1 | editconf -f ${GRO} -o NVE_${TIMES}_${slice}.gro -n trim_${slice} 
		#$GMX5/grompp -f ../em.mdp -p NVE_${TIMES}_${slice}.top -c NVE_${TIMES}_${slice}.gro -o NVE_${TIMES}_${slice}.tpr
		#for k in `seq 500 1000`; do
			#$GMX5/trjconv -s ${TPR} -f  NVE_${TIMES}_short.xtc -n trim_${slice} -o MSD/${slice}_${k}.gro
			#editconf -f NVE_${TIMES}_${slice}_input0.gro -o NVE_${TIMES}_${slice}_input.pdb 
			#cat trim_${slice}.ndx
		#	ps=`echo "( $k / 20 )" | bc`	
		#	group=`echo "$k" | bc`
		echo 1 | $GMX5/g_msd -s ${TPR} -f NVE_${TIMES[i]}.trr -o MSD/msd_${slice}_full50 -b 0 -e 50 -n trim_${slice} -trestart -1 -pdb MSD/msd_${slice}.pdb -tpdb 1   #trestart -1 gives great data
		echo 1 | editconf -f MSD/msd_${slice}.pdb -o MSD/msd_${slice}_build.pdb  -n trim_${slice}.ndx
		echo ${TIMES[i]}_${slice} > MSD/msd_${slice}_data_full50.xvg 
		grep -v "#\|@" MSD/msd_${slice}_full50.xvg | awk '{print $2}' >> MSD/msd_${slice}_data_full50.xvg
		#done
	done
done

SLICE=(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23)
for k in `seq 0 23`; do
	slice1=`echo "scale=4; ${SLICE[k]} * 0.5 - 5.5" | bc`
        slice2=`echo "scale=4;${slice1} - 0.5" | bc`
        slice=`echo "scale=4;${slice1} - 0.25" | bc`
	paste -d "," NVE_*/MSD/msd_${slice}_data_full50.xvg > ${slice}_full50.xvg
done
