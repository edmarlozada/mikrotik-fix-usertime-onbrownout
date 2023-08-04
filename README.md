# MikroTik-fix-usertime-onbrownout v13.3
MikroTik script to fix users time on brownout.
Handle active users limit-uptime on power interruption.
I strongly suggest to use UPS than this script! 😅

What's New in v13.3 (2023-Aug-05)
- eBrownOutUpdate users updated time are shown in logs
- eBrownOutUpdate begin/end time are shown in logs
- eBrownOutUpdate exit if empty data-BrownOut
- eBrownOutUpdate exit if proper shutdown
- eBrownOutBackup loggin>critical always enabled
- eBrownOutBackup start-time & interval always updated
- eBrownOutBackup unlimited users are skipped

eUpTimeBackup: (interval)
- ip hotspot active user
- ip hotspot user uptime
- ip hotspot active uptime
- ip hotspot active session-time-left
- ip hotspot user limit-uptime

Saved Data Location:
- system script name="data-BrownOut" source

eUpTimeUpdate:
- NewLimitUptime = (User-Limit-Uptime) - (Save-Active-Uptime)
- ip hotspot user limit-uptime=$NewLimitUptime

How to install:
- Open file "fixusertime-onbrownout_v13.3"
- select all, copy, & paste to winbox terminal

Author:
- Chloe Renae & Edmar Lozada

Facebook Contact:
- https://www.facebook.com/chloe.renae.9

Youtube Video:
- https://www.youtube.com/watch?v=smxCxMflO2E

