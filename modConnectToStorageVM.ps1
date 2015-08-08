
###########################################################################
# 
# Script to connect to SVM from SQL Virtual Machine
#
# Author - Mudassar Shafique
# Version - 1.1
# Last Modified 08/04/2015
#
#############################################################################


#set these variables per the storage virtual machine
Import-Module DataOnTap -ErrorAction SilentlyContinue
$SqlServerName = ($env:computername).ToLower()
$LogFile = "C:\Windows\Panther\netappStorage.log"
date >> $LogFile
echo "modConnectToStorage start..." >> $LogFile
switch -wildcard ($SqlServerName) { 
		"*01" {
			$mgmtLIF = "192.168.250.2"
			$dataLIF1 = "192.168.250.4"
			$dataLIF2 = "192.168.250.5"
			$server = "Server140"
			date >> $LogFile
			echo "Hostname is $SqlServerName, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
		}
		"*02" {
			$mgmtLIF = "192.168.250.18"
			$dataLIF1 = "192.168.250.20"
			$dataLIF2 = "192.168.250.21"
			$server = "Server141"
			date >> $LogFile
			echo "Hostname is $SqlServerName, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
		} 
		"*03" {
			$mgmtLIF = "192.168.250.34"
			$dataLIF1 = "192.168.250.36"
			$dataLIF2 = "192.168.250.37"
			$server = "Server142"
			date >> $LogFile
			echo "Hostname is $SqlServerName, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
		}
		"*04" {
			$mgmtLIF = "192.168.250.50"
			$dataLIF1 = "192.168.250.52"
			$dataLIF2 = "192.168.250.53"
			$server = "Server143"
			date >> $LogFile
			echo "Hostname is $SqlServerName, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
		}
		"*05" {
			$mgmtLIF = "192.168.250.66"
			$dataLIF1 = "192.168.250.68"
			$dataLIF2 = "192.168.250.69"
			$server = "Server144"
			date >> $LogFile
			echo "Hostname is $SqlServerName, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
		}
		"*06" {
			$mgmtLIF = "192.168.250.82"
			$dataLIF1 = "192.168.250.84"
			$dataLIF2 = "192.168.250.85"
			$server = "Server145"
			date >> $LogFile
			echo "Hostname is $SqlServerName, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
		}
		"*07" {
			$mgmtLIF = "192.168.250.98"
			$dataLIF1 = "192.168.250.100"
			$dataLIF2 = "192.168.250.101"
			$server = "Server146"
			date >> $LogFile
			echo "Hostname is $SqlServerName, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
		}
		"*08" {
			$mgmtLIF = "192.168.250.114"
			$dataLIF1 = "192.168.250.116"
			$dataLIF2 = "192.168.250.117"
			$server = "Server147"
			date >> $LogFile
			echo "Hostname is $SqlServerName, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
		}
		"*09" {
			$mgmtLIF = "192.168.250.130"
			$dataLIF1 = "192.168.250.132"
			$dataLIF2 = "192.168.250.133"
			$server = "Server148"
			date >> $LogFile
			echo "Hostname is $SqlServerName, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
		}
		"*10" {
			$mgmtLIF = "192.168.250.146"
			$dataLIF1 = "192.168.250.148"
			$dataLIF2 = "192.168.250.149"
			$server = "Server149"
			date >> $LogFile
			echo "Hostname is $SqlServerName, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
		}
		default {date >> $LogFile ; echo "### ERROR can't determine management LIF IP address for VMname: $SqlServerName"  >> $LogFile}
	}
#$dataLIF1 = "192.168.250.36"
#$dataLIF2 = "192.168.250.37"
#$mgmtLIF = "192.168.250.34"
#$server = "server142"

$verbose = $true #for debugging
$secpasswd = ConvertTo-SecureString "Orbitera123!" -AsPlainText -Force
$svmcreds = New-Object System.Management.Automation.PSCredential ("vsadmin", $secpasswd)


#Logging function
function PostEvent([String]$TextField, [string]$EventType)
	{	# Subroutine to Post Events to Log/Screen/EventLog
		$outfile = "C:\TestDriveSetup\Logs\netapp.log"
        $LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
        	
		if (! (test-path $OUTFILE))
		{	
            $suppress = mkdir C:\TestDriveSetup\Logs
		}
		
		if (! (test-path HKLM:\SYSTEM\CurrentControlSet\Services\Eventlog\application\NetAppTestDrive) )
		{	New-Eventlog -LogName Application -source NetAppTestDrive
			PostEvent "Creating Eventlog\Application\NetAppTestDrive Eventlog Source" "Warning"
		}
		else
		{	switch -wildcard ($Eventtype)
			{	"Info*" 	{ $color="gray" }
				"Warn*"		{ $color="green" }
				"Err*"		{ $color="yellow" }
				"Cri*"		{ $color="red"
							  $EventType="Error" }
				default		{ $color="gray" }
			}
			if (!(!($verbose) -and ($EventType -eq "Information")))
			{	write-host "- "$textfield -foregroundcolor $color
				Write-Eventlog -LogName Application -Source NetAppTestDrive -EventID 1 -Message $TextField -EntryType $EventType -Computername "." -category 0
                $textfieldwithtime = $LogTime + $textfield
				$textfieldwithtime | out-file -filepath $outfile -append
			}
		}
	}	


PostEvent "Starting ConnectToStorageVM Script" "Information"

#Initiator IQN
$vmiqn = (get-initiatorPort).nodeaddress

Import-Module DataOnTap

connect-nccontroller $mgmtLIF -cred $svmcreds
$iGroupList = Get-ncigroup
$iGroupSetup = $False

#Find if iGroup is already setup, add if not 
foreach($igroup in $iGroupList)
{
    if( $igroup.Name -eq $server)
    {
        $iGroupSetup = $True
        PostEvent "Found $server iGroup is alerady setup on SvM" "Information"
        break
    }
}
if($iGroupSetup -eq $False)
{
    Add-NcIscsiService
    new-ncigroup -name $server -Protocol iScSi -Type Windows    
    Add-NcIgroupInitiator -name $server -Initiator $vmiqn
    PostEvent "Setting up $server iGroup on SvM" "Information"
}

New-IscsiTargetPortal -TargetPortalAddress $dataLIF1
$Tar = get-iscsitarget
connect-iscsitarget -NodeAddress $Tar.NodeAddress -IsMultiPathEnabled $True -IsPersistent $True -TargetPortalAddress $dataLIF1
connect-iscsitarget -NodeAddress $Tar.NodeAddress -IsMultiPathEnabled $True -IsPersistent $True -TargetPortalAddress $dataLIF2

PostEvent "ConnectToStorageVM Script finished" "Information"


