{
put ("eUpTimeBackup Begin => $[/system clock get time]")
log info ("eUpTimeBackup Begin => $[/system clock get time]")
# ------------------------------
local iName "data-Test"; local x 5;
if ([/system script find name=$iName]="") do={
  /system script add name=$iName comment="( hotspot: BrownOut Saved Data )"
  while (($x>0) and ([/system script find name=$iName]="")) do={set x ($x-1);delay 1s}
}
if ($x>0) do={
  local iData ":local tData [:toarray \"\"];\r\n"
  if ([len [/ip hotspot active print as-value]]>0) do={
    /system logging set [find topics="critical"] disabled=no
    /system scheduler set [find name=eBrownOutBackup] disabled=yes
    /system scheduler set [find name=eBrownOutUpdate] start-time=startup interval=0
    foreach au in=[/ip hotspot active find] do={
      local aUser [/ip hotspot active get $au user]
      local uTimeLimit [/ip hotspot user get [find name=$aUser] limit-uptime]
      if ($uTimeLimit>0) do={
        local uTimeUseBak [/ip hotspot user get [find name=$aUser] uptime]
        local aTimeUseBak [/ip hotspot active get $au uptime]
        local aTimeLftBak [/ip hotspot active get $au session-time-left]
        set iData "$iData :set (\$tData->[:len \$tData]) { \"$aUser\"; $uTimeUseBak; $aTimeUseBak; $aTimeLftBak; $uTimeLimit }\r\n"
      }
    }
    /system scheduler set [find name=eBrownOutBackup] disabled=no
  }
  set iData ("$iData".":return \$tData\r\n")
  /system script set [find name=$iName] source=$iData
}
# ------------------------------
log info ("eUpTimeBackup End ($x) => $[/system clock get time]")
put ("eUpTimeBackup End ($x) => $[/system clock get time]")
/system script remove $iName
}
