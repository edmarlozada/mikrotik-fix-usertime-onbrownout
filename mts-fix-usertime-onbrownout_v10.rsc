# ==============================
# Mikrotik Script to Fix Users-Limit-Uptime on Brownout v10.0
# Handle Active Users Limit-Uptime on Power Interruption.
# eUpTimeBackup: (interval)
# - ip hotspot active user
# - ip hotspot user uptime
# - ip hotspot active uptime
# - ip hotspot user limit-uptime
# Saved Data Location:
# - system script name="hs-SavedUptime" source
# eUpTimeUpdate:
# - NewLimitUptime = (User-Limit-Uptime) - (Save-Active-Uptime)
# - ip hotspot user limit-uptime=$NewLimitUptime
# Howto Install:
# - select all, copy, & paste to winbox terminal
# Author:
# - Chloe Renae & Edmar Lozada
# - Gcash (0909-3887889)
# Facebook Contact:
# - https://www.facebook.com/chloe.renae.9
# ------------------------------
/{:put "Installing Fix Users-Limit-Uptime...";

:local BackupInterval 5m;

# === remove old === #
/system scheduler remove [find name="uptime backup"];
/system scheduler remove [find name="uptime restore"];
/system scheduler remove [find name="uptime_backup"];
/system scheduler remove [find name="uptime_restore"];
/system scheduler remove [find name="ss_UpTime_Backup"];
/system scheduler remove [find name="ss_UpTime_Update"];
/system scheduler remove [find name="ss_UpTime_Restore"];
/system scheduler remove [find name="eUpTimeBackup"];
/system scheduler remove [find name="eUpTimeRestore"];
/system script remove [find name="sd-hsTimeLeft"];
/system script remove [find name="sd-hsSaveUptime"];
/system script remove [find name="hs-SaveUptime"];
/system script remove [find name="hs-SavedUptime"];

# === eUpTimeBackup === #
{ :local eName "eUpTimeBackup";
  :local eEvent "# $eName #\r
# ==============================\r
# Backup User Active Limit-Uptime\r
# Saves    => /ip hotspot active get \$i user\r
#          => /ip hotspot active get \$i uptime\r
# Location => /system script name=\"hs-SavedUptime\" source\r
# Interval => $BackupInterval\r
# by: Chloe Renae & Edmar Lozada\r
# ------------------------------\r
:local iName \"hs-SavedUptime\"; :local i 5;
/system logging set [find topics=\"critical\"] disabled=no;
:if ([/system script find name=\$iName]=\"\") do={
  /system script add name=\$iName comment=\"( hotspot_saved_uptime )\";
  :while ((\$i>0) and ([/system script find name=\$iName]=\"\")) do={:set i (\$i-1);:delay 1s};
};
:if (\$i>0) do={
  :local iData \" :local tData [:toarray \\\"\\\"];\\r\\n\";
  :if ([:len [/ip hotspot active print as-value]]>0) do={
    :foreach i in=[/ip hotspot active find] do={
      :local eUsrName [/ip hotspot active get \$i user];
      :local uTimeLimit [/ip hotspot user get [find name=\$eUsrName] limit-uptime];
      :if (\$uTimeLimit>0) do={
        :local uTimeUseBak [/ip hotspot user get [find name=\$eUsrName] uptime];
        :local aTimeUseBak [/ip hotspot active get \$i uptime];
        :put \"( UpTimeBackup ) user => UsrName:[\$eUsrName] uTimeLimit:[\$uTimeLimit] \
                                       uTimeUseBak:[\$uTimeUseBak] aTimeUseBak:[\$aTimeUseBak]\";
        :set iData \"\$iData :set (\\\$tData->[:len \\\$tData]) { \\\"\$eUsrName\\\"; \$uTimeUseBak; \$aTimeUseBak; \$uTimeLimit }\\r\\n\";
      }
    }
  };
  :set iData \"\$iData :return \\\$tData\\r\\n\";
  /system script set [find name=\$iName] source=\$iData;
};\r
# ------------------------------\r\n"
:if ([/system scheduler find name=$eName]="") do={ /system scheduler add name=$eName }
/system scheduler  set [find name=$eName] on-event=$eEvent \
 disabled=no start-time=00:00:00 interval=$BackupInterval comment="system_schedulers: UpTime Backup";
}


# === eUpTimeUpdate === #
{ :local eName "eUpTimeUpdate";
  :local eEvent "# $eName #\r
# ==============================\r
# Adjust User Limit-Uptime\r
# Saved    => /system script name=\"hs-SavedUptime\" source\r
# Update   => /ip hotspot user name=\$eUsrName limit-uptime=aNewTime]\r
# interval => startup\r
# by: Chloe Renae & Edmar Lozada\r
# ------------------------------\r
/system scheduler set [find name=eUpTimeBackup] disabled=yes;
:local iName \"hs-SavedUptime\";
:if ([/log find message~\"router was rebooted without proper shutdown\"]!=\"\") do={
:if ([/system script find name=\$iName]!=\"\") do={
  :local iData [[:parse [/system script get [find name=\$iName] source]]];
  :foreach i in=\$iData do={
    :local eUsrName (\$i->0); local uTimeUseBak (\$i->1); :local aTimeUseBak (\$i->2);
    :local uTimeLimNow [/ip hotspot user get [find name=\$eUsrName] limit-uptime];
    :local uTimeUseNow [/ip hotspot user get [find name=\$eUsrName] uptime];
    :local uTimeLimNew ([:totime \$uTimeLimNow]-[:totime \$aTimeUseBak]);
    :put \"( UpTimeUpdate ) Bak => eUsrName:[\$eUsrName] uTimeUseBak:[\$uTimeUseBak] aTimeUseBak:[\$aTimeUseBak]\";
    :put \"( UpTimeUpdate ) Now => eUsrName:[\$eUsrName] uTimeUseNow:[\$uTimeUseNow] uTimeLimNow:[\$uTimeLimNow]\";
    if (\$uTimeUseNow=\$uTimeUseBak) do={
      :put \"( UpTimeUpdate ) NEW => New-Limit-Uptime:[\$uTimeLimNew]\";
      /ip hotspot user set [find name=\$eUsrName] limit-uptime=\$uTimeLimNew;
    }
  }
}};
/system scheduler set [find name=eUpTimeBackup] disabled=no;
:execute script=[/system scheduler get [find name=\"eUpTimeBackup\"] on-event];\r
# ------------------------------\r\n"
:if ([/system scheduler find name=$eName]="") do={ /system scheduler add name=$eName }
/system scheduler  set [find name=$eName] on-event=$eEvent \
 disabled=no start-time=startup interval=0 comment="system_schedulers: UpTime Update (startup)"
}

# ------------------------------\r
}
:local i 10;:while (($i>0) and ([/system scheduler find name="eUpTimeBackup"]="")) do={:set i ($i-1);:delay 1s};
execute script=[/system scheduler get [find name="eUpTimeBackup"] on-event];

