# Mount NetApp storage and repair DNS settings past shutdown VM


$LogFile = "C:\Windows\Panther\netappStorage.log"
$LogFile1 = "C:\Windows\Panther\netappStorageScripts.log"
$LogFile2 = "C:\Windows\Panther\netappStorageScriptsRelease.log"
$SupervisorIP = Get-Content -Path "c:\Windows\OEM\SuperVisorIP.txt"
$supervisorDnsName = "supervisor1.testdrivesupervisor.eastus.cloudapp.azure.com"
#$supervisorIP="23.96.43.23"
$debug="&debug="
function czas {$a="$((get-date -Format yyyy-MM-dd_HH:mm:ss).ToString())"; return $a}

$vmName=($env:computername).ToLower()
$l=0
	function CheckDNS ([string]$dnsOnBoard,[string]$dns) {
		$i = 0
		if ($dnsOnBoard -ne $dns) {
					Set-DNSClientServerAddress –InterfaceIndex $index -ServerAddresses $dns
					start-sleep -s 5	#15
					#date >> $LogFile
					echo "$(czas)  (netappStorage.ps1) Modify DNS: $dnsOnBoard, Hostname is $SqlServerName, DNS: $dns" >> $LogFile
					while ($i -lt 250) {
						$i++
						$dnsOnBoard=Get-DnsClientServerAddress -AddressFamily ipv4 -InterfaceIndex (Get-NetIPInterface -AddressFamily ipv4 -InterfaceAlias "Ethernet*" | select ifIndex -ExpandProperty ifIndex) | select serveraddresses -ExpandProperty serveraddresses
						if ($dnsOnBoard -eq $dns) {						
							#date >> $LogFile
							echo "$(czas)  (netappStorage.ps1) Correct DnsClient, dnsOnBoard: $dnsOnBoard , DNS is: $dns" >> $LogFile
							echo "$(czas)  While loop step number: $i" >> $LogFile
							$nlookup = nslookup.exe 'netapp.prv'
							foreach ($nameNetapp in $nlookup) {
								if ($nameNetapp -like "*netapp.prv") {
									$i = 2000
									#date >> $LogFile
									echo "$(czas)  (netappStorage.ps1) dns name netapp.prv successfully resolved" >> $LogFile
									$suervisorResp = ping $supervisorIP
									break
								}else{
									#date >> $LogFile
									echo "$(czas)  (netappStorage.ps1) wait for resolver" >> $LogFile
									start-sleep -s 2
								}
							}
						}else{
							#date >> $LogFile
							echo "$(czas)  (netappStorage.ps1) Wait for DnsClient, dnsOnBoard: $dnsOnBoard , correct DNS is: $dns" >> $LogFile
							start-sleep -s 2
						}
					}				
				}else{
					#date >> $LogFile
					echo "$(czas)  (netappStorage.ps1) DNS: $dnsOnBoard is correct." >> $LogFile
				}
	}
	$currentUser=[Environment]::UserName
	echo "$(czas)  User is $currentUser" >> $LogFile
	if ($currentUser -notlike "*testdriveadmin*"){
	
		If (!(Test-Path C:\Windows\Temp\netappStorage.loc)) {
			
			echo "$(czas)  Lock." >> C:\Windows\Temp\netappStorage.loc
			
			echo "$(czas)  Start ALLInOne.PS1" >> $LogFile
			#C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Minimized -command start-process powershell  -WindowStyle Minimized -Wait  -Verb runAs -argumentlist 'C:\Windows\OEM\modConnectToStorageVM.ps1 ; C:\Windows\OEM\modLunMapping.ps1 ; C:\Windows\OEM\modAttachSQLDatabase.ps1 ; C:\Windows\OEM\modConfigureSnapDrive.ps1 ; C:\Windows\OEM\modConfigureSnapManager.ps1' >> $LogFile1
			C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Minimized -command start-process powershell  -WindowStyle Minimized -Wait  -Verb runAs -argumentlist 'C:\Windows\OEM\ALLInOne.ps1' >> $LogFile1			
			echo "$(czas)  Stop ALLInOne.PS1" >> $LogFile

			$resp=""
			$resp=(new-object net.webclient).DownloadString('http://'+$SupervisorIP+'/sqlinstall.php?name='+$vmName + $debug)
			$Length = $resp.Length
				if ($Length -ge 2) {
					echo "$(czas)  Supervisor sqlinstall.php respond string: $resp." >> $LogFile
					echo "$(czas)  resp length: $($resp.Length)" >> $LogFile
				}else{		
					echo "$(czas)  Supervisor sqlinstall.php not respond OK but: $resp." >> $LogFile
					echo "$(czas)  resp length: $($resp.Length)" >> $LogFile
				}
				$checkstatus=""
				$step=0
				While ($checkstatus -ne "ReleaseStorage") {
					# waiting for ReleaseStorage response from supervisor
					$checkstatus=(new-object net.webclient).DownloadString('http://'+$SupervisorIP+'/checkstatus.php?name='+$vmName + $debug)
					echo "$(czas) Supervisor checkstatus.php respond string: $checkstatus" >> $LogFile2
					echo "$(czas) checkstatus length: $($checkstatus.Length)" >> $LogFile2
					start-sleep -s 2
					$step++
					echo "$(czas) loop step: $step" >> $LogFile2
				}
				if ($checkstatus -eq "ReleaseStorage") {
					echo "$(czas) End loop, response from supervisor: $checkstatus" >> $LogFile2
					C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Minimized -command start-process powershell  -WindowStyle Minimized -Wait  -Verb runAs -argumentlist 'C:\Windows\OEM\modRestoreVolume.ps1' >> $LogFile2
				}else{
					echo "$(czas) !! ERROR !! End loop, waiting but supervisor NOT respond ReleaseStorage but: $checkstatus" >> $LogFile2
				}
		}else{
			#after restart, probably never happened
			#date >> $LogFile
			echo "$(czas)  Lock - detected. C:\Windows\Temp\netappStorage.loc" >> $LogFile
			echo "$(czas)  Lock 2." >> C:\Windows\Temp\netappStorage1.loc
			echo "$(czas)  Create Lock File C:\Windows\Temp\netappStorage1.loc" >> $LogFile
			$index=Get-NetIPInterface -AddressFamily ipv4 -InterfaceAlias "Ethernet*" | select ifIndex -ExpandProperty ifIndex
			$SqlServerName = ($env:computername).ToLower()
			$dnsOnBoard=Get-DnsClientServerAddress -AddressFamily ipv4 -InterfaceIndex (Get-NetIPInterface -AddressFamily ipv4 -InterfaceAlias "Ethernet*" | select ifIndex -ExpandProperty ifIndex) | select serveraddresses -ExpandProperty serveraddresses	
			switch -wildcard ($SqlServerName) { 
				"*01" {
					$dns = "10.200.0.68"
					$mgmtLIF = "192.168.250.2"
					CheckDNS $dnsOnBoard $dns
				}
				"*02" {
					$dns = "10.200.1.68"
					$mgmtLIF = "192.168.250.18"
					CheckDNS $dnsOnBoard $dns
				} 
				"*03" {
					$dns = "10.200.2.68"
					$mgmtLIF = "192.168.250.34"
					CheckDNS $dnsOnBoard $dns
				}
				"*04" {
					$dns = "10.200.3.68"
					$mgmtLIF = "192.168.250.50"
					CheckDNS $dnsOnBoard $dns
				}
				"*05" {
					$dns = "10.200.4.68"
					$mgmtLIF = "192.168.250.66"
					CheckDNS $dnsOnBoard $dns
				}
				"*06" {
					$dns = "10.200.5.68"
					$mgmtLIF = "192.168.250.82"
					CheckDNS $dnsOnBoard $dns
				}
				"*07" {
					$dns = "10.200.6.68"
					$mgmtLIF = "192.168.250.98"
					CheckDNS $dnsOnBoard $dns
				}
				"*08" {
					$dns = "10.200.7.68"
					$mgmtLIF = "192.168.250.114"
					CheckDNS $dnsOnBoard $dns
				}
				"*09" {
					$dns = "10.200.8.68"
					$mgmtLIF = "192.168.250.130"
					CheckDNS $dnsOnBoard $dns
				}
				"*10" {
					$dns = "10.200.9.68"
					$mgmtLIF = "192.168.250.146"
					CheckDNS $dnsOnBoard $dns
				}
				default {echo "$(czas)  (netappStorage.ps1) ### ERROR can't determine management DNS IP address for VMname: $SqlServerName"  >> $LogFile}
			}
			#date >> $LogFile
			start-sleep -s 3
			gpupdate.exe /force >> $LogFile
			#date >> $LogFile
			#echo "$(czas)  Start ALLInOne.PS1 after restart." >> $LogFile
			#C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Minimized -command start-process powershell  -WindowStyle Minimized -Wait  -Verb runAs -argumentlist 'C:\Windows\OEM\modConnectToStorageVM.ps1 ; C:\Windows\OEM\modLunMapping.ps1 ; C:\Windows\OEM\modAttachSQLDatabase.ps1 ; C:\Windows\OEM\modConfigureSnapDrive.ps1 ; C:\Windows\OEM\modConfigureSnapManager.ps1' >> $LogFile1
			#C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Minimized -command start-process powershell  -WindowStyle Minimized -Wait  -Verb runAs -argumentlist 'C:\Windows\OEM\ALLInOne.ps1' >> $LogFile1			
			#echo "$(czas)  End Start ALLInOne.PS1 after restart." >> $LogFile
			$mgmtLIFping = ping $mgmtLIF
			if ($mgmtLIFping -split ':' -contains "Reply from $mgmtLIF") {
				echo "$(czas)  mgmtLIF ping respond OK." >> $LogFile
			}else{
				echo "$(czas)  mgmtLIF ping NOT respond." >> $LogFile
			}
			$resp=""
			$resp=(new-object net.webclient).DownloadString('http://'+$SupervisorIP+'/sqlready.php?name='+$vmName + $debug)
			$Length = $resp.Length
			if ($Length -ge 2) {
				echo "$(czas)  Supervisor sqlinstall.php respond string: $resp." >> $LogFile
				echo "$(czas)  resp length: $($resp.Length)" >> $LogFile
			}else{		
				echo "$(czas)  Supervisor sqlinstall.php not respond OK but: $resp." >> $LogFile
				echo "$(czas)  resp length: $($resp.Length)" >> $LogFile
			}
		}
	}else{
		#date >> $LogFile
		echo "$(czas)  User: $currentUser is logged on, netappStorage.ps1 script was skipped... " >> $LogFile
	}
	#date >> $LogFile
	<#echo "$(czas)  Notify supervisor." >> $LogFile
	$resp=""
		$resp=(new-object net.webclient).DownloadString('http://23.96.43.23/sqlready.php?name='+$vmName)
		if ($resp -eq "OK") {
			echo "$(czas)  Supervisor respond string: $resp." >> $LogFile
			echo "$(czas)  resp length: $resp.Length" >> $LogFile
		}else{		
			echo "$(czas)  Supervisor not respond OK but: $resp." >> $LogFile
			echo "$(czas)  resp length: $resp.Length" >> $LogFile
		}#>
	echo "$(czas)  (netappStorage.ps1) End of script." >> $LogFile