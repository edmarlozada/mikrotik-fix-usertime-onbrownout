# mikrotik-fix-usertime-onbrownout v10.0
Mikrotik Script to Fix Users-Limit-Uptime on Brownout.
Handle Active Users Limit-Uptime on Power Interruption.

eUpTimeBackup: (interval)
- ip hotspot active user
- ip hotspot user uptime
- ip hotspot active uptime
- ip hotspot user limit-uptime

Saved Data Location:
- system script name="hs-SavedUptime" source

eUpTimeUpdate:
- NewLimitUptime = (User-Limit-Uptime) - (Save-Active-Uptime)
- ip hotspot user limit-uptime=$NewLimitUptime

How to install:
- Open file "mts-fix-usertime-onbrownout_v10.rsc".
- select all, copy, & paste to winbox terminal

Author:
- Chloe Renae & Edmar Lozada
- Gcash (0909-3887889)

Facebook Contact:
- https://www.facebook.com/chloe.renae.9

Facebook JuanFi Group:
- https://www.facebook.com/groups/1172413279934139
