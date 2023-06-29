{
:put ("begin=>$[/system clock get time]")
# ------------------------------
local iName "hs-UpTimeSaved"; local x 5;
if ([/system script find name=$iName]="") do={
  /system script add name=$iName comment="( hotspot ) Saved Uptime )"
  while (($x>0) and ([/system script find name=$iName]="")) do={set x ($x-1);delay 1s}
}
if ($x>0) do={
  local iData ":local tData [:toarray \"\"];\r\n"
  if ([len [/ip hotspot active print as-value]]>0) do={ set x 1
    /system scheduler set [find name=eUpTimeBackup] interval=0 disabled=yes
    /system logging set [find topics=critical] disabled=no
    foreach au in=[/ip hotspot active find] do={ set x ($x+1)
      local eUsrName [/ip hotspot active get $au user]
      local uTimeLimit [/ip hotspot user get [find name=$eUsrName] limit-uptime]
      if ($uTimeLimit>0) do={
        local uTimeUseBak [/ip hotspot user get [find name=$eUsrName] uptime]
        local aTimeUseBak [/ip hotspot active get $au uptime]
        local aTimeLftBak [/ip hotspot active get $au session-time-left]
        put "( UpTimeBackup ) user => UsrName:[$eUsrName] uTimeUseBak:[$uTimeUseBak] aTimeUseBak:[$aTimeUseBak]"
        set iData "$iData :set (\$tData->[:len \$tData]) { \"$eUsrName\"; $uTimeUseBak; $aTimeUseBak; $aTimeLftBak; $uTimeLimit }\r\n"
      }
    }
    /system scheduler set [find name=eUpTimeBackup] disabled=no
  }
  set iData ("$iData".":return \$tData\r\n")
  /system script set [find name=$iName] source=$iData
}
# ------------------------------
:put ("end=>$[/system clock get time]")
/system script remove $iName
}
