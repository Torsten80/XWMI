#/bin/sh

# 10.12.2021/TF
#
# check server time compared to local time
#
# Uebergabeparameter:
# $1: host $2: warning $3 critical 
#
#


STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

STATE=$STATE_OK

CRIT=5
WARN=15

if  [[ $2 ]] ; then
 WARN=$2
fi
if  [[ $3 ]] ; then
 CRIT=$3
fi


mydir=`dirname $0`



MYTEMP1=`$mydir/wmiquery.sh $1 time.qry | grep -v "None"  | tail -n +5`
#echo "$MYTEMP1"

LTIME=`date -u +"%Y%m%d%H%M%S"`
#echo "$LTIME"

a=($(echo "$MYTEMP1" | tr '|' '\n'))
 MYDAY=${a[0]} 
 MYHOUR=${a[1]}
 MYMINUTE=${a[2]}
 MYMONTH=${a[3]}
 MYSECOND=${a[4]}
 MYYEAR=${a[5]}
 
MYDAYL=${#MYDAY}
MYHOURL=${#MYHOUR}
MYMINUTEL=${#MYMINUTE}
MYMONTHL=${#MYMONTH}
MYSECONDL=${#MYSECOND}

 if  [[ MYDAYL -eq 1 ]] ; then   MYDAY="0"$MYDAY  
 fi
 if  [[ MYHOURL -eq 1 ]] ; then   MYHOUR="0"$MYHOUR  
 fi
 if  [[ MYMINUTEL -eq 1 ]] ; then   MYMINUTE="0"$MYMINUTE  
 fi
 if  [[ MYMONTHL -eq 1 ]] ; then   MYMONTH="0"$MYMONTH  
 fi
 if  [[ MYSECONDL -eq 1 ]] ; then   MYSECOND="0"$MYSECOND  
 fi



STIME=$MYYEAR$MYMONTH$MYDAY$MYHOUR$MYMINUTE$MYSECOND

# echo "$MYYEAR $MYMONTH $MYDAY $MYHOUR $MYMINUTE $MYSECOND----"

#echo "$STIME"

TDIFF=$(( $LTIME - $STIME ))



  if  [[ $TDIFF -gt $WARN ]] ; then
   STATE=STATE_WARNING
  fi


  if  [[ $TDIFF -gt $CRIT ]] ; then
   STATE=$STATE_CRITICAL
  fi



echo "Timediff is: $TDIFF s|'Timediff sec'=$TDIFF;$WARN;$CRIT;"
exit $STATE



