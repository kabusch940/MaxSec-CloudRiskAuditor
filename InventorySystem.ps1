## Inveotry System ArrayLists

$dbServers              = [System.Collections.ArrayList]@("databaseServer1", "databaseServer2", "databaseServer3")
$fileServers            = [System.Collections.ArrayList]@("fileserver1", "fileserver2", "fileserver3")
$DCs                    = [System.Collections.ArrayList]@("DC1")
$unclassifiedServers    = [System.Collections.ArrayList]@()


# Input New Servers

[string]$newServerInput = Read-Host "Enter Servers to be added to the inventory (Comma seperated), or press Enter to skip"


# Add New Server to Inventory and Check Duplicates

if($newServerInput){
    $newServers = $newServerInput -split ',' | ForEach-Object { $_.Trim().ToLower() } | Where-Object { $_ -ne '' }
    foreach($newServer in $newServers){
    if ($fileServers -contains $newServer -or
            $DCs -contains $newServer -or
            $dbServers -contains $newServer -or
            $unclassifiedServers -contains $newServer) {
            
            Write-Host "$newServer already exists. Skipped."
            continue
        }
    elseif ($newServer -like "*file*") {
        $fileServers.Add($newServer) | Out-Null
        Write-Host $newServer "added to Fileservers"
    } elseif($newServer -like "*dc*") {
        $DCs.Add($newServer) | Out-Null
        Write-Host $newServer "added to DCs"
    } elseif ($newServer -like "*db*") {
        $dbServers.Add($newServer) | Out-Null
        Write-Host $newServer "added to DBServers"
    } else {
        $unclassifiedServers += $newServer | Out-Null
        Write-Host $newServer "is unclassified."
    }
}
} 







