$Server = "8.8.8.8"
$CurrentDirectory = Get-Location 
$LogPath = "$($CurrentDirectory)\pinglog.csv"
$WarningsLogPath = "$($CurrentDirectory)\warnings.log"

$Timeout = 2
$RowCount = 10
Write-Host "Количество строк: $($RowCount)"
$RespTime = 35
Write-Host "Допустимое время ответа: $($RespTime)ms"
$FailureCount = 5
Write-Host "Допустимое количетво потерь пакетов: $($FailureCount)"
$SlowCount = 5 #
Write-Host "Допустимое количетво медленных: $($FailureCount)"

If (-not (Test-Path (Split-Path $LogPath) -PathType Container)){    New-Item (Split-Path $LogPath) -ItemType Directory | Out-Null	}
If (-not (Test-Path $LogPath)) {	Add-Content -Value '"TimeStamp","Source","Destination","IPV4Address","Status","ResponseTime"' -Path $LogPath	}
$Ping = @()
While ($true){   
	$Ping = Get-WmiObject Win32_PingStatus -Filter "Address = '$Server'" | Select @{Label="TimeStamp";Expression={Get-Date}},@{Label="Source";Expression={ $_.__Server }},@{Label="Destination";Expression={ $_.Address }},IPv4Address,@{Label="Status";Expression={ If ($_.StatusCode -ne 0) {"Failed"} Else {"Ok"}}},ResponseTime
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