
###########################################################################
# 
# Script to connect to SVM from SQL Virtual Machine
#
# Author - Mudassar Shafique
# Version - 1.2
# Last Modified 08/07/2015
#
#############################################################################


#set these variables per the storage virtual machine

$SqlServerName = ($env:computername).ToLower()
$LogFile = "C:\Windows\Panther\netappStorageConnectToStorage.log"
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


function CheckService([String]$ServiceName)
{
    
    $arrService = Get-Service -Name $ServiceName
    if ($arrService.Status -ne "Running"){
        Start-Service $ServiceName
        PostEvent "Starting  $ServiceName  service" "Information"
    }
    if ($arrService.Status -eq "running"){ 
        PostEvent "$ServiceName service is already started" "Information"
    }
}


try
{
    PostEvent "Starting ConnectToStorageVM Script" "Information"

    CheckService("MSiSCSI")

    #Initiator IQN
    $vmiqn = (get-initiatorPort).nodeaddress

    Import-Module DataOnTap

    connect-nccontroller $mgmtLIF -cred $svmcreds
    $iGroupList = Get-ncigroup
    $iGroupSetup = $False

    #Find if iGroup is already setup, add if not 
    foreach($igroup in $iGroupList)
    {
        if ($igroup.Name -eq $server)   
        {
            foreach($initiator in $igroup.Initiators)
            {
                if($initiator.InitiatorName.Equals($vmiqn))
                {
                    $iGroupSetup = $True
                    PostEvent "Found $server iGroup is alerady setup on SvM with IQN: $vmiqn" "Information"
                    break
                }
            }
        }
    }
    if($iGroupSetup -eq $False)
    {
    
        if ((get-nciscsiservice).IsAvailable -ne "True") { Add-NcIscsiService }    
        new-ncigroup -name $server -Protocol iScSi -Type Windows    
        Add-NcIgroupInitiator -name $server -Initiator $vmiqn
        PostEvent "Setting up $server iGroup on SvM" "Information"
    }

    New-IscsiTargetPortal -TargetPortalAddress $dataLIF1
    $Tar = get-iscsitarget
    connect-iscsitarget -NodeAddress $Tar.NodeAddress -IsMultiPathEnabled $True  -TargetPortalAddress $dataLIF1
    connect-iscsitarget -NodeAddress $Tar.NodeAddress -IsMultiPathEnabled $True  -TargetPortalAddress $dataLIF2

    PostEvent "ConnectToStorageVM Script finished" "Information"
    #exit 1

}
catch
{
     PostEvent "Error in ConnectToStorageVM Script" "Error"
     PostEvent $_.exception "Error"
     #exit 0
}

#### 2


###########################################################################
# 
# Script to Map Luns to the Windows Host
#
# Author - Mudassar Shafique
# Version - 1.1
# Last Modified 08/04/2015
#
#############################################################################

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

    #exit 1
}
catch
{
    PostEvent $_.exception "Error"
    
    #exit 0
}
		   
### 3


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

### 4

###########################################################################
# 
# Script to Configure Snap Drive
#
# Author - Mudassar Shafique
# Version - 1.0
# Last Modified 08/07/2015
#
#############################################################################

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

    #exit 1
}
catch
{
    PostEvent $_.exception "Error"
    
    #exit 0
}

### 5

################################################
# SnapManager Configuration Import Script
###############################################

#$SMSQLConfig = "C:\NetApp\SMSQLConfig.xml"
$SMSQLConfig = "C:\Windows\OEM\SMSQLConfig.xml"
#$sqlserver = "sqltestdrive03b"
$sqlserver = ($env:computername).ToLower()

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



try{
    PostEvent "Starting ConfigureSnapManager Script" "Information"

    # Update the config file
    (gc $SMSQLConfig).replace('WINSQL', $sqlserver) | sc $SMSQLConfig

    # Load SnapManager for SQL PowerShell Snap In
    Add-PSSnapin -Name NetApp.SnapManager.SQL.PS.Admin

    import-config -Server $sqlserver -ControlFilePath $SMSQLConfig -ValidateAndApply

    PostEvent "Imported SnapManager configuration" "Information"
    #exit 1
}
catch
{
    PostEvent "Error in ConfigureSnapManager Script" "Error"
    PostEvent $_.exception "Error"
    #exit 0
}



