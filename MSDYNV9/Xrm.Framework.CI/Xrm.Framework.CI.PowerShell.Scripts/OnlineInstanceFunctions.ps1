#
# OnlineInstanceFunctions.ps1
#

$ErrorActionPreference = "Stop"

Write-Verbose 'Entering OnlineInstanceFunctions.ps1'

function Get-XrmInstanceByName(
	[String]$ApiUrl,
	[Object]$Cred,
	[String]$InstanceName)
{
	$instances = Get-CrmInstances -ApiUrl $ApiUrl -Credential $Cred

	Foreach($instance in $instances)
	{
		if ($instance.DomainName -ieq $InstanceName)
		{
			Write-Output($instance)
			return
		}
	}
}

function Get-XrmBackupByLabel(
	[String]$ApiUrl,
	[Object]$Cred,
	[String]$InstanceId,
	[String]$Label)
{
	$backups = Get-CrmInstanceBackups -ApiUrl $ApiUrl -Credential $Cred -InstanceId $InstanceId

	$backup = $backups | Sort CreatedOn -Descending | Where-Object {$_.Label -eq $Label}

	if ($backup.length -eq 1)
	{
		return $backup
	}
	elseif($backup.length > 1)
	{
		throw "More than one backup found for Label $Label"
	}
	else
	{
		return $null
	}
}

function Wait-XrmBackup(
	[String]$ApiUrl,
	[Object]$Cred,
	[String]$InstanceId,
	[String]$Label,
	[Int]$SleepDuration = 5
)
{
	$completed = $false
	Write-Host "Waiting for backup with label $Label to complete..."

	while ($completed -eq $false)
	{
		Start-Sleep -Seconds $SleepDuration
		
		$backup = Get-XrmBackupByLabel -ApiUrl $ApiUrl -Cred $Cred -InstanceId $InstanceId -Label $Label

		if ($backup -eq $null)
		{
			throw "No backup found for Label $Label"
		}
		else
		{
			Write-Host "Backup Status: $($backup.Status)"

			if ($backup.Status -eq 'Available')
			{
				Write-Output($backup)
				$completed = $true
				return
			}
		}
	}
}

function Wait-XrmOperation(
	[String]$ApiUrl,
	[Object]$Cred,
	[String]$OperationId,
	[Int]$SleepDuration = 5
)
{
	$completed = $false
	Write-Host "Waiting for completion...$OperationId"

	while ($completed -eq $false)
	{	
		Start-Sleep -Seconds $SleepDuration
    
		$OpStatus = Get-CrmOperationStatus -ApiUrl $ApiUrl -Credential $Cred -Id $OperationId

		$OperationStatus = $OpStatus.Status
    
		Write-Host "Asyn Operation Status = $OperationStatus" -ForegroundColor DarkYellow

		if ($OperationStatus -notin "None", "NotStarted", "Ready", "Pending", "Running", "Deleting", "Aborting", "Cancelling")
		{
            Write-Output($OpStatus)
			$completed = $true
			return
		}
	}
}

Write-Verbose 'Leaving OnlineInstanceFunctions.ps1'