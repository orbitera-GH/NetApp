# Main script running via host.ps1 on sql's machines

$vmName=($env:computername).ToLower()
$PlainPassword = "Qwerty12"
 $SecurePassword = (ConvertTo-SecureString $PlainPassword -AsPlainText -Force) 
$UserName = "NETAPP\netappadmin"
 $Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName, $SecurePassword
$i=0
$l=0
$NetappServicePassword = "P@ssword1"
#$NetappServicePassword = "p@ssword1"
#$StorageAdmin = "$vmName\testdriveadmin"
$StorageAdmin = "netapp\netappadmin"
#$StorageAdminPassword = "p@ssword1"
$StorageAdminPassword = "Qwerty12"
$log="C:\Windows\Panther\bcd.log"
$myDomain="netapp.prv"
$ipConfig = ipconfig
$ip=$ipConfig[8].Replace('   IPv4 Address. . . . . . . . . . . : ','')
$ip=$ip.Trim()
$domainControllerIP=$ip.Remove(($ip.LastIndexOf('.')+1))+"68"

## download
function czas {$a="$((get-date -Format yyyy-MM-dd_HH:mm:ss).ToString())"; return $a}

Function download ([string]$source,[string]$destination) {	
	Invoke-WebRequest $source -OutFile $destination
	if (test-path $destination) {
		#date >> $log
		echo "$(czas)  Successfully downloaded file: $destination" >> $log
	}else{
		#date >> $log
		echo "$(czas)  Error download file: $destination" >> $log
	}
}

download "https://raw.githubusercontent.com/orbitera-GH/NetApp/master/netappStorage.ps1" "c:\Windows\OEM\netappStorage.ps1"
download "https://raw.githubusercontent.com/orbitera-GH/NetApp/master/modAttachSQLDatabase.ps1" "c:\Windows\OEM\modAttachSQLDatabase.ps1"
download "https://raw.githubusercontent.com/orbitera-GH/NetApp/master/modConnectToStorageVM.ps1" "c:\Windows\OEM\modConnectToStorageVM.ps1"
download "https://raw.githubusercontent.com/orbitera-GH/NetApp/master/modLunMapping.ps1" "c:\Windows\OEM\modLunMapping.ps1"
download "https://raw.githubusercontent.com/orbitera-GH/NetApp/master/modRestoreVolume.ps1" "c:\Windows\OEM\modRestoreVolume.ps1"
download "https://raw.githubusercontent.com/orbitera-GH/NetApp/master/SMSQLConfig.xml" "c:\Windows\OEM\SMSQLConfig.xml"
download "https://raw.githubusercontent.com/orbitera-GH/NetApp/master/modConfigureSnapDrive.ps1" "c:\Windows\OEM\modConfigureSnapDrive.ps1"
download "https://raw.githubusercontent.com/orbitera-GH/NetApp/master/modConfigureSnapManager.ps1" "c:\Windows\OEM\modConfigureSnapManager.ps1"
download "https://raw.githubusercontent.com/orbitera-GH/NetApp/master/ALLInOne.ps1" "c:\Windows\OEM\ALLInOne.ps1"
download "https://raw.githubusercontent.com/orbitera-GH/NetApp/master/makeuser.cmd" "c:\Windows\OEM\makeuser.cmd"

## download end

copy "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft SQL Server 2014\SQL Server 2014 Management Studio.lnk" "C:\Users\Public\Desktop\SQL Server 2014 Management Studio.lnk"
copy "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\NetApp\SnapManager for SQL Server PowerShell.lnk" "C:\Users\Public\Desktop\SnapManager for SQL Server PowerShell.lnk"
copy "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\NetApp\SnapManager for SQL Server Management Console.lnk" "C:\Users\Public\Desktop\SnapManager for SQL Server Management Console.lnk"
copy "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\NetApp\SnapDrive.lnk" "C:\Users\Public\Desktop\SnapDrive.lnk"

## controller.txt (file on sql desktop)
echo "$(czas)  start assemble controller.txt" >> $log
switch -wildcard ($vmName) { 
		"*01" {
			$vnetNameForConntrollerFile = "aztestdrive140"
			echo "$(czas)  vnetName for controller.txt: $vnetNameForConntrollerFile" >> $log
		}
		"*02" {
			$vnetNameForConntrollerFile = "aztestdrive141"
			echo "$(czas)  vnetName for controller.txt: $vnetNameForConntrollerFile" >> $log
		} 
		"*03" {
			$vnetNameForConntrollerFile = "aztestdrive142"
			echo "$(czas)  vnetName for controller.txt: $vnetNameForConntrollerFile" >> $log
		}
		"*04" {
			$vnetNameForConntrollerFile = "aztestdrive143"
			echo "$(czas)  vnetName for controller.txt: $vnetNameForConntrollerFile" >> $log
		}
		"*05" {
			$vnetNameForConntrollerFile = "aztestdrive144"
			echo "$(czas)  vnetName for controller.txt: $vnetNameForConntrollerFile" >> $log
		}
		"*06" {
			$vnetNameForConntrollerFile = "aztestdrive145"
			echo "$(czas)  vnetName for controller.txt: $vnetNameForConntrollerFile" >> $log
		}
		"*07" {
			$vnetNameForConntrollerFile = "aztestdrive146"
			echo "$(czas)  vnetName for controller.txt: $vnetNameForConntrollerFile" >> $log
		}
		"*08" {
			$vnetNameForConntrollerFile = "aztestdrive147"
			echo "$(czas)  vnetName for controller.txt: $vnetNameForConntrollerFile" >> $log
		}
		"*09" {
			$vnetNameForConntrollerFile = "aztestdrive148"
			echo "$(czas)  vnetName for controller.txt: $vnetNameForConntrollerFile" >> $log
		}
		"*10" {
			$vnetNameForConntrollerFile = "aztestdrive149"
			echo "$(czas)  vnetName for controller.txt: $vnetNameForConntrollerFile" >> $log
		}
		default {echo "$(czas) ### ERROR can't determine aztestdrive network name for VMname: $vmName"  >> $LogFile}
	}
