#!/bin/bash
#Running NVE sims

#
#
#
#
#
# DEPRECATED. USE NVE_all_v2.sh
#
#
#
#
#
#


GMX5=/usr/local/gromacs_5/bin
CURRENT_DIR=`pwd`

cd ${CURRENT_DIR}
TIMES=(500 502 504 506 508 510 600 602 604 606 608 610 700 702 704 706 708 710 800 802 804 806 808 810 900 902 904 906 908 910 1000)

function resize {
echo q | make_ndx -f Input.gro -o index.ndx
$GMX5/grompp -f em.mdp -c Input.gro -p TOP.top -o in.tpr
$GMX5/g_select -f Input.gro -s in.tpr -sf ../selection1.dat -on trim -selrpos whole_res_com -rmpbc
cat index.ndx trim.ndx > newtrim.ndx
group=`grep -c "\[" newtrim.ndx`
groups=`echo ${group} - 1 | bc`
echo $groups | editconf -f Input.gro -n newtrim.ndx -o trim.gro -bt triclinic
cp TOP.top Trim1.top 
sed '/POP/d' Trim1.top -i; sed '/SOL/d' Trim1.top -i; sed '/NA/d' Trim1.top -i; sed '/CL/d' Trim1.top -i;
echo "POP `grep -c P8 trim.gro`" >> Trim1.top
echo "SOL `grep -c OW trim.gro`" >> Trim1.top
echo "NA `grep -c NA trim.gro`" >> Trim1.top
echo "CL `grep -c CL trim.gro`" >> Trim1.top
$GMX5/grompp -f em.mdp -p Trim1.top -c trim.gro -o trim.tpr
### and again
$GMX5/g_select -f trim.gro -s trim.tpr -sf ../selection2.dat -on trim2 -selrpos whole_res_com -rmpbc
cat  trim.ndx trim2.ndx > newtrim2.ndx
group=`grep -c "\[" newtrim2.ndx`
groups=`echo ${group} - 1 | bc`
echo $groups |editconf -f trim.gro -n newtrim2.ndx -o trim2.gro -bt triclinic
cp Trim1.top Trim2.top
sed '/POP/d' Trim2.top -i; sed '/SOL/d' Trim2.top -i; sed '/NA/d' Trim2.top -i; sed '/CL/d' Trim2.top -i;
echo "POP `grep -c P8 trim2.gro`" >> Trim2.top
echo "SOL `grep -c OW trim2.gro`" >> Trim2.top
echo "NA `grep -c NA trim2.gro`" >> Trim2.top
echo "CL `grep -c CL trim2.gro`" >> Trim2.top
$GMX5/grompp -f em.mdp -p Trim2.top -c trim2.gro -o trim2.tpr
editconf -f trim2.gro -o trim2.pdb
}

TL=${#TIMES[@]}
rm failedNVE.txt
echo "failed NVE" > failedNVE.txt

for i in `seq 0 $TL`; do
	cd ${CURRENT_DIR}
	if [[ ! -d NVE_${TIMES[i]} ]]; then
		mkdir NVE_${TIMES[i]}
	fi
	cd NVE_${TIMES[i]}
	if [[ -f NVE_${TIMES[i]}.gro ]]; then
                echo done
	else
	rm NVE_${TIMES[i]}.tpr
	cp /home/birac/Desktop/Archer_Tom_subs/Results/ATP/ATP.${TIMES[i]}0.gro Input.gro
        cp /home/birac/Desktop/Subs_model_Tom/setup/ATP/atp.top TOP.top
	cp /home/birac/Desktop/Subs_model_Tom/setup/ATP/*itp .
	cp ~/Desktop/MD_KIT/em.mdp .
	### Resize here!
	resize
	### Done
	$GMX5/grompp -f ../NVE_waters.mdp -c trim2.gro -p Trim2.top -o NVE_${TIMES[i]}.tpr >& grompp_${TIMES[i]}_out
        $GMX5/mdrun -v -deffnm NVE_${TIMES[i]}
        #echo System | $GMX5/trjconv -f NVE_${TIMES[i]}.trr -o NVE_${TIMES[i]}.pbc.trr -pbc mol -s NVE_${TIMES[i]}.tpr
        rm NVE_${TIMES[i]}.energy.xvg
        echo -e Total-Energy '\n' 0 | $GMX5/g_energy -f NVE_${TIMES[i]}.edr -o NVE_${TIMES[i]}.energy.xvg
        if [[ ! -f NVE_${TIMES[i]}.tpr ]]; then
                echo NVE_${TIMES[i]}.tpr failed >> ../failedNVE.txt
        fi
	fi
done
