################################################
# SnapManager Configuration Import Script
###############################################

#
#	DEVEL
#
#	DEVEL
#
#	DEVEL
#
######################################################

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
    exit 1
}
catch
{
    PostEvent "Error in ConfigureSnapManager Script" "Error"
    PostEvent $_.exception "Error"
    exit 0
}


