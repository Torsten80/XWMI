#!/bin/sh

# 05.01.2022/TF
#
# check eventlogs
#
#

export PYTHONIOENCODING=utf8
# export LANG="en_US.UTF-8"

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

MYSTATE=$STATE_OK
MYCOUNT=0

CRIT=0
WARN=0


MYTYPE="and (type= \"Error\" or type= \"Warning\" or type= \"Fehler\")";
while getopts H:b:n:e:o:m:l:c:s:t:v:w:x:C:i:p:help:h option;
do
        case $option in
                H) hostname=$OPTARG;;
                m) MODE="-v";;
                l) MYLOGFILE=$OPTARG;;
                e) MYEVENT=$(echo "$OPTARG"  | sed 's/,/\\\|/g') ;; 
                t) MYTEXT=$OPTARG;;
                s) MYTYPE="and Type = \"$OPTARG\"";;
                x) MYEXTRAEVENT="and eventcode  = \"$OPTARG\"";;
                o) MYHOURS=$OPTARG;;
                w) WARN=$OPTARG;;
                c) CRIT=$OPTARG;;
                h) help=1;;
        esac
done


if  [ $help ] ; then
 echo "
 Usage: check_Xwmi_processCPU.sh -H Hostname  -l eventlog [-s eventtype] -o hoursback [-w warning -c critical]  [-e eventids]  [-x eventid] [-t searchtext]


####List of Available Parameters
-H Hostname
-w (optional) set the warning parameter
-c (optional) set the critical parameter
-l Eventlog name
-e eventids (comma separeted without blanks) (optional)
-x eventid (optional)
-t searchtext (optional)
-h Print this help screen
-m mode vor inverse search  (optional)
-s eventtype  (optional)

 if you searching one eventid add -x option with -e option for performaces reasons
 
 examples:
 check_Xwmi_events.sh -H sqlhost  -l "application"  -o 10 -w 0 -c 1  -e "18456"
 check_Xwmi_events.sh -H evaulthost  -l "Veritas Enterprise Vault"  -o 11 -w 0 -c 1  -e "41352"  -x "41352" 
 check_Xwmi_events.sh -H host -l "System"  -o 1 -w 0 -c 1  -t "eventvm"
 check_Xwmi_events.sh -H sqlhost  -l "application"  -o 3 -w 0 -c 1 -s "Audit Failure"   -e "18456"  
 "
 exit 
fi


mydir=$(dirname "$0")


MYDATE=$(date -u +"%Y%m%d%H%M%S.000000-000"  -d "-$MYHOURS hour")

  echo "Select * from Win32_NTLogEvent Where Logfile = \"$MYLOGFILE\" and  TimeGenerated> \"$MYDATE\" $MYTYPE $MYEXTRAEVENT" > /usr/local/nagios/libexec/wmiquery/tmp/events."$hostname"
  myquery="tmp/events.$hostname"



MYTEMP1=$("$mydir"/wmiquery.sh "$hostname" "$myquery" | tail -n +5)

MYMESSAGE=""
MYCOUNT=0
   MYT="0"
   MYT1="0"


IFS=$'\n'
arr2=$MYTEMP1
for x in $arr2
do
 a=($(echo "$x" | tr '|' '\n'))

if [ "$MYTEXT" ] ; then
 MYT=$(echo "${a[11]} ${a[12]} ${a[13]}" | grep -c $MODE "$MYTEXT")
fi

if [[ "$MYEVENT" && "${a[3]}" -gt "0" ]] ; then
 MYT1=$(echo "${a[3]}" | grep -c $MODE "$MYEVENT")
fi 


 if  [[ "$MYT" -gt "0" || $MYT1  -ne "0" ]] ; then
  MYCOUNT=$((MYCOUNT+1))
  y=($(echo "$x" | tr '|' ','))
  MYMESSAGE="$MYMESSAGE  $y \n"
  MYT1="0" 
  MYT="0"
 fi  
done 


if  [[ "$MYCOUNT" -gt "$WARN" ]] ; then
   MYSTATE=$STATE_WARNING
fi


if  [[ "$MYCOUNT" -gt "$CRIT" ]] ; then
   MYSTATE=$STATE_CRITICAL
fi

 MYTEMP1=($(echo "$MYTEMP1" | tr '|' ','))

echo "Events: $MYCOUNT  $MYMESSAGE <br> "
exit $MYSTATE



