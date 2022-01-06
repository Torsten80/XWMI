#!/bin/sh

# 28.12.2021/TF
#
# process cpu check
#
#



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

while getopts H:b:n:e:o:m:l:c:s:t:v:w:C:i:p:help:h option;
do
        case $option in
                H) hostname=$OPTARG;;
                p) MYPROCESS=$OPTARG;;
                w) WARN=$OPTARG;;
                c) CRIT=$OPTARG;;
                h) help=1;;
        esac
done


if  [ $help ] ; then
 echo "
# checks Process CPUUsage
Usage: check_Xwmi_processCPU.sh -H Hostname -p processname [-w 50] [-c 80]


####List of Available Parameters
-H Hostname 
-w (optional) set the warning parameter 
-c (optional) set the critical parameter 
-h Print this help screen
-p processname to check

examples:
check_Xwmi_processCPU.sh -H 177.29.1.16  -p OWSTIMER  -w 50 -c 90  

"


 exit
fi




mydir=$(dirname "$0")



LCPUCOUNT=`$mydir/wmiquery.sh $hostname cpulcount.qry | sed 's/|//g' | sed 's/ //g'| tail -n 1 `



echo "Select PercentProcessorTime  FROM win32_PerfFormattedData_PerfProc_Process  Where name = \"$MYPROCESS\"  " > /usr/local/nagios/libexec/wmiquery/tmp/processCPU."$MYPROCESS.$hostname"
myquery="tmp/processCPU.$MYPROCESS.$hostname"



MYTEMP1=$("$mydir"/wmiquery.sh "$hostname" "$myquery" | tail -n +5 )


MYCOUNT=0

CPUUsage=0

IFS=$'\n'
arr2=$MYTEMP1
for x in $arr2
do
 a=($(echo "$x" | tr '|' '\n'))
 MYCOUNT=$((MYCOUNT+1))
 CPUUsage=$((CPUUsage+${a[0]}))

done


CPUUsage=$(( $CPUUsage / $LCPUCOUNT ))


if  [[ "$CPUUsage" -gt "$WARN" ]] ; then
   MYSTATE=$STATE_WARNING
   MYSTATE1="Warning:"
fi


if  [[ "$CPUUsage" -gt "$CRIT" ]] ; then
   MYSTATE=$STATE_CRITICAL
   MYSTATE1="Critical:"
fi

if  [[ "$MYCOUNT" -lt "1" ]] ; then
   MYSTATE=$STATE_CRITICAL
   MYSTATE1="Critical:"
fi


echo "$MYSTATE1 CPUUsage=$CPUUsage% Total Process Count=$MYCOUNT (LCPUCOUNT=$LCPUCOUNT) |'Process Count'=$MYCOUNT; 'CPUUsage'=$CPUUsage %;"

exit $MYSTATE

