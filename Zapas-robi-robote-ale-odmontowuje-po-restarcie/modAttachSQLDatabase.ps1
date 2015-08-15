
###########################################################################
# 
# Script to grant system and administrators full access on the databases and log files
#
# Author - Mudassar Shafique
# Version - 1.1
# Last Modified 08/04/2015
#
#############################################################################

#Assembly Imports

$LogFile = "C:\Windows\Panther\netappStorageAttachDB.log"
date >> $LogFile
echo "modAttachSQLDatabase start..." >> $LogFile

[System.Reflection.Assembly]::LoadWithPartialName( 'Microsoft.SqlServer.SMO')| out-null
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMOExtended') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SQLWMIManagement') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Collections.Specialized.StringCollection') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Management.Smo.AttachOptions') | out-null

#Data and Log file paths, set per drive mapping
$datastr = "G:\Adventureworks.mdf"
$logstr = "H:\Adventureworks_log.ldf"

$verbose = $true #for debugging


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

PostEvent "Starting AttachSQLDatabase Script" "Information"

try
{

    $username = "SYSTEM"
    $acl = (Get-Item $datastr).GetAccessControl("Access")
    $accessrule = New-Object system.security.AccessControl.FileSystemAccessRule($username, "FullControl", "None", "None", "Allow")
    $acl.AddAccessRule($accessrule)
    set-acl -aclobject $acl $datastr
    $acl.SetOwner([System.Security.Principal.NTAccount] "SYSTEM")

    $username = "SYSTEM"
    $logstr = "H:\Adventureworks_log.ldf"
    $acl = (Get-Item $logstr).GetAccessControl("Access")
    $accessrule = New-Object system.security.AccessControl.FileSystemAccessRule($username, "FullControl", "None", "None", "Allow")
    $acl.AddAccessRule($accessrule)
    set-acl -aclobject $acl $logstr
    $acl.SetOwner([System.Security.Principal.NTAccount] "SYSTEM")

    PostEvent "Added permissions on data and log file for SYSTEM" "Information"

    $username = "Administrators"
    $acl = (Get-Item $datastr).GetAccessControl("Access")
    $accessrule = New-Object system.security.AccessControl.FileSystemAccessRule($username, "FullControl", "None", "None", "Allow")
    $acl.AddAccessRule($accessrule)
    set-acl -aclobject $acl $datastr
    $acl.SetOwner([System.Security.Principal.NTAccount] ".\Administrators")

    $username = "Administrators"
    $acl = (Get-Item $logstr).GetAccessControl("Access")
    $accessrule = New-Object system.security.AccessControl.FileSystemAccessRule($username, "FullControl", "None", "None", "Allow")
    $acl.AddAccessRule($accessrule)
    set-acl -aclobject $acl $logstr
    $acl.SetOwner([System.Security.Principal.NTAccount] ".\Administrators")

    PostEvent "Added permissions on data and log file for SYSTEM" "Information"



    $srv = new-object Microsoft.SqlServer.Management.Smo.Server("(local)")

    $sc = new-object System.Collections.Specialized.StringCollection
    $sc.Add($datastr)
    $sc.Add($logstr)


    $srv.AttachDatabase("Adventureworks", $sc)
    PostEvent "Attached Adventureworks database" "Information"    
    #end try
}
catch
{
    PostEvent "Error attaching databases" "Error"
    PostEvent $_.exception "Error"
    
    #end catch
}
