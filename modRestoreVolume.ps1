
###########################################################################
# Script to restore the volumes back to original using SnapShots
#
# Returns 1 if all volumes are successfully restored, 0 if restore is not successful
#
# Author - Mudassar Shafique
# Version - 1.2
# Last Modified 08/07/2015
#
#############################################################################

$SqlServerName = ($env:computername).ToLower()
$LogFile = "C:\Windows\Panther\netappStorage.log"
$PermissionFile = "C:\Windows\Panther\AllowToDisconnectStorage.yes"

date >> $LogFile
echo "Starting script modRestoreVolume.ps1..." >> $LogFile

date >> $LogFile
	echo "File $PermissionFile was detected. Start  Netapp RestoreVolume procedure." >> $LogFile
	switch -wildcard ($SqlServerName) { 
			"*01" {
				$mgmtLIF = "192.168.250.2"
				$server = "Server140"
				date >> $LogFile
				echo "Hostname is $SqlServerName, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
			}
			"*02" {
				$mgmtLIF = "192.168.250.18"
				$server = "Server141"
				date >> $LogFile
				echo "Hostname is $SqlServerName, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
			} 
			"*03" {
				$mgmtLIF = "192.168.250.34"
				$server = "Server142"
				date >> $LogFile
				echo "Hostname is $SqlServerName, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
			}
			"*04" {
				$mgmtLIF = "192.168.250.50"
				$server = "Server143"
				date >> $LogFile
				echo "Hostname is $SqlServerName, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
			}
			"*05" {
				$mgmtLIF = "192.168.250.66"
				$server = "Server144"
				date >> $LogFile
				echo "Hostname is $SqlServerName, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
			}
			"*06" {
				$mgmtLIF = "192.168.250.82"
				$server = "Server145"
				date >> $LogFile
				echo "Hostname is $SqlServerName, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
			}
			"*07" {
				$mgmtLIF = "192.168.250.98"
				$server = "Server146"
				date >> $LogFile
				echo "Hostname is $SqlServerName, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
			}
			"*08" {
				$mgmtLIF = "192.168.250.114"
				$server = "Server147"
				date >> $LogFile
				echo "Hostname is $SqlServerName, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
			}
			"*09" {
				$mgmtLIF = "192.168.250.130"
				$server = "Server148"
				date >> $LogFile
				echo "Hostname is $SqlServerName, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
			}
			"*10" {
				$mgmtLIF = "192.168.250.146"
				$server = "Server149"
				date >> $LogFile
				echo "Hostname is $SqlServerName, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
			}
			default {date >> $LogFile ; echo "### ERROR can't determine management LIF IP address for VMname: $SqlServerName"  >> $LogFile}
		}

# Set these variables per each storage virtual machine
#$mgmtLIF = "192.168.250.34"
#$server = "server142"
$secpasswd = ConvertTo-SecureString "Orbitera123!" -AsPlainText -Force
$svmcreds = New-Object System.Management.Automation.PSCredential ("vsadmin", $secpasswd)	

$datalun = "/vol/sql_data/data_lun_001"
$loglun = "/vol/sql_log/log_lun_001"
$snapinfolun = "/vol/sql_snapinfo/snapinfo_lun_001"


$verbose = $true #for debugging

#Function to write logs
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
                $textfieldwithtime = $LogTime +"-" +$textfield
				$textfieldwithtime | out-file -filepath $outfile -append
			}
		}
	}	


PostEvent "Starting RestoreVolume Script" "Information"



Import-Module DataOnTap
connect-nccontroller $mgmtLIF -cred $svmcreds


try
{
     
     PostEvent "Taking SnapDrive Volumes Offline and Removing" "Information"

     get-ncvol | where {$_.Name -like "sdw*" } | set-ncvol -Offline
     get-ncvol | where {$_.Name -like "sdw*" } | remove-ncvol -confirm:$false

     $lastModified = read-ncdirectory -path /vol/sql_data | where-object {$_.Name -eq "data_lun_001"} | Select-Object Modified

     restore-ncsnapshotvolume sql_data baseline -PreserveLunIds -Confirm:$false

     $NewModified = read-ncdirectory -path /vol/sql_data | where-object {$_.Name -eq "data_lun_001"} | Select-Object Modified

     if ($lastModified.Modified -eq $NewModified.Modified)
     {
            PostEvent "Problem restoring sql_data volume" "Error"
            exit 0 
     }

     $lastModified = read-ncdirectory -path /vol/sql_log | where-object {$_.Name -eq "log_lun_001"} | Select-Object Modified

     restore-ncsnapshotvolume sql_log baseline -PreserveLunIds -Confirm:$false

     $NewModified = read-ncdirectory -path /vol/sql_log | where-object {$_.Name -eq "log_lun_001"} | Select-Object Modified

     if ($lastModified.Modified -eq $NewModified.Modified)
     {
            PostEvent "Problem restoring sql_log volume" "Error"
            exit 0 
     }
     
     
     $lastModified = read-ncdirectory -path /vol/sql_snapinfo | where-object {$_.Name -eq "snapinfo_lun_001"} | Select-Object Modified
     
     restore-ncsnapshotvolume sql_snapinfo baseline -PreserveLunIds -Confirm:$false

     $NewModified = read-ncdirectory -path /vol/sql_snapinfo | where-object {$_.Name -eq "snapinfo_lun_001"} | Select-Object Modified

     if ($lastModified.Modified -eq $NewModified.Modified)
     {
            PostEvent "Problem restoring sql_snapinfo volume" "Error"
            exit 0 
     }

     PostEvent "All volumes successfully restored" "Information"

     
     #Remove Lun Maps

     get-nclunmap | remove-nclunmap -Confirm:$false

    

     PostEvent "Removed Lun Mapping" "Information"

     exit 1

    #end try
}
catch
{
    PostEvent $_.exception "Error"
    
    exit 0
    #end catch
}

