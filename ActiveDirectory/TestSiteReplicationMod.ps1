Write-Output "Starting replication test..."
Write-Output "-----------"
#Set-AdUser abertram -Server xxxx -Description "xxxxx"
Set-ADAccountPassword abertramtest -NewPassword (ConvertTo-SecureString 'p@$$w0rd14' -AsPlainText -Force) -Reset -Server XXXX
$passwordlastset = (Get-Aduser abertramtest -Properties passwordlastset -Server XXXX).passwordlastset
Write-Host "Waiting for replication..." -ForegroundColor Yellow
$i = 0
do { 
    $i++
    Start-Sleep 1
#} while ((Get-AdUser abertram -Properties description -Server DC01).description -ne "Keller Schroeder Vendor - Set on UAPDC01")
} while ((Get-Aduser abertramtest -Properties passwordlastset -Server DC01).passwordlastset -ne $passwordlastset)

Write-Host "Replication from XXXX from XXXX successful.  Replication time: $i seconds ($($i / 60) minutes)" -ForegroundColor Green


Write-Output "Starting replication test..."
Write-Output "-----------"
Write-Host "Waiting for replication from XXXXX to XXXX..." -ForegroundColor Yellow
Set-ADAccountPassword XXXXX -NewPassword (ConvertTo-SecureString 'p@$$w0rd15' -AsPlainText -Force) -Reset -Server XXXX
$passwordlastset = (Get-Aduser XXXX -Properties passwordlastset -Server DC01).passwordlastset
$i = 0
do { 
    $i++
    Start-Sleep 1
} while ((Get-Aduser XXXXX -Properties passwordlastset -Server XXXXX).passwordlastset -ne $passwordlastset)

Write-Host "Replication from XXXX from XXXXX successful. Replication time: $i seconds ($($i / 60) minutes)" -ForegroundColor Green


Set-AdUser XXXXX -Server XXXX -Description "XXXXXX"

Write-Output '-----------'
Write-Output 'Checking last replication status between XXXX and XXXX sites...'
Write-Output "-----------"
Get-ADReplicationLink -SiteName xxxxx | Where-Object { $_.sourceserver -eq 'XXXX' } | Select-Object sourceserver,destinationserver,LastSuccessfulsync,lastsyncmessage
Get-ADReplicationLink -SiteName xxxx | Where-Object { $_.sourceserver -eq 'XXXX' } | Select-Object sourceserver,destinationserver,LastSuccessfulsync,lastsyncmessage
