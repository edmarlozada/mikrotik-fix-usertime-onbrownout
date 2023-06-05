# mikrotik-fix-usertime-onbrownout
Mikrotik Script to Fix Users-Limit-Uptime on Brownout v10.0
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

Howto Install:
- select all, copy, & paste to winbox terminal

Author:
- Chloe Renae & Edmar Lozada
- Gcash (0909-3887889)

Facebook Contact:
- https://www.facebook.com/chloe.renae.9
