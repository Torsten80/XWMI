#!/bin/sh

# 22.12.2021/TF
#
# service check
#
# parameter:
# $1: host $2: mode (normal or auto) $3 service(s) $4 warn  $5 critical 
# if auto $ exclude services
# don't use normal with more than one service! performance issue!
#
# examples:  /usr/local/nagios/libexec/check_Xwmi_service.sh 111.22.100.42 normal spool 
 #           /usr/local/nagios/libexec/check_Xwmi_service.sh 111.22.100.42 auto snow,win,RemoteRegistry
#


STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

MYSTATE=$STATE_OK
MYCOUNT=0
MYlocated=0
MYRESULT=""

CRIT=0
WARN=0

MYOPT=""
# auto oder normal, wenn nicht auto dann normal
MODE=$2
 if [ "$MODE" = "auto" ] ; then
  MYOPT="-v"
 fi




EXIN=$(echo "$3"  | sed 's/,/\\\|/g')

if  [ "$4" ] ; then
 WARN=$4
fi

if  [ "$5" ] ; then
 CRIT=$5
fi


mydir=$(dirname "$0")



myquery="service.qry"

if  [ "$MODE" = "normal" ] ; then
  echo "Select Name,DisplayName, state,startmode ,status From Win32_Service where name like \"%$3%\"" > /usr/local/nagios/libexec/wmiquery/tmp/servicetest."$1$3"
  myquery="tmp/servicetest.$1$3"
fi



EXINCOUNT=$(echo "$EXIN"  | grep -c '|')

if  [[ "$MODE" = "normal" && "$EXINCOUNT" = "1" ]] ; then
  myquery="service.qry"
fi


if  [ "$MODE" = "auto" ] ; then
 myquery="serviceauto.qry"
fi


MYTEMP1=$("$mydir"/wmiquery.sh "$1" "$myquery" | tail -n +4)


IFS=$'\n'
arr2=$MYTEMP1
for x in $arr2
do
 a=($(echo "$x" | tr '|' '\n'))
 MYNAME=${a[0]}
 MYDisplayName=${a[1]}
 MYstate=${a[3]}
 MYstartmode=${a[2]}
# MYstatus=${a[4]}
 
 MY1=$(echo "$MYDisplayName" | grep -i $MYOPT -c "$EXIN")


 if [ "$MY1" == "1" ] ; then
  MYlocated=$((MYlocated +1))
 fi


 if [[ "$MY1" == "1" &&  "$MYstate" != " Running " ]] ; then
  if  [ "$MYOPT"  == "-v" ] ; then
   if  [ "$MYstartmode" == " Auto " ] ; then
    MYCOUNT=$((MYCOUNT+1))
    MYRESULT+="$MYDisplayName($MYNAME), "
   fi
  else
    MYCOUNT=$((MYCOUNT+1))
   MYRESULT+="$MYDisplayName($MYNAME), "
  fi 
 fi
 
done


if  [[ "$MYCOUNT" -gt "$WARN" ]] ; then
   MYSTATE=$STATE_WARNING
fi

if  [[ "$MYCOUNT" -gt "$CRIT" ]] ; then
   MYSTATE=$STATE_CRITICAL
fi


if [ "$MYRESULT" ] ; then
   MYRESULT="not running: "$MYRESULT
 else
  MYRESULT="all running"
fi
 


echo "$MYlocated services located $MYCOUNT with problems  $MYRESULT"
exit $MYSTATE



