#!/bin/sh

# 28.12.2021/TF
#
# process check
#



STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

MYSTATE=$STATE_OK
MYSTATE1="OK:"
MYCOUNT=0

CRIT=500
WARN=200

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

# checks Process Memory 
Usage: check_Xwmi_process.sh -H Hostname -p processname [-w 50] [-c 80]


####List of Available Parameters
-H Hostname
-w (optional) set the warning parameter (MB)
-c (optional) set the critical parameter (MB)
-h Print this help screen
-p processname to check

examples:
check_Xwmi_process.sh -H 177.29.1.15  -p owstimer.exe  -w 1000 -c 2000  

"
 exit
fi



mydir=$(dirname "$0")

echo "Select WorkingSetSize,PrivatePageCount,VirtualSize from Win32_process Where name = \"$MYPROCESS\"  " > /usr/local/nagios/libexec/wmiquery/tmp/process."$MYPROCESS.$hostname"
myquery="tmp/process.$MYPROCESS.$hostname"



MYTEMP1=$("$mydir"/wmiquery.sh "$hostname" "$myquery" | tail -n +5)


mygb=$(( 1024*1024 ))


MYCOUNT=0

WorkingSetSize=0
PrivatePageCount=0
VirtualSize=0


IFS=$'\n'
arr2=$MYTEMP1
for x in $arr2
do
 a=($(echo "$x" | tr '|' '\n'))
 MYCOUNT=$((MYCOUNT+1))
 WorkingSetSize=$((WorkingSetSize+${a[2]}))
 PrivatePageCount=$((PrivatePageCount+${a[0]}))
 VirtualSize=$((VirtualSize+${a[1]}))


done 

if  [ $WorkingSetSize ] ; then
  WorkingSetSize1=$(( $WorkingSetSize / $mygb ))
  PrivatePageCount1=$(( $PrivatePageCount / $mygb ))
  VirtualSize1=$(( $VirtualSize / $mygb ))
fi



if  [[ "$WorkingSetSize1" -gt "$WARN" ]] ; then
   MYSTATE=$STATE_WARNING
   MYSTATE1="Warning:"
fi


if  [[ "$WorkingSetSize1" -gt "$CRIT" ]] ; then
   MYSTATE=$STATE_CRITICAL
   MYSTATE1="Critical:"
fi

if  [[ "$MYCOUNT" -lt "1" ]] ; then
   MYSTATE=$STATE_CRITICAL
   MYSTATE1="Critical:"
fi

echo "$MYSTATE1 Total Process Count=$MYCOUNT WorkingSetSize=$WorkingSetSize1 MB, PrivatePageCount=$PrivatePageCount1 MB, VirtualSize=$VirtualSize1 MB |'Process Count'=$MYCOUNT; 'WorkingSetSize'=$WorkingSetSize Bytes; 'PrivatePageCount'=$PrivatePageCount Bytes; 'VirtualSize'=$VirtualSize Bytes;"

exit $MYSTATE



