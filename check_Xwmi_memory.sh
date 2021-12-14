#/bin/sh

# 26.11.2021/TF
#
# check free memory
#
# Uebergabeparameter:
# $1: host  $2:WARN  $3:CRIT
#


STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

CRIT=5
WARN=10

if  [[ $2 ]] ; then
 WARN=$2
fi
if  [[ $3 ]] ; then
 CRIT=$3
fi




mydir=`dirname $0`


MYTEMP1=`$mydir/wmiquery.sh $1 memory.qry | sed 's/ //g'| tail -n 1 `

if  [[ ! $MYTEMP1 ]] ; then
   echo "UNKNOWN:! $MYTEMP got no value"
   exit $STATE_UNKNOWN
fi



a=($(echo "$MYTEMP1" | tr '|' '\n'))
FreePhysicalMemory=${a[0]} 
FreeVirtualMemory=${a[1]}
TotalVirtualMemorySize=${a[2]}
TotalVisibleMemorySize=${a[3]}
mygb=$(( 1024*1024 ))


usedPhysicalMemory=$(( $TotalVisibleMemorySize - $FreePhysicalMemory ))

PercentFree=$(( $FreePhysicalMemory*100 / $TotalVisibleMemorySize ))

SwapSize=$(( $TotalVirtualMemorySize - $TotalVisibleMemorySize ))
SwapSize=$(( $SwapSize  / $mygb ))



## now in GB
TotalVisibleMemorySize=$(( $TotalVisibleMemorySize / $mygb ))
TotalVirtualMemorySize=$(( $TotalVirtualMemorySize / $mygb ))
FreeVirtualMemory=$(( $FreeVirtualMemory / $mygb ))
FreePhysicalMemory=$(( $FreePhysicalMemory / $mygb ))






#echo "OK - PercentFree=$PercentFree% FreePhysicalMemory=$FreePhysicalMemory  FreeVirtualMemory=$FreeVirtualMemory  TotalVirtualMemorySize=$TotalVirtualMemorySize  TotalVisibleMemorySize=$TotalVisibleMemorySize Swapsize=$SwapSize |'Physical Memory Used'=$usedPhysicalMemory Bytes; 'Physical Memory Free'=$PercentFree%;$WARN;$CRIT;"



if  [[ $PercentFree -lt $CRIT ]] ; then
   echo "Critical:! PercentFree=$PercentFree% FreePhysicalMemory=$FreePhysicalMemory GB,  FreeVirtualMemory=$FreeVirtualMemory GB,  TotalVirtualMemorySize=$TotalVirtualMemorySize GB,  TotalVisibleMemorySize=$TotalVisibleMemorySize GB, Swapsize=$SwapSize GB |'Physical Memory Used'=$usedPhysicalMemory Bytes; 'Physical Memory Free'=$PercentFree%;$WARN;$CRIT;" 
   exit $STATE_CRITICAL
fi
      
if  [[ $PercentFree -lt $WARN ]] ; then
   echo "Warning! PercentFree=$PercentFree% FreePhysicalMemory=$FreePhysicalMemory GB, FreeVirtualMemory=$FreeVirtualMemory GB, TotalVirtualMemorySize=$TotalVirtualMemorySize GB, TotalVisibleMemorySize=$TotalVisibleMemorySize GB, Swapsize=$SwapSize GB |'Physical Memory Used'=$usedPhysicalMemory Bytes; 'Physical Memory Free'=$PercentFree%;$WARN;$CRIT;" 
   exit $STATE_WARNING
fi
      
      

echo "OK - PercentFree=$PercentFree% FreePhysicalMemory=$FreePhysicalMemory GB, FreeVirtualMemory=$FreeVirtualMemory GB, TotalVirtualMemorySize=$TotalVirtualMemorySize GB, TotalVisibleMemorySize=$TotalVisibleMemorySize GB, Swapsize=$SwapSize GB |'Physical Memory Used'=$usedPhysicalMemory Bytes; 'Physical Memory Free'=$PercentFree%;$WARN;$CRIT;"

exit $STATE_OK
