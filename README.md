# XWMI
replacement for check_wmi_plus 

(because of MS november-2021-patchday)
(see: https://edcint.co.nz/checkwmiplus/forums/topic/wmic-rpc_c_authn_level_pkt_integrity/)
only possible through https://github.com/SecureAuthCorp/impacket/blob/master/examples/wmiquery.py,

Aim is to keep it as simple as possible and stay flexible.
Therefore a simple wrapper and for each check an extra bash script.

Wrapper calls wmiquery.py Password is read out via https://github.com/plyint/encpass.sh set (of course everything local)

**** New are passive checks to reduce the load for the monitoring server. *********
Single checks with wmiquery1.sh or wmiquery.sh sometimes take quite a long time.
The idea is similar to check_mk to perform only one check that returns various values.
Here system1.qry is executed with several basic wql queries. 
You save some connections. 
For this only check_Xwmi_system3.sh is executed.
