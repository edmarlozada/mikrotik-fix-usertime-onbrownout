# eUpTimeUpdate #
# ==============================
# Adjust User Limit-Uptime v13.0
# Saved    => /system script name="hs-SavedUptime" source
# Update   => /ip hotspot user name=$eUsrName limit-uptime=aNewTime]
# interval => startup
# by: Chloe Renae & Edmar Lozada
# ------------------------------
/system scheduler set [find name=eUpTimeBackup] disabled=yes;
:local iName "hs-SavedUptime";
:if ([/log find message~"router was rebooted without proper shutdown"]!="") do={
:if ([/system script find name=$iName]!="") do={
  :do {
    :local iData [[:parse [/system script get [find name=$iName] source]]];
    :foreach au in=$iData do={
      :local eUsrName ($au->0); local uTimeUseBak ($au->1); :local aTimeUseBak ($au->2);
      :local uTimeLimNow [/ip hotspot user get [find name=$eUsrName] limit-uptime];
      :local uTimeUseNow [/ip hotspot user get [find name=$eUsrName] uptime];
      :local uTimeLimNew ([:totime $uTimeLimNow]-[:totime $aTimeUseBak]);
      :put "( UpTimeUpdate ) Bak => eUsrName:[$eUsrName] uTimeUseBak:[$uTimeUseBak] aTimeUseBak:[$aTimeUseBak]";
      :put "( UpTimeUpdate ) Now => eUsrName:[$eUsrName] uTimeUseNow:[$uTimeUseNow] uTimeLimNow:[$uTimeLimNow]";
      if ($uTimeUseNow=$uTimeUseBak) do={
        :put "( UpTimeUpdate ) NEW => New-Limit-Uptime:[$uTimeLimNew]";
        /ip hotspot user set [find name=$eUsrName] limit-uptime=$uTimeLimNew;
      }
    }
  } on-error={ :log warning "ERROR: invalid saved data" }; 
}};
/system scheduler set [find name=eUpTimeBackup] disabled=no;
:execute script=[/system scheduler get [find name="eUpTimeBackup"] on-event];
# ------------------------------
