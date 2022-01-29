#! /bin/sh
# 28.12.2021/Faehrmann
#
# Wrapper für WMI neu
#
# your credentials
#
# 20220118: path to qry changed
#


. /usr/local/bin/encpass.sh
wmipw=$(get_secret)
export wmipw
## this is only if you modified wmiquery.py with password = os.environ['wmipw'] (near line 192)
wmiquery.py domain/user:"dummypw"@"$1"  -rpc-auth-level privacy  -f "$2"
