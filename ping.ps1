[CmdletBinding()]
Param (
    
    [int32]$Timeout = 2,
    [String]$Server = "64.233.165.101",
    [string]$LogPath = "$(Get-Location)\pinglog.csv",
    [string]$WarningsLogPath = "$(Get-Location)\warnings.log",
    [int32]$RowCount = 10,
    [int32]$RespTime = 30,
    [int32]$FailureCount = 5,
    [int32]$SlowCount = 5
)

[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("cp866")
Write-Host "Количество строк: $($RowCount)"
Write-Host "Допустимое время ответа: $($RespTime)ms"
Write-Host "Допустимое количетво потерь пакетов: $($FailureCount)"
Write-Host "Допустимое количетво медленных: $($FailureCount)"

If (-not (Test-Path (Split-Path $LogPath) -PathType Container)){    New-Item (Split-Path $LogPath) -ItemType Directory | Out-Null	}
If (-not (Test-Path (Split-Path $WarningsLogPath) -PathType Container)){    New-Item (Split-Path $WarningsLogPath) -ItemType Directory | Out-Null	}
If (-not (Test-Path $LogPath)) {	Add-Content -Value '"TimeStamp","Source","Destination","IPV4Address","Status","ResponseTime"' -Path $LogPath	}
$Ping = @()
While ($true){   
	try{
		$Ping = Get-WmiObject Win32_PingStatus -Filter "Address = '$Server'" | Select @{Label="TimeStamp";Expression={Get-Date}},@{Label="Source";Expression={ $_.__Server }},@{Label="Destination";Expression={ $_.Address }},IPv4Address,@{Label="Status";Expression={ If ($_.StatusCode -ne 0) {"Failed"} Else {"Ok"}}},ResponseTime
    }
	catch {
	
	}
	$Result = $Ping | Select TimeStamp,Source,Destination,IPv4Address,Status,ResponseTime | ConvertTo-Csv -NoTypeInformation
    $Result[1] | Add-Content -Path $LogPath
	
	$TmpFailureCount = 0
	$TmpSlowCount = 0
	$LastStrings = Get-Content $LogPath | select -Last $RowCount

	ForEach ($line in $LastStrings){
		If (-not($line.Split(",")[5] -like "*ResponseTime*")) {	
			If ($RespTime -lt [int]$line.Split(",")[5].trim('"')) {	$TmpSlowCount ++ }
		}
		If (-not($line.Split(",")[4] -like "*Status*")) {	
			If ($line.Split(",")[4] -like "*Failed*") {	$TmpFailureCount ++	}
		}
    }
	If ($FailureCount -lt $TmpFailureCount) {
		"$(Get-Date) Потеряно $($TmpFailureCount) пакетов за последние $($Timeout * $RowCount) секунд" | Add-Content -Path $WarningsLogPath
	}
	If ($SlowCount -lt $TmpSlowCount) {
		"$(Get-Date) Время отклика более $($RespTime)ms за последние $($Timeout * $RowCount) секунд" | Add-Content -Path $WarningsLogPath
	}
    Start-Sleep -Seconds $Timeout
}
