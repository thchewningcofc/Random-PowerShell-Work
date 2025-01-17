﻿function Get-ClientsUnderNoSite
{
	[CmdletBinding()]
	param ()
	try
	{
		## Find all DCs in the forest
		$dcs = ((Get-ADForest).Domains | ForEach-Object { (Get-ADDomainController -Server $_ -Filter *) }).HostName
		foreach ($d in $dcs)
		{
			$output = @{'DomainController' = $d}

			$clients = Select-String -Pattern 'NO_CLIENT_SITE: (.*) \d' -Path "\\$d\c$\windows\debug\netlogon.log" | ForEach-Object {
				$_.Matches.Groups[1].Value
			} | Group-Object
			if ($clients)
			{
				$clients | ForEach-Object {
					$output.Client = $_.Name
					[pscustomobject]$output
				}
			}
		}
		
	}
	catch
	{
		Write-Error -Message $_.Exception.Message
	}
}