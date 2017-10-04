#!/bin/bash

#CD=/run/media/birac/Romulus/SecY_water
CD=/run/media/birac/Guildenstern/SecY_waters/TOM_ADP

TIMES=(500 502 504 506 508 510 600 602 604 606 608 610 700 702 704 706 708 710 800 802 804 806 808 810 900 902 904 906 908 910 1000)

TL=`echo "${#TIMES[@]} - 1" | bc`

SLICE=(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23)

function dipoles {
for j in `seq 0 23`; do
	slice1=`echo "scale=4; ${SLICE[j]} * 0.5 - 5.5" | bc`
	slice2=`echo "scale=4;${slice1} - 0.5" | bc`
	slice=`echo "scale=4;${slice1} - 0.25" | bc`
	if [[ ! -f SDAC/sdac_NVE_${TIMES[i]}_${slice}_dipcorr_proper.xvg ]]; then
		$GMX5/g_dipoles -f NVE_${TIMES[i]}.trr -s NVE_${TIMES[i]}.tpr -corr mol -P 3  -n trim_${slice} -nice -19 -a SDAC/sdac_NVE_${TIMES[i]}_${slice}_ave_proper.xvg -o SDAC/sdac_NVE_${TIMES[i]}_${slice}_tot_proper.xvg -c SDAC/sdac_NVE_${TIMES[i]}_${slice}_dipcorr_proper.xvg -temp 300  >& sdac_${slice}
	fi
done
}

for i in `seq 24 $TL`; do
        cd $CD
        cd NVE_${TIMES[i]}
	mkdir -p SDAC
	dipoles >& out
done
<<'END'
for i in `seq 0 $TL`; do
        cd ${CURRENT_DIR}
        cd NVE_${TIMES[i]}
        cd SDAC
for j in `seq 0 23`; do
        slice1=`echo "scale=4; ${SLICE[j]} * 0.5 - 5.5" | bc`
        slice2=`echo "scale=4;${slice1} - 0.5" | bc`
        slice=`echo "scale=4;${slice1} - 0.25" | bc`
        cp sdac_NVE_${TIMES[i]}_${slice}_dipcorr_proper.xvg ${j}_dipcorr.xvg
        sed 's/^    //g' "${j}_dipcorr.xvg" -i
        sed 's/^   //g' "${j}_dipcorr.xvg" -i
        sed 's/^  //g' "${j}_dipcorr.xvg" -i
        sed 's/^ //g' "${j}_dipcorr.xvg" -i
        sed 's/     / /g' "${j}_dipcorr.xvg" -i
        sed 's/    / /g' "${j}_dipcorr.xvg" -i
        sed 's/   / /g' "${j}_dipcorr.xvg" -i
        sed 's/  / /g' "${j}_dipcorr.xvg" -i
        sed 's/ /,/g' "${j}_dipcorr.xvg" -i
        sed '/\#/d' "${j}_dipcorr.xvg" -i
        sed '/\@/d' "${j}_dipcorr.xvg" -i
        sed '/\&/d' "${j}_dipcorr.xvg" -i
        awk -F , '{print $2}' ${j}_dipcorr.xvg > ${j}_dipcorr.data.xvg
done
done


for k in `seq 0 23`; do
        slice1=`echo "scale=4; ${SLICE[k]} * 0.5 - 5.5" | bc`
        slice2=`echo "scale=4;${slice1} - 0.5" | bc`
        slice=`echo "scale=4;${slice1} - 0.25" | bc`
        paste -d " " NVE_*/SDAC/${SLICE[k]}_dipcorr.data.xvg > all_${slice}_sdac.xvg
        echo $slice > ave_${slice}_sdac.xvg
        rm -f ave_${slice}_sdac.xvg
        while read j; do
                sum=0
                vals=0
                vals=`echo $j | awk '{print NF}'`
                for num in $j; do
                        sum=`echo "scale=5; $sum + $num " | bc`
                        ave=`echo "scale=10; $sum / $vals " | bc`
                 #       err=`echo $j | awk -vM=$ave '{
                 #                               for (i = 1; i <= NF; i++) {
                 #                                       sum+= (($i)-M) * (($i)-M) 
                 #                               };
                 #                               print sqrt (sum/NF)
                 #                               }'`
                done
                echo $ave >> ave_${slice}_sdac.xvg
        done < all_${slice}_sdac.xvg
        echo "${slice} done"
        paste -d "," /run/media/birac/Romulus/SecY_water/sdactime.xvg ave_${slice}_sdac.xvg > ave_${slice}_sdac_full.xvg
done

mv ave_-.75_sdac_full.xvg ave_-0.75_sdac_full.xvg
mv ave_-.25_sdac_full.xvg ave_-0.25_sdac_full.xvg
mv ave_.25_sdac_full.xvg  ave_0.25_sdac_full.xvg
mv ave_.75_sdac_full.xvg  ave_0.75_sdac_full.xvg
END
