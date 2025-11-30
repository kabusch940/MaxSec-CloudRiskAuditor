## Inventory System ArrayLists

$dbServers              = [System.Collections.ArrayList]@()
$fileServers            = [System.Collections.ArrayList]@()
$DCs                    = [System.Collections.ArrayList]@()
$unclassifiedServers    = [System.Collections.ArrayList]@()

## Test if Inventory exists in current path

$WD = Get-Location
$inventoryExists = Test-Path ".\InventoryList.json"

## Create Inventory

if($inventoryExists){
    Write-Host "Inventory was found at:" $WD
    $jsonData = Get-Content -Path ".\InventoryList.json" -Raw
    $inventoryObject = $jsonData | ConvertFrom-Json
    Write-Host "Inventory JSON successfully loaded."
} else {
    $createInventory = Read-Host "Inventory Liste nicht gefunden. Soll eine neue erstellt werden? (J/N)"

    if ($createInventory -match "^[Jj]$") {

        # Create JSON Object
        $inventoryObject = @{
            fileServers         = @()
            dbServers           = @()
            DCs                 = @()
            unclassifiedServers = @()
            LastUpdated         = (Get-Date)
        }

        # Write JSON to File
        $inventoryObject |
            ConvertTo-Json -Depth 5 |
            Set-Content -Path ".\InventoryList.json"

        Write-Host "InventoryList.json was created at" $WD
    }
    else {
        Write-Host "No Inventory List was found"
        exit
    }
}


## Add Data to ArrayLists

if($inventoryExists){
$fileServers.AddRange($inventoryObject.fileServers)
$dbServers.AddRange($inventoryObject.dbServers)
$DCs.AddRange($inventoryObject.DCs)
$unclassifiedServers.AddRange($inventoryObject.unclassifiedServers)
}


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


$inventoryObject = @{
    fileServers         = $fileServers
    dbServers           = $dbServers
    DCs                 = $DCs
    unclassifiedServers = $unclassifiedServers
    LastUpdated         = (Get-Date)
}

$inventoryObject |
    ConvertTo-Json -Depth 5 |
    Set-Content ".\InventoryList.json"

Write-Host "Current Inventory is:"

$inventoryObject


