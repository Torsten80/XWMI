#! /bin/sh
# 28.12.2021/Faehrmann
#
# Wrapper for WMI new
# see # https://github.com/SecureAuthCorp/impacket/blob/master/examples/wmiquery.py
#
# your credentials , we are using https://github.com/plyint/encpass.sh

mydir=$(dirname "$0")
. /usr/local/bin/encpass.sh
pw=$(get_secret)

wmiquery.py mydomain/wmiuser:"$pw"@"$1"  -rpc-auth-level privacy  -f "$mydir"/wmiquery/"$2"
