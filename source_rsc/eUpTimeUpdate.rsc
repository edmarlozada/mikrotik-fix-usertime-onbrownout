# eUpTimeUpdate #
# ==============================
# Adjust User Limit-Uptime v13.0
# Saved    => /system script name="hs-UpTimeSaved" source
# Update   => /ip hotspot user name=$aUser limit-uptime=aNewTime]
# interval => startup
# by: Chloe Renae & Edmar Lozada
# ------------------------------
local iName "hs-UpTimeSaved"
if ([/log find message~"router was rebooted without proper shutdown"]!="") do={
if ([/system script find name=$iName]!="") do={
  log info ("eUpTimeUpdate Begin => $[/system clock get time]")
  /system scheduler set [find name=eUpTimeBackup] disabled=yes
  do {
    local iData [[parse [/system script get [find name=$iName] source]]]
    foreach au in=$iData do={
      local aUser ($au->0); local uTimeUseBak ($au->1); local aTimeUseBak ($au->2);
      local uTimeLimNow [/ip hotspot user get [find name=$aUser] limit-uptime]
      local uTimeUseNow [/ip hotspot user get [find name=$aUser] uptime]
      local uTimeLimNew ([totime $uTimeLimNow]-[totime $aTimeUseBak])
      put "( UpTimeUpdate ) Bak => aUser:[$aUser] uTimeUseBak:[$uTimeUseBak] aTimeUseBak:[$aTimeUseBak]"
      put "( UpTimeUpdate ) Now => aUser:[$aUser] uTimeUseNow:[$uTimeUseNow] uTimeLimNow:[$uTimeLimNow]"
      if ($uTimeUseNow=$uTimeUseBak) do={
        put "( UpTimeUpdate ) NEW => New-Limit-Uptime:[$uTimeLimNew]"
        /ip hotspot user set [find name=$aUser] limit-uptime=$uTimeLimNew
      }
    }
  } on-error={ log warning "ERROR: invalid saved data" } 
  /system scheduler set [find name=eUpTimeBackup] disabled=no
  log info ("eUpTimeUpdate End => $[/system clock get time]")
}}
execute script=[/system scheduler get [find name=eUpTimeBackup] on-event]
# ------------------------------
