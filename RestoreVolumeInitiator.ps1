# init script located on DC machines and distributed via GPO

#
#	DEVEL
#
#	DEVEL
#
#	DEVEL
#
######################################################


$LogFile = "C:\Windows\Panther\netappRestore.log"
date >> $LogFile
echo "RestoreVolumeInitiator.ps1" >> $LogFile
echo "Try to run cleaning script." >> $LogFile
C:\Windows\System32\WindowsPowerShell\v1.0\PowerShell -NoProfile -ExecutionPolicy Bypass -file "c:\Windows\OEM\modRestoreVolume.ps1" >> $LogFile
date >> $LogFile
echo "RestoreVolumeInitiator.ps1 script ended." >> $LogFile
