#!/bin/sh

# 29.12.2021/TF
#
# check Disk IO
#
#
# 20.01.2022 For performance reasons, the query is only written to the temp folder the first time.
# If you want to change it you have to call the script once (or always) with the parameter -r 1 for reset.
# wmiquery1.sh is used


STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

MYSTATE=$STATE_OK
MYSTATE1="OK:"
MYCOUNT=0

CRIT=80
WARN=50

while getopts H:b:n:e:o:m:l:c:s:t:v:w:C:i:p:r:help:h option;
do
        case $option in
                H) hostname=$OPTARG;;
                p) MYPOOL=$OPTARG;;
                t) MYTEST=$(echo "$OPTARG"  | sed 's/,/\\\|/g') ;;
                w) WARN=$OPTARG;;
                c) CRIT=$OPTARG;;
                r) RESET=$OPTARG;;
                h) help=1;;
        esac
done


if  [ $help ] ; then
 echo "
# checks Process CPUUsage
Usage: check_Xwmi_PhysicalDisk.sh -H Hostname -p processname [-w 50] [-c 80]


####List of Available Parameters
-H Hostname 
only first fit will evaluated 
-w (optional) set the warning parameter,  if 0 warning and  critical will ingnored
-c (optional) set the critical parameter 
-h Print this help screen
-p drive to check
-t performance counter
-r reset (delete qry file and create a new file)


examples:
 check_Xwmi_PhysicalDisk.sh -H host  -p "W:" -t "PercentIdleTime,AvgDisksecPerRead,AvgDisksecPerWrite,DiskWritesPersec,AvgDiskWriteQueueLength" -w 200 -c 500
"



 exit
fi



mydir=$(dirname "$0")




myquery="$mydir/wmiquery/tmp/PhysicalDiskDisk"."$MYPOOL.$hostname"

if [ $RESET ]; then
    rm $myquery
fi


if [ ! -f "$myquery" ]; then
   echo "SELECT * FROM Win32_PerfFormattedData_PerfDisk_PhysicalDisk where name like \"%$MYPOOL%\"  "   > $myquery
fi







MYTEMP1=$("$mydir"/wmiquery1.sh "$hostname" "$myquery" | tail -n +4)



MYVALUES=`echo "$MYTEMP1" | tail -n 1`
MYHEAD=`echo "$MYTEMP1" |  head -n 1`

 MYHEAD=${MYHEAD// /}
 MYVALUES=${MYVALUES// /}



b=($(echo "$MYVALUES" | tr '|' '\n'))

MYCOUNT=0
MYCOUNT1=0
MYSTATE1="OK"



a=($(echo "$MYHEAD" | tr '|' '\n'))


for x in  "${a[@]}"
do
 MYT1=$(echo "${a[$MYCOUNT]}" | grep -c $MODE "$MYTEST")
 if  [[ "$MYT1" -eq "1" ]] ; then
 

   if [[ "$MYCOUNT1" -eq "1" && "$WARN" -ne "0"  ]] ; then

      if  [[ "${b[$MYCOUNT]}" -gt "$WARN" ]] ; then
   	MYSTATE=$STATE_WARNING
	MYSTATE1="Warning:"
      fi


     if  [[ "${b[$MYCOUNT]}" -gt "$CRIT" ]] ; then
   	MYSTATE=$STATE_CRITICAL
   	MYSTATE1="Critical:"
     fi

    E1+="${a[$MYCOUNT]}=${b[$MYCOUNT]}, "
    E2+="'${a[$MYCOUNT]}'=${b[$MYCOUNT]};$WARN;$CRIT; "
   else
    E1+="${a[$MYCOUNT]}=${b[$MYCOUNT]}, "
    E2+="'${a[$MYCOUNT]}'=${b[$MYCOUNT]}; "
   fi


 fi
 MYCOUNT=$((MYCOUNT+1))
 
done


echo "$MYSTATE1 - $E1 |$E2"
exit $MYSTATE


