$log="c:\windows\panther\netappstorage.txt"
$vmName=($env:computername).ToLower()
$l=0
If (!(Test-Path C:\Windows\Temp\netappStorage.loc)) {
	date >> C:\Windows\Temp\netappStorage.loc
	echo "Lock." >> C:\Windows\Temp\netappStorage.loc
	date >> $log
	echo "Start modConnectToStorageVM.PS1" >> $log
	C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Minimized -command start-process powershell  -WindowStyle Minimized -Wait  -Verb runAs -argumentlist 'C:\Windows\OEM\modConnectToStorageVM.PS1' >> $log
	date >> $log
	echo "Stop modConnectToStorageVM.PS1" >> $log

	date >> $log
	echo "Start modLunMapping.ps1" >> $log
	C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Minimized -command start-process powershell  -WindowStyle Minimized -Wait  -Verb runAs -argumentlist 'C:\Windows\OEM\modLunMapping.ps1' >> $log
	date >> $log
	echo "Stop modLunMapping.ps1" >> $log

	date >> $log
	echo "Start AttachSQLDatabase.PS1" >> $log
	C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Minimized -command start-process powershell  -WindowStyle Minimized -Wait  -Verb runAs -argumentlist 'C:\Windows\OEM\modAttachSQLDatabase.ps1' >> $log
	date >> $log
	echo "Stop AttachSQLDatabase.PS1" >> $log
	while ($l -lt 3) {
			date >> $log
			echo "Notify supervisor" >> $log
			$l++
			(new-object net.webclient).DownloadString('http://168.62.183.34/sqlready.php?name='+$vmName)
			start-sleep -s 15
		}
}else{
	date >> $log
	echo "Lock - detected. C:\Windows\Temp\netappStorage.loc" >> $log
}