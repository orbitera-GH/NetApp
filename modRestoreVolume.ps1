
$LogFile = "C:\Windows\Panther\netappStorageRestoreVolume.log"
function czas {$a="$((get-date -Format yyyy-MM-dd_HH:mm:ss).ToString())"; return $a}
echo "$(czas)  Starting EMPTY script modRestoreVolume.ps1..." >> $LogFile
	