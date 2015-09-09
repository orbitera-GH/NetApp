###########################################################################
# 
# Script to Configure Snap Drive
#
# Author - Mudassar Shafique
# Version - 1.0
# Last Modified 08/07/2015
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

#Global variables to be set for this script

$sqlserver = ($env:computername).ToLower()
$LogFile = "C:\Windows\Panther\netappStorageConfigureSnapDrive.log"
date >> $LogFile
echo "modLunMapping start..." >> $LogFile
switch -wildcard ($sqlserver) { 
		"*01" {
			$mgmtLIF = "192.168.250.2"
			$dataLIF1 = "192.168.250.4"
			$dataLIF2 = "192.168.250.5"
			$server = "Server140"
			$Vserver = "aztestdrive140"
			date >> $LogFile
			echo "Hostname is $sqlserver, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
		}
		"*02" {
			$mgmtLIF = "192.168.250.18"
			$dataLIF1 = "192.168.250.20"
			$dataLIF2 = "192.168.250.21"
			$server = "Server141"
			$Vserver = "aztestdrive141"
			date >> $LogFile
			echo "Hostname is $sqlserver, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
		} 
		"*03" {
			$mgmtLIF = "192.168.250.34"
			$dataLIF1 = "192.168.250.36"
			$dataLIF2 = "192.168.250.37"
			$server = "Server142"
			$Vserver = "aztestdrive142"
			date >> $LogFile
			echo "Hostname is $sqlserver, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
		}
		"*04" {
			$mgmtLIF = "192.168.250.50"
			$dataLIF1 = "192.168.250.52"
			$dataLIF2 = "192.168.250.53"
			$server = "Server143"
			$Vserver = "aztestdrive143"
			date >> $LogFile
			echo "Hostname is $sqlserver, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
		}
		"*05" {
			$mgmtLIF = "192.168.250.66"
			$dataLIF1 = "192.168.250.68"
			$dataLIF2 = "192.168.250.69"
			$server = "Server144"
			$Vserver = "aztestdrive144"
			date >> $LogFile
			echo "Hostname is $sqlserver, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
		}
		"*06" {
			$mgmtLIF = "192.168.250.82"
			$dataLIF1 = "192.168.250.84"
			$dataLIF2 = "192.168.250.85"
			$server = "Server145"
			$Vserver = "aztestdrive145"
			date >> $LogFile
			echo "Hostname is $sqlserver, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
		}
		"*07" {
			$mgmtLIF = "192.168.250.98"
			$dataLIF1 = "192.168.250.100"
			$dataLIF2 = "192.168.250.101"
			$server = "Server146"
			$Vserver = "aztestdrive146"
			date >> $LogFile
			echo "Hostname is $sqlserver, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
		}
		"*08" {
			$mgmtLIF = "192.168.250.114"
			$dataLIF1 = "192.168.250.116"
			$dataLIF2 = "192.168.250.117"
			$server = "Server147"
			$Vserver = "aztestdrive147"
			date >> $LogFile
			echo "Hostname is $sqlserver, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
		}
		"*09" {
			$mgmtLIF = "192.168.250.130"
			$dataLIF1 = "192.168.250.132"
			$dataLIF2 = "192.168.250.133"
			$server = "Server148"
			$Vserver = "aztestdrive148"
			date >> $LogFile
			echo "Hostname is $sqlserver, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
		}
		"*10" {
			$mgmtLIF = "192.168.250.146"
			$dataLIF1 = "192.168.250.148"
			$dataLIF2 = "192.168.250.149"
			$server = "Server149"
			$Vserver = "aztestdrive149"
			date >> $LogFile
			echo "Hostname is $sqlserver, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
		}
		default {date >> $LogFile ; echo "### ERROR can't determine management LIF IP address for VMname: $sqlserver"  >> $LogFile}
	}

#$mgmtLIF = "192.168.250.34"
#$sqlserver = "sqltestdrive03b"
#$Vserver = "aztestdrive142"

$file = "C:\Windows\System32\drivers\etc\hosts"

function add-host([string]$filename, [string]$ip, [string]$hostname) {

	$ip + "`t`t" + $hostname | Out-File -encoding ASCII -append $filename
}


#Logging function
function PostEvent([String]$TextField, [string]$EventType)
	{	# Subroutine to Post Events to Log/Screen/EventLog
		$outfile = "C:\TestDriveSetup\netapp.log"
        $outdir = "C:\TestDriveSetup"
        $LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
        	
		if (! (test-path $outdir))
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
    if ( (Get-SdStorageConnectionSetting -Host $sqlserver).Name -eq $mgmtLIF )
    {
        PostEvent "$mgmtLIF is alerady configured in SnapDrive for $sqlserver" "Information"
    }
    else
    {
        add-host $file $mgmtLIF $Vserver
        PostEvent "Added mgmt LIF IP $mgmtLIF with $vserver to the host file" "Information"
        set-sdstorageConnectionSetting -StorageSystem $mgmtLIF -Credential $svmcreds
        PostEvent "Configured SnapDrive for $mgmtLIF" "Information"
    }

    exit 1
}
catch
{
    PostEvent $_.exception "Error"
    
    exit 0
}
