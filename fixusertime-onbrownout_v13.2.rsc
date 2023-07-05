# ==============================
# mikrotik-fix-usertime-onbrownout v13.2
# Mikrotik script to fix users time on brownout.
# Handle active users limit-uptime on power interruption.
# Author:
# - Chloe Renae & Edmar Lozada
# - Gcash (0909-3887889)
# Facebook Contact:
# - https://www.facebook.com/chloe.renae.9
# eUpTimeBackup: (interval)
# - ip hotspot active user
# - ip hotspot user uptime
# - ip hotspot active uptime
# - ip hotspot user limit-uptime
# Saved Data Location:
# - system script name="hs-UpTimeSaved" source
# eUpTimeUpdate:
# - NewLimitUptime = (User-Limit-Uptime) - (Save-Active-Uptime)
# - ip hotspot user limit-uptime=$NewLimitUptime
# Howto Install:
# - select all, copy, & paste to winbox terminal
# Howto Install:
#  - open as txt file
#  - select all, copy
#  - paste to winbox terminal
# ------------------------------


# === remove old === #
/system scheduler remove [find name="uptime backup"]
/system scheduler remove [find name="uptime restore"]
/system scheduler remove [find name="uptime_backup"]
/system scheduler remove [find name="uptime_restore"]
/system scheduler remove [find name="ss_UpTime_Backup"]
/system scheduler remove [find name="ss_UpTime_Update"]
/system scheduler remove [find name="ss_UpTime_Restore"]
/system scheduler remove [find name="eUpTimeBackup"]
/system scheduler remove [find name="eUpTimeUpdate"]
/system scheduler remove [find name="eUpTimeRestore"]
/system script remove [find name="sd-hsTimeLeft"]
/system script remove [find name="sd-hsSaveUptime"]
/system script remove [find name="hs-SaveUptime"]
/system script remove [find name="hs-SavedUpTime"]
/system script remove [find name="hs-SavedTime"]
/system script remove [find name="hs-UpTimeSaved"]


/{put "Installing Fix Users-Limit-Uptime..."
local BackupInterval 5m
# === eUpTimeBackup === #
{ local eName "eUpTimeBackup"
  local eEvent "# $eName #
# ==============================
# Backup Users Active Uptime v13.0
# Saves   : /ip hotspot active user
#           /ip hotspot user uptime
#           /ip hotspot active uptime
#           /ip hotspot active session-time-left
#           /ip hotspot user limit-uptime
# Location: /system script \"hs-UpTimeSaved\" source
# Interval: $BackupInterval
# by: Chloe Renae & Edmar Lozada
# ------------------------------
local iName \"hs-UpTimeSaved\"; local x 5;
if ([/system script find name=\$iName]=\"\") do={
  /system script add name=\$iName comment=\"( hotspot: Saved Uptime )\"
  while ((\$x>0) and ([/system script find name=\$iName]=\"\")) do={set x (\$x-1);delay 1s}
}
if (\$x>0) do={
  local iData \":local tData [:toarray \\\"\\\"];\\r\\n\"
  if ([len [/ip hotspot active print as-value]]>0) do={
    /system scheduler set [find name=eUpTimeBackup] disabled=yes
    /system scheduler set [find name=eUpTimeUpdate] interval=0
    /system logging set [find topics=critical] disabled=no
    foreach au in=[/ip hotspot active find] do={
      local aUser [/ip hotspot active get \$au user]
      local uTimeLimit [/ip hotspot user get [find name=\$aUser] limit-uptime]
      if (\$uTimeLimit>0) do={
        local uTimeUseBak [/ip hotspot user get [find name=\$aUser] uptime]
        local aTimeUseBak [/ip hotspot active get \$au uptime]
        local aTimeLftBak [/ip hotspot active get \$au session-time-left]
        put \"( UpTimeBackup ) Bak => aUser:[\$aUser] uTimeUseBak:[\$uTimeUseBak] aTimeUseBak:[\$aTimeUseBak]\"
        set iData \"\$iData :set (\\\$tData->[:len \\\$tData]) { \\\"\$aUser\\\"; \$uTimeUseBak; \$aTimeUseBak; \$aTimeLftBak; \$uTimeLimit }\\r\\n\"
      }
    }
    /system scheduler set [find name=eUpTimeBackup] disabled=no
  }
  set iData (\"\$iData\".\":return \\\$tData\\r\\n\")
  /system script set [find name=\$iName] source=\$iData
}
# ------------------------------\r\n"
if ([/system scheduler find name=$eName]="") do={ /system scheduler add name=$eName }
/system scheduler  set [find name=$eName] on-event=$eEvent \
 disabled=no start-time=00:00:00 interval=$BackupInterval comment="system_schedulers: UpTime Backup"
}
# ------------------------------


# === eUpTimeUpdate === #
{ local eName "eUpTimeUpdate"
  local eEvent "# $eName #
# ==============================
# Adjust User Limit-Uptime v13.0
# Saved    => /system script name=\"hs-UpTimeSaved\" source
# Update   => /ip hotspot user name=\$aUser limit-uptime=aNewTime]
# interval => startup
# by: Chloe Renae & Edmar Lozada
# ------------------------------
local iName \"hs-UpTimeSaved\"
if ([/log find message~\"router was rebooted without proper shutdown\"]!=\"\") do={
if ([/system script find name=\$iName]!=\"\") do={
  log info (\"eUpTimeUpdate Begin => \$[/system clock get time]\")
  /system scheduler set [find name=eUpTimeBackup] disabled=yes
  do {
    local iData [[parse [/system script get [find name=\$iName] source]]]
    foreach au in=\$iData do={
      local aUser (\$au->0); local uTimeUseBak (\$au->1); local aTimeUseBak (\$au->2);
      local uTimeLimNow [/ip hotspot user get [find name=\$aUser] limit-uptime]
      local uTimeUseNow [/ip hotspot user get [find name=\$aUser] uptime]
      local uTimeLimNew ([totime \$uTimeLimNow]-[totime \$aTimeUseBak])
      put \"( UpTimeUpdate ) Bak => aUser:[\$aUser] uTimeUseBak:[\$uTimeUseBak] aTimeUseBak:[\$aTimeUseBak]\"
      put \"( UpTimeUpdate ) Now => aUser:[\$aUser] uTimeUseNow:[\$uTimeUseNow] uTimeLimNow:[\$uTimeLimNow]\"
      if (\$uTimeUseNow=\$uTimeUseBak) do={
        put \"( UpTimeUpdate ) NEW => New-Limit-Uptime:[\$uTimeLimNew]\"
        /ip hotspot user set [find name=\$aUser] limit-uptime=\$uTimeLimNew
      }
    }
  } on-error={ log warning \"ERROR: invalid saved data\" } 
  /system scheduler set [find name=eUpTimeBackup] disabled=no
  log info (\"eUpTimeUpdate End => \$[/system clock get time]\")
}}
execute script=[/system scheduler get [find name=eUpTimeBackup] on-event]
# ------------------------------\r\n"
if ([/system scheduler find name=$eName]="") do={ /system scheduler add name=$eName }
/system scheduler  set [find name=$eName] on-event=$eEvent \
 disabled=no start-time=startup interval=0 comment="system_schedulers: UpTime Update (startup)"
}
# ------------------------------

local n 10;while (($n>0) and ([/system scheduler find name=eUpTimeBackup]="")) do={set n ($n-1);delay 1s}
execute script=[/system scheduler get [find name=eUpTimeBackup] on-event]
}

