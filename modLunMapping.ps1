
###########################################################################
# 
# Script to Map Luns to the Windows Host
#
# Author - Mudassar Shafique
# Version - 1.1
# Last Modified 08/04/2015
#
#############################################################################

#
#	DEVEL
#
#	DEVEL
#
#	DEVEL
#
######################################################

#Global variables to be set per the storage virtual machine setting

$SqlServerName = ($env:computername).ToLower()
$LogFile = "C:\Windows\Panther\netappStorageLunMapping.log"
date >> $LogFile
echo "modLunMapping start..." >> $LogFile
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
#$sqlserver = "sqltestdrive03b"


$verbose = $true #for debugging

$secpasswd = ConvertTo-SecureString "Orbitera123!" -AsPlainText -Force
$svmcreds = New-Object System.Management.Automation.PSCredential ("vsadmin", $secpasswd)			   
Import-Module DataOnTap   
connect-nccontroller $mgmtLIF -cred $svmcreds
function PostEvent([String]$TextField, [string]$EventType)
	{	# Subroutine to Post Events to Log/Screen/EventLog
		$outfile = "C:\TestDriveSetup\netapp.log"
        $LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
        	
		if (! (test-path $OUTFILE))
		{	
            $suppress = mkdir C:\TestDriveSetup
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



try
{
    PostEvent "Starting LunMapping Script" "Information"
    PostEvent "Mapping Luns on the Server" "Information"

    add-nclunmap /vol/sql_data/data_lun_001 $server
    add-nclunmap /vol/sql_log/log_lun_001 $server
    add-nclunmap /vol/sql_snapinfo/snapinfo_lun_001 $server


    Start-NcHostDiskRescan; Wait-NcHostDisk  -SettlingTime 5000
    #Start-NcHostDiskRescan; Wait-NcHostDisk  -SettlingTime 5000
    #Start-NcHostDiskRescan; Wait-NcHostDisk  -SettlingTime 5000

    PostEvent "Disk Scan finished" "Information"


    $DataDisk = (get-nchostdisk | Where-Object {$_.ControllerPath -like "*sql_data*"}).Disk
    $LogDisk = (get-nchostdisk | Where-Object {$_.ControllerPath -like "*sql_log*"}).Disk
    $SnapInfoDisk = (get-nchostdisk | Where-Object {$_.ControllerPath -like "*sql_snapinfo*"}).Disk

    if (!(test-path "G:" )) { Add-PartitionAccessPath -DiskNumber $DataDisk -AccessPath G: -PartitionNumber 2 }
    if (!(test-path "H:" )) { Add-PartitionAccessPath -DiskNumber $LogDisk -AccessPath H: -PartitionNumber 2 }
    if (!(test-path "I:" )) { Add-PartitionAccessPath -DiskNumber $SnapInfoDisk -AccessPath I: -PartitionNumber 2 }

    PostEvent "Assigned Drive Letters" "Information"


    PostEvent "Finished LunMapping " "Information"

    exit 1
}
catch
{
    PostEvent $_.exception "Error"
    
    exit 0
}
		   
