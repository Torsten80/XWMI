#!/bin/sh

# 29.12.2021/TF
#
# NW Interface check
#
# # 30.08.2023 fix blank in devicename



STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

MYSTATE=$STATE_OK
MYSTATE1="OK:"

mymb=$(( 1024*1024 ))
mygb=$(( 1024*1024*1024 ))


CRIT=800
WARN=500

while getopts H:b:n:e:o:m:l:c:s:t:v:w:C:i:p:help:h option;
do
        case $option in
                H) hostname=$OPTARG;;
                p) MYPOOL=$OPTARG;;
                t) MYTEST=$(echo "$OPTARG"  | sed 's/,/\\\|/g') ;;
                w) WARN=$OPTARG;;
                c) CRIT=$OPTARG;;
                h) help=1;;
        esac
done


if  [ $help ] ; then
 echo "
# checks Process CPUUsage
Usage: check_Xwmi_Network.sh -H Hostname -p Interface -t Counter [-w 50] [-c 80]


####List of Available Parameters
-H Hostname 
only first fit will evaluated 
-w (optional) set the warning parameter,  if 0 warning and  critical will ingnored
-c (optional) set the critical parameter 
-h Print this help screen
-p interface 
-t counter to check (without blanks!!!)


examples:
check_Xwmi_Network.sh -H host  -p "public" -t "BytesReceivedPersec,BytesSentPersec,OutputQueueLength" -w 0
"

 exit
fi


mydir=$(dirname "$0")


echo "SELECT * FROM Win32_PerfRawData_Tcpip_NetworkAdapter where name like \"%$MYPOOL%\"  " > "$mydir"/wmiquery/tmp/NetworkAdapter."$MYPOOL.$hostname"
myquery="tmp/NetworkAdapter"."$MYPOOL.$hostname"


MYTEMP1=$("$mydir"/wmiquery.sh "$hostname" "$myquery" | tail -n +4)


MYVALUES=`echo "$MYTEMP1" | tail -n 1`
MYHEAD=`echo "$MYTEMP1" |  head -n 1`

MYVALUES=($(echo -n "${MYVALUES//[[:space:]]/}"))   
b=($(echo "$MYVALUES" | tr '|' '\n'))

MYCOUNT=0
MYCOUNT1=0
MYSTATE1="OK"


a=($(echo "$MYHEAD" | tr '|' '\n'))

for x in  "${a[@]}"
do
 MYT1=$(echo "${a[$MYCOUNT]}" | grep -c "Timestamp_Sys100NS")
 MYT2=$(echo "${a[$MYCOUNT]}" | grep -c "Frequency_Sys100NS")
 
  if  [[ "$MYT1" -eq "1" ]] ; then
   mynow=${b[$MYCOUNT]} 
  fi

  if  [[ "$MYT2" -eq "1" ]] ; then
   Frequency_Sys100NS=${b[$MYCOUNT]} 
  fi
  MYCOUNT=$((MYCOUNT+1))
done


MYCOUNT=0

for x in  "${a[@]}"
do
 MYT1=$(echo "${a[$MYCOUNT]}" | grep -c "$MYTEST")
 if  [[ "$MYT1" -eq "1" ]] ; then
 
   
   if [ ! -f "$mydir"/wmiquery/tmp/NetworkAdapter."${a[$MYCOUNT]}.$MYPOOL.$hostname" ]; then
    echo "create first sample $mydir/wmiquery/tmp/NetworkAdapter.${a[$MYCOUNT]}.$MYPOOL.$hostname"
    echo "value=${b[$MYCOUNT]}  stime=$mynow" > "$mydir"/wmiquery/tmp/NetworkAdapter."${a[$MYCOUNT]}.$MYPOOL.$hostname"
    exit
   fi
    
.  "$mydir"/wmiquery/tmp/NetworkAdapter."${a[$MYCOUNT]}.$MYPOOL.$hostname"

   mytdiff=$(( mynow - stime ))
   nvalue=${b[$MYCOUNT]}
   MYVALUE=`echo "scale=0;(($nvalue-$value)/($mytdiff/$Frequency_Sys100NS))" | bc`
   
  T2=$(echo "${a[$MYCOUNT]}" | grep -c "Bytes")
  if  [[ "$T2" -gt "0" ]] ; then
    MYVALUE1=`echo "scale=2; $MYVALUE / $mymb" | bc`
    else
    MYVALUE1=$MYVALUE
  fi

   MYCOUNT1=$((MYCOUNT1+1))
   if [[ "$MYCOUNT1" -eq "1" && "$WARN" -ne "0"  ]] ; then

      if  [[ "$MYVALUE" -gt "$WARN" ]] ; then
   	MYSTATE=$STATE_WARNING
	MYSTATE1="Warning:"
      fi


     if  [[ "$MYVALUE" -gt "$CRIT" ]] ; then
   	MYSTATE=$STATE_CRITICAL
   	MYSTATE1="Critical:"
     fi


    E1+="${a[$MYCOUNT]}=$MYVALUE1, "
    E2+="'${a[$MYCOUNT]}'=$MYVALUE;$WARN;$CRIT; "
   else
    E1+="${a[$MYCOUNT]}=$MYVALUE1, "
    E2+="'${a[$MYCOUNT]}'=$MYVALUE; "
   fi

   echo "value=${b[$MYCOUNT]}  stime=$mynow" > "$mydir"/wmiquery/tmp/NetworkAdapter."${a[$MYCOUNT]}.$MYPOOL.$hostname"

fi

 MYCOUNT=$((MYCOUNT+1))
 
done


echo "$MYSTATE1 - $E1 |$E2"
exit $MYSTATE


