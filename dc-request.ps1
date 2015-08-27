#
#	Production
#
#	Production
#
#	Production
#
######################################################

$LogFile = "C:\Windows\Panther\DC-request.log"
$vmName=($env:computername).ToLower()
function czas {$a="$((get-date -Format yyyy-MM-dd_HH:mm:ss).ToString())"; return $a}

$resp=""
			$resp=(new-object net.webclient).DownloadString('http://23.96.43.23/dcready.php?name='+$vmName + $debug)
			$Length = $resp.Length
			if ($Length -ge 2) {
				echo "$(czas)  Supervisor sqlinstall.php respond string: $resp." >> $LogFile
				echo "$(czas)  resp length: $($resp.Length)" >> $LogFile
			}else{		
				echo "$(czas)  Supervisor sqlinstall.php not respond OK but: $resp." >> $LogFile
				echo "$(czas)  resp length: $($resp.Length)" >> $LogFile
			}
Restart-Service dns

echo "$(czas)  add registry" >> $LogFile
$Work="C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Minimized -command start-process powershell  -WindowStyle Minimized -Wait  -Verb runAs -argumentlist 'C:\call\dc-request.ps1'"
$Run="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
Set-ItemProperty $Run "CallToSupervisor" ($Work)


Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value "netapp\netappadmin"
	Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -Value "Qwerty12"
	Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -Value "1"

echo "$(czas)  Run key" >> $LogFile	
Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" >> $LogFile
echo "$(czas)  Winlogon key" >> $LogFile	
Get-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" >> $LogFile