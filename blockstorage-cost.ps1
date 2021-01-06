$date = (Get-Date -UFormat "%Y-%m-%d-%H-%M-%S").ToString()
$Filename1 = "blockstoragedetail -" + $date + '.csv';
$2iop = 0.0957
$4iop = 0.116
$10iop = 0.37115
$25iop = 0.0428
$costo = 0
$pu = 0
$max = 0
#sacar información de los filestorage

function Get-BSinfo {
    $bn = ibmcloud sl block volume-detail $id.id --output json | ConvertFrom-Json
    if ($bn.storageTierLevel -eq "READHEAVY_TIER")
    {$iops ="2"
     $pu = $2iop
     $costo = $pu * [int]$id.capacityGb
     $max = [int]$id.capacityGb * [int]$iops }
    if ($bn.storageTierLevel -eq "10_IOPS_PER_GB")
    {$iops ="10"
     $pu = $10iop
     $costo = $pu * [int]$id.capacityGb
     $max = [int]$id.capacityGb * [int]$iops }
    if ($bn.storageTierLevel -eq "WRITEHEAVY_TIER")
    {$iops ="4"
     $pu = $4iop
     $costo = $pu * [int]$id.capacityGb
     $max = [int]$id.capacityGb * [int]$iops }
     if ($bn.storageTierLevel -eq "LOW_INTENSITY_TIER")
    {$iops ="0.25"
     $pu = $25iop
     $costo = $pu * [int]$id.capacityGb
     $max = [int]([int]$id.capacityGb * [decimal]$iops) }
    $bsinfo = [PSCustomObject]@{
        'Name' = $bn.username
        'Quien Paga' = ""
        'Costo' = $costo
        'Location' = $id.serviceResource.datacenter.name
        'Status' = "Active"
        'Type' = $bn.storageTierLevel
        'IOPS' = $iops
        'p.u x gb' = $pu
        'Max IOPS' = $max
        'Capacidad en GB' = $id.capacityGb
        'Target address' = $bn.serviceResourceBackendIpAddress
        'Ubicacion' =""
        'Plataforma' =""
        'Cliente' =""
        'Tipo' =""
        'Componente' =""
        'Ambiente' = ""
        'Numeración' =""
    }
    $bsinfo | Export-Csv -NoTypeInformation -Path  $Filename1 -Encoding UTF8 -Append -Force;
    
} 
foreach ($id in (ibmcloud sl block volume-list --output json | ConvertFrom-Json))
{
    Get-BSinfo
}

