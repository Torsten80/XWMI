#! /bin/sh
# 09.01.2022/TF
#
# Wrapper for WMI new
# see # https://github.com/SecureAuthCorp/impacket/blob/master/examples/wmiquery.py
#
# your credentials , we are using https://github.com/plyint/encpass.sh

mydir=$(dirname "$0")
. /usr/local/bin/encpass.sh
pw=$(get_secret)
## this is only if you modified wmiquery.py with password = os.environ['wmipw'] (near line 192)
export wmipw
wmiquery.py domain/user:"dummypw"@"$1"  -rpc-auth-level privacy  -f "$mydir"/wmiquery/"$2"
