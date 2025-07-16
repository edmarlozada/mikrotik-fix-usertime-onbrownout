# ==============================
# MikroTik-fix-usertime-onbrownout v16a
# ------------------------------
# MikroTik script to fix users time on brownout.
# Handle active users limit-uptime on power interruption.
# Author:
# - Chloe Renae & Edmar Lozada
# Facebook Contact:
# - https://www.facebook.com/chloe.renae.9
# Howto Install:
#  - open as txt file
#  - select all, copy
#  - paste to winbox terminal
# WARNING!!!
#  Do Not Mix with other brownout script
#  Only use one brownout script for your system
#  Remove our old version of brownout as well
#  use at your own risk!
# ------------------------------

/{
put "Installing Fix-Users-Limit-Uptime..."
local SaveInterval 5m
local iVer v16a
local eSName "<eBrownOutSave>"
local eUName "<eBrownOutUpdate>"
local eDName "db_BrownOut"

if ([/system scheduler find name=$eSName]="") do={ /system scheduler add name=$eSName }
/system scheduler set [find name=$eSName] start-time=00:00:00 interval=$SaveInterval \
 disabled=no comment="sysched: BrownOut Save Active User ($iVer)" \
 on-event=("# $eSName #\r
# ==============================\r
# Save Active Users Time $iVer\r
# by: Chloe Renae & Edmar Lozada\r
# ------------------------------\r
local dbFile \"$eDName\"
local ssSave \"$eSName\"
if ([/system script find name=\$dbFile]=\"\") do={
  /system script add name=\$dbFile
  local i 10;while (([/system script find name=\$dbFile]=\"\")&&(\$i>0)) do={set i (\$i-1);delay 1s}
}
if ([/system script find name=\$dbFile]!=\"\") do={
  local iData \"local e [toarray \\\"\\\"]\\r\\n\"
  if ([len [/ip hotspot active find session-time-left>0]]>0) do={
    /system scheduler set [find name=\$ssSave] disabled=yes
    local aHSU; local aHSA; local iUsr; local iUsrUT; local iActUT; 
    foreach i in=[/ip hotspot active find session-time-left>0] do={ do {
      set aHSA [/ip hotspot active get \$i]
      set iUsr (\$aHSA->\"user\")
      set aHSU [/ip hotspot user get [find name=\$iUsr]]
      set iUsrUT (\$aHSU->\"uptime\")
      set iActUT (\$aHSA->\"uptime\")
      set iData (\$iData.\"set (\\\$e->[len \\\$e]) {\\\"\$iUsr\\\";\$iUsrUT;\$iActUT}\\r\\n\")
    } on-error={ log warning \"( \$ssSave ) ERROR: [\$i] invalid data!\" } }
    /system scheduler set [find name=\$ssSave] disabled=no
  }
  set iData (\"\$iData\".\"return \\\$e\\r\\n\")
  /system script set [find name=\$dbFile] comment=\"brownout: Saved Active Users\" owner=\"brownout script\" source=\$iData
} else={ log error \"( \$ssSave ) ERROR: data file not exist!\" }\r
# ------------------------------\r\n")

# ==============================

if ([/system scheduler find name=$eUName]="") do={ /system scheduler add name=$eUName }
/system scheduler set [find name=$eUName] start-time=startup interval=0 \
 disabled=no comment="sysched: BrownOut Update User Time ($iVer)" \
 on-event=("# $eUName #\r
# ==============================\r
# Adjust User Limit-Uptime $iVer\r
# by: Chloe Renae & Edmar Lozada\r
# ------------------------------\r
local dbFile \"$eDName\"
local ssSave \"$eSName\"
local ssUpdt \"$eUName\"
if ([/system script find name=\$dbFile]!=\"\") do={
  /system scheduler set [find name=\$ssSave] disabled=yes
  local iData [[parse [/system script get [find name=\$dbFile] source]]]
  if ([len \$iData]>0) do={
    log info (\"( \$ssUpdt ) Beg => \$[/system clock get time]\")
    local aHSU; local iUsr; local iUsrUT; local iActUT; local iNewLT
    foreach i in=\$iData do={ do {
      set iUsr (\$i->0); set iUsrUT (\$i->1); set iActUT (\$i->2);
      if ([/ip hotspot user find name=\$iUsr]!=\"\") do={
        set aHSU [/ip hotspot user get \$iUsr]
        if (((\$aHSU->\"limit-uptime\")>1s) && ((\$aHSU->\"uptime\")=\$iUsrUT)) do={
          if ((\$aHSU->\"limit-uptime\")>\$iActUT) do={ set iNewLT ((\$aHSU->\"limit-uptime\") - \$iActUT) } else={ set iNewLT 1s }
          log info \"( \$ssUpdt ) => User:[\$iUsr] UsrLT:[\$(\$aHSU->\"limit-uptime\")] UsrUT:[\$(\$aHSU->\"uptime\")] BakUT:[\$iActUT] => NewLT:[\$iNewLT]\"
          /ip hotspot user set [find name=\$iUsr] limit-uptime=\$iNewLT
        }
      }
    } on-error={ log warning \"( \$ssUpdt ) ERROR: [\$i] invalid data\" } }
    /system script set [find name=\$dbFile] owner=\"brownout script\" source=\"local e [toarray \\\"\\\"]\\r\\nreturn \\\$e\\r\\n\"
    log info (\"( \$ssUpdt ) End => \$[/system clock get time]\")
  }
  /system scheduler set [find name=\$ssSave] disabled=no
  execute [/system scheduler get [find name=\$ssSave] on-event]\r
}
# ------------------------------\r\n")

local n 10;while (($n>0) and ([/system scheduler find name=$eSName]="")) do={set n ($n-1);delay 1s}
execute [/system scheduler get [find name="$eSName"] on-event]
}

console clear-history
