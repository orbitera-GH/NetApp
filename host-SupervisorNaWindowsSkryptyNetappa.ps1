$vmName=($env:computername).ToLower()
$PlainPassword = "Qwerty12"
 $SecurePassword = (ConvertTo-SecureString $PlainPassword -AsPlainText -Force) 
$UserName = "NETAPP\netappadmin"
 $Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName, $SecurePassword
$i=0
$l=0
$StorageAdmin = "storageadmin"
$StorageAdminPassword = "Qwerty12"
$log="C:\Windows\Panther\bcd.log"
$myDomain="netapp.prv"
$ipConfig = ipconfig
$ip=$ipConfig[8].Replace('   IPv4 Address. . . . . . . . . . . : ','')
$ip=$ip.Trim()
$domainControllerIP=$ip.Remove(($ip.LastIndexOf('.')+1))+"68"
##netapp start
	date >> $log
	echo "### NetappStorageON registry and services set start." >> $log
	$Work="C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Minimized -command start-process powershell  -WindowStyle Minimized -Wait  -Verb runAs -argumentlist 'C:\Windows\OEM\netappStorage.ps1'"
	#1
		Set-NetFirewallProfile -Profile Public,Private,Domain -Enabled False
	#2
		Set-Service -Name msiscsi -StartupType Automatic -ErrorAction SilentlyContinue
		Start-Service msiscsi -ErrorAction SilentlyContinue
	
	
	Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value "$StorageAdmin"
	Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -Value "$StorageAdminPassword"
	Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -Value "1"
	date >> $log
	echo "### Registry HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" >> $log
	Get-Item HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run >> $log
	echo "### Registry HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" >> $log
	Get-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" >> $log
	echo "### NetappStorageON registry set stop." >> $log
##netapp stop
Write-Output "$domainControllerIP  netapp" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Append
Write-Output "$domainControllerIP  netapp.prv" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Append
$nicIndex = Get-NetIPInterface -InterfaceAlias ethernet -AddressFamily ipv4 | select ifIndex -ExpandProperty ifIndex
Set-DNSClientServerAddress –InterfaceIndex $nicIndex -ServerAddresses $domainControllerIP
 Import-Module ServerManager -ErrorAction SilentlyContinue
 Import-Module ADDSDeployment -ErrorAction SilentlyContinue
#echo "## bcd.ps1 ###" >> %windir%\Panther\WaSetup.log 

Write-Host "## bcd.ps1 ###" | Out-File -FilePath "$log"
while ($i -lt 250) {
	$i++
	Start-Sleep -Seconds 5
	$response = ping netapp.prv
	#notify supervisor in netappStorage.ps1
			date >> $log
			#echo "Jest ping $myDomain : $domain" >> $log
			echo "#### Add-computer to $myDomain #####" >> $log
			Add-computer -DomainName $myDomain -Credential $Credentials -Restart
			if ($?) {
					$Run="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
					Set-ItemProperty $Run "NetappStorageON" ($Work)
					date >> $log
					echo "I ma: $i" >> $log
					echo "### Registry HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" >> $log
					Get-Item HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run >> $log
					echo "#### Add-computer STOP #####" >> $log
					$i=300
			}
		
}