Write-Output "NetApp Storage Controller: $vnetNameForConntrollerFile" | Out-File -FilePath C:\Users\Public\Desktop\controller.txt -Append
Write-Output "UserName: VSAdmin" | Out-File -FilePath C:\Users\Public\Desktop\controller.txt -Append
Write-Output "Password: Orbitera123!" | Out-File -FilePath C:\Users\Public\Desktop\controller.txt -Append
echo "$(czas)  stop assemble controller.txt" >> $log
## controller.txt stop

#C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe  -command start-process powershell  -WindowStyle Minimized -Wait  -Verb runAs -argumentlist "'cmd.exe /c c:\Windows\OEM\makeuser.cmd'"

##netapp start
	#date >> $log
	echo "$(czas)  ### NetappStorageON registry and services set start." >> $log
	$Work="C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Minimized -command start-process powershell  -WindowStyle Minimized -Wait  -Verb runAs -argumentlist 'C:\Windows\OEM\netappStorage.ps1'"
	$Run="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
	Set-ItemProperty $Run "NetappStorageON" ($Work)
	#1
		Set-NetFirewallProfile -Profile Public,Private,Domain -Enabled False -ErrorAction SilentlyContinue
	#2
		Set-Service -Name msiscsi -StartupType Automatic -ErrorAction SilentlyContinue
		Start-Service msiscsi -ErrorAction SilentlyContinue
	
	
	Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value "$StorageAdmin"
	Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -Value "$StorageAdminPassword"
	Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -Value "1"
	#date >> $log
	echo "$(czas)  ### Registry HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" >> $log
	Get-Item HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run >> $log
	echo "$(czas)  ### Registry HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" >> $log
	Get-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" >> $log
	echo "$(czas)  ### NetappStorageON registry set stop." >> $log
##netapp stop

##DNS
Write-Output "$domainControllerIP  netapp" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Append
Write-Output "$domainControllerIP  netapp.prv" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Append
$nicIndex = Get-NetIPInterface -InterfaceAlias ethernet -AddressFamily ipv4 | select ifIndex -ExpandProperty ifIndex
Set-DNSClientServerAddress –InterfaceIndex $nicIndex -ServerAddresses $domainControllerIP
#DNS end
# Change Netapp Servicess password

#date >> $log
echo "$(czas)  Service: Data ONTAP VSS" >> $log
$service = gwmi win32_service -filter "name='Navssprv'"
$service.Change($Null,$Null,$Null,$Null,$Null,$Null,$Null,$NetappServicePassword) >> $log
$service.StartService() >> $log
start-sleep -s 3
gwmi win32_service -filter "name='Navssprv'" >> $log

echo "$(czas)  Service: SnapDrive" >> $log
$service = gwmi win32_service -filter "name='SWSvc'"
$service.Change($Null,$Null,$Null,$Null,$Null,$Null,$Null,$NetappServicePassword) >> $log
$service.StartService() >> $log
start-sleep -s 3
gwmi win32_service -filter "name='SWSvc'" >> $log

echo "$(czas)  Service: SnapDriveManagmentService" >> $log
$service = gwmi win32_service -filter "name='SDMgmtSvc'"
$service.Change($Null,$Null,$Null,$Null,$Null,$Null,$Null,$NetappServicePassword) >> $log
$service.StartService() >> $log
start-sleep -s 3
gwmi win32_service -filter "name='SDMgmtSvc'" >> $log

echo "$(czas)  Service: SnapDriveService" >> $log
$service = gwmi win32_service -filter "name='SnapDriveService'"
$service.Change($Null,$Null,$Null,$Null,$Null,$Null,$Null,$NetappServicePassword) >> $log
$service.StartService() >> $log
start-sleep -s 3
gwmi win32_service -filter "name='SnapDriveService'" >> $log

echo "$(czas)  Service: SnapManagerService" >> $log
$service = gwmi win32_service -filter "name='SnapManagerService'"
$service.Change($Null,$Null,$Null,$Null,$Null,$Null,$Null,$NetappServicePassword) >> $log
$service.StartService() >> $log
start-sleep -s 3
gwmi win32_service -filter "name='SnapManagerService'" >> $log

#date >> $log
echo "$(czas)  Change Netapp Servicess password END" >> $log


 Import-Module ServerManager -ErrorAction SilentlyContinue
 Import-Module ADDSDeployment -ErrorAction SilentlyContinue
#echo "$(czas)  ## bcd.ps1 ###" >> %windir%\Panther\WaSetup.log 

Write-Host "## bcd.ps1 ###" | Out-File -FilePath "$log" -Append
while ($i -lt 250) {
	$i++
	Start-Sleep -Seconds 5
	$response = ping netapp.prv
	#notify supervisor in netappStorage.ps1
			#date >> $log
			#echo "$(czas)  Jest ping $myDomain : $domain" >> $log
			echo "$(czas)  #### Add-computer to $myDomain #####" >> $log
			Add-computer -DomainName $myDomain -Credential $Credentials -Restart
			if ($?) {
					
					#date >> $log
					echo "$(czas)  I ma: $i" >> $log
					echo "$(czas)  ### Registry HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" >> $log
					Get-Item HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run >> $log
					echo "$(czas)  #### Add-computer STOP #####" >> $log
					$i=300
			}
		
}
