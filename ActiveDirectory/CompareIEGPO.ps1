#requires -version 3

[xml]$golden_gpo = Get-Content '.\IE Settings.xml'
$gpos = Get-GPOReport -All -ReportType XML

$golden_gpo_computer_registry_settings = ($golden_gpo.GPO.Computer.ExtensionData | Where-Object {$_.Name -eq 'Registry'}).childNodes.Policy | Select-Object name,state
$golden_gpo_user_ie_pref_settings = ($golden_gpo.GPO.User.ExtensionData | Where-Object {$_.Name -eq 'Internet Options'}).childNodes.InternetOptions.IE8.Properties.Reg
$golden_computer_ie_settings = ($golden_gpo.GPO.Computer.ExtensionData | Where-Object { $_.Name -eq 'Registry' }).childNodes.Policy | Where-Object {$_.Category -like 'Windows Components/Internet Explorer*'} | Select-Object name,state

foreach ($gpo in $gpos){
    [xml]$gpo = $gpo

    $gpo_computer_registry_settings = ($gpo.GPO.Computer.ExtensionData | Where-Object {$_.Name -eq 'Registry'}).childNodes.Policy | Select-Object name,state
    $gpo_user_ie_pref_settings = ($gpo.GPO.User.ExtensionData | Where-Object {$_.Name -eq 'Internet Options'}).childNodes.InternetOptions.IE8.Properties.Reg
    if ($gpo_computer_registry_settings) {
        $Compare = Compare-Object -ReferenceObject $gpo_computer_registry_settings -DifferenceObject $golden_gpo_computer_registry_settings -Property Name -IncludeEqual -PassThru | Where-Object {$_.SideIndicator -eq '=='}
        if ($Compare) {
            $Compare | ForEach-Object {
                $properties = @{'MatchingGPO' = $gpo.GPO.Name; 'GPOSetting' = 'Computer'; 'CompareType' = 'Match'; 'Setting' = "$($_.Name) = $($_.State)"}
                New-Object -TypeName PSObject -Property $properties    
            } | Export-Csv Matching-IE-GPO-Settings.txt -NoTypeInformation -Append
        }

    }
    if ($gpo_user_ie_pref_settings) {
        $Compare = Compare-Object -ReferenceObject $gpo_user_ie_pref_settings -DifferenceObject $golden_gpo_user_ie_pref_settings -Property Name -IncludeEqual -PassThru | Where-Object {$_.SideIndicator -eq '=='}
        if ($Compare) {
            $Compare | ForEach-Object {
                $properties = @{'MatchingGPO' = $gpo.GPO.Name; 'GPOSetting' = 'User'; 'CompareType' = 'Match'; 'Setting' = "$($_.Key)\$($_.Name)"}
                New-Object -TypeName PSObject -Property $properties    
            } | Export-Csv Matching-IE-GPO-Settings.txt -NoTypeInformation -Append
        }
        
        $Compare = Compare-Object -ReferenceObject $gpo_user_ie_pref_settings -DifferenceObject $golden_gpo_user_ie_pref_settings -Property Name -PassThru | Where-Object {$_.SideIndicator -eq '=>'}
        if ($Compare) {
            $Compare | ForEach-Object {
                $properties = @{'MatchingGPO' = $gpo.GPO.Name; 'GPOSetting' = 'User'; 'CompareType' = 'Difference'; 'Setting' = "$($_.Key)\$($_.Name)"}
                New-Object -TypeName PSObject -Property $properties    
            } | Export-Csv Matching-IE-GPO-Settings.txt -NoTypeInformation -Append
        } 
    }

    $diff_computer_ie_settings = ($gpo.GPO.Computer.ExtensionData | Where-Object { $_.Name -eq 'Registry' }).childNodes.Policy | Where-Object {$_.Category -like 'Windows Components/Internet Explorer*'} | Select-Object name,state
    if ($diff_computer_ie_settings) {
        $Compare = Compare-Object -ReferenceObject $golden_computer_ie_settings -DifferenceObject $diff_computer_ie_settings -Property name -PassThru | Where-Object {$_.SideIndicator -eq '=>'}
        if ($Compare) {
            $Compare | ForEach-Object {
                $properties = @{'MatchingGPO' = $gpo.GPO.Name; 'GPOSetting' = 'Computer'; 'CompareType' = 'Difference'; 'Setting' = "$($_.Name) = $($_.State)"}
                New-Object -TypeName PSObject -Property $properties    
            } | Export-Csv Matching-IE-GPO-Settings.txt -NoTypeInformation -Append
        }  
    }
}