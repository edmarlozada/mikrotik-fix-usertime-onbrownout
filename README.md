# mikrotik-fix-usertime-onbrownout v13.2
Mikrotik script to fix users time on brownout.
Handle active users limit-uptime on power interruption.
I strongly suggest to use UPS than this script! 😅

eUpTimeBackup: (interval)
- ip hotspot active user
- ip hotspot user uptime
- ip hotspot active uptime
- ip hotspot active session-time-left
- ip hotspot user limit-uptime

Saved Data Location:
- system script name="hs-UpTimeSaved" source

eUpTimeUpdate:
- NewLimitUptime = (User-Limit-Uptime) - (Save-Active-Uptime)
- ip hotspot user limit-uptime=$NewLimitUptime

How to install:
- Open file "fixusertime-onbrownout.rsc".
- select all, copy, & paste to winbox terminal

Author:
- Chloe Renae & Edmar Lozada

Facebook Contact:
- https://www.facebook.com/chloe.renae.9

Youtube Video:
- https://www.youtube.com/watch?v=smxCxMflO2E
