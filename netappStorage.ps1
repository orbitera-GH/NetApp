$LogFile = "C:\Windows\Panther\netappStorage.log"
$vmName=($env:computername).ToLower()
$l=0
function CheckDNS ([string]$dnsOnBoard,[string]$dns) {
	$i = 0
	if ($dnsOnBoard -ne $dns) {
				Set-DNSClientServerAddress –InterfaceIndex $index -ServerAddresses $dns
				start-sleep -s 15
				date >> $LogFile
				echo "(netappStorage.ps1) Modify DNS: $dnsOnBoard, Hostname is $SqlServerName, DNS: $dns" >> $LogFile
				while ($i -lt 11) {
					$i++
					$dnsOnBoard=Get-DnsClientServerAddress -AddressFamily ipv4 -InterfaceIndex (Get-NetIPInterface -AddressFamily ipv4 -InterfaceAlias "Ethernet*" | select ifIndex -ExpandProperty ifIndex) | select serveraddresses -ExpandProperty serveraddresses
					if ($dnsOnBoard -eq $dns) {						
						date >> $LogFile
						echo "(netappStorage.ps1) Correct DnsClient, dnsOnBoard: $dnsOnBoard , DNS is: $dns" >> $LogFile
						echo "While loop step number: $i" >> $LogFile
						$nlookup = nslookup.exe 'netapp.prv'
						foreach ($nameNetapp in $nlookup) {
							if ($nameNetapp -like "*netapp.prv") {
								$i = 100
								date >> $LogFile
								echo "(netappStorage.ps1) dns name netapp.prv successfully resolved" >> $LogFile
								break
							}else{
								date >> $LogFile
								echo "(netappStorage.ps1) wait for resolver" >> $LogFile
								start-sleep -s 10
							}
						}
					}else{
						date >> $LogFile
						echo "(netappStorage.ps1) Wait for DnsClient, dnsOnBoard: $dnsOnBoard , correct DNS is: $dns" >> $LogFile
						start-sleep -s 10
					}
				}				
			}else{
				date >> $LogFile
				echo "(netappStorage.ps1) DNS: $dnsOnBoard is correct." >> $LogFile
			}
}
If (!(Test-Path C:\Windows\Temp\netappStorage.loc)) {
	date >> C:\Windows\Temp\netappStorage.loc
	echo "Lock." >> C:\Windows\Temp\netappStorage.loc
	date >> $LogFile
	echo "Start modConnectToStorageVM.PS1" >> $LogFile
	C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Minimized -command start-process powershell  -WindowStyle Minimized -Wait  -Verb runAs -argumentlist 'C:\Windows\OEM\modConnectToStorageVM.ps1' >> $LogFile
	date >> $LogFile
	echo "Stop modConnectToStorageVM.PS1" >> $LogFile

	date >> $LogFile
	echo "Start modLunMapping.ps1" >> $LogFile
	C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Minimized -command start-process powershell  -WindowStyle Minimized -Wait  -Verb runAs -argumentlist 'C:\Windows\OEM\modLunMapping.ps1' >> $LogFile
	date >> $LogFile
	echo "Stop modLunMapping.ps1" >> $LogFile

	date >> $LogFile
	echo "Start AttachSQLDatabase.PS1" >> $LogFile
	C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Minimized -command start-process powershell  -WindowStyle Minimized -Wait  -Verb runAs -argumentlist 'C:\Windows\OEM\modAttachSQLDatabase.ps1' >> $LogFile
	date >> $LogFile
	echo "Stop AttachSQLDatabase.PS1" >> $LogFile
	while ($l -lt 3) {
			date >> $LogFile
			echo "Notify supervisor" >> $LogFile
			$l++
			(new-object net.webclient).DownloadString('http://168.62.183.34/sqlready.php?name='+$vmName)
			start-sleep -s 15
		}
}else{
	date >> $LogFile
	echo "Lock - detected. C:\Windows\Temp\netappStorage.loc" >> $LogFile
	$index=Get-NetIPInterface -AddressFamily ipv4 -InterfaceAlias "Ethernet*" | select ifIndex -ExpandProperty ifIndex
	$SqlServerName = ($env:computername).ToLower()
	$dnsOnBoard=Get-DnsClientServerAddress -AddressFamily ipv4 -InterfaceIndex (Get-NetIPInterface -AddressFamily ipv4 -InterfaceAlias "Ethernet*" | select ifIndex -ExpandProperty ifIndex) | select serveraddresses -ExpandProperty serveraddresses	
	switch -wildcard ($SqlServerName) { 
		"*01" {
			$dns = "10.200.0.68"
			CheckDNS $dnsOnBoard $dns
		}
		"*02" {
			$dns = "10.200.1.68"
			CheckDNS $dnsOnBoard $dns
		} 
		"*03" {
			$dns = "10.200.2.68"
			CheckDNS $dnsOnBoard $dns
		}
		"*04" {
			$dns = "10.200.3.68"
			CheckDNS $dnsOnBoard $dns
		}
		"*05" {
			$dns = "10.200.4.68"
			CheckDNS $dnsOnBoard $dns
		}
		"*06" {
			$dns = "10.200.5.68"
			CheckDNS $dnsOnBoard $dns
		}
		"*07" {
			$dns = "10.200.6.68"
			CheckDNS $dnsOnBoard $dns
		}
		"*08" {
			$dns = "10.200.7.68"
			CheckDNS $dnsOnBoard $dns
		}
		"*09" {
			$dns = "10.200.8.68"
			CheckDNS $dnsOnBoard $dns
		}
		"*10" {
			$dns = "10.200.9.68"
			CheckDNS $dnsOnBoard $dns
		}
		default {date >> $LogFile ; echo "(netappStorage.ps1) ### ERROR can't determine management DNS IP address for VMname: $SqlServerName"  >> $LogFile}
	}
	date >> $LogFile
	gpupdate.exe /force >> $LogFile
	date >> $LogFile
}