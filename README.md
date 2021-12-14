# XWMI-
replacement for check_wmi_plus 

(because of MS november-2021-patchday)
(see: https://edcint.co.nz/checkwmiplus/forums/topic/wmic-rpc_c_authn_level_pkt_integrity/)
only possible through https://github.com/SecureAuthCorp/impacket/blob/master/examples/wmiquery.py,

Aim is to keep it as simple as possible and stay flexible.
Therefore a simple wrapper and for each check an extra bash script.

Wrapper calls wmiquery.py Password is read out via https://github.com/plyint/encpass.sh set (of course everything local)
