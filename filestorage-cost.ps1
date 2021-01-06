$date = (Get-Date -UFormat "%Y-%m-%d-%H-%M-%S").ToString()
$Filename1 = "filestoragedetail -" + $date + '.csv';
$2iop = 0.0957
$4iop = 0.116
$10iop = 0.37115
$costo = 0
$pu = 0
$max = 0
#sacar información de los filestorage

function Get-FSinfo {
    $bn = ibmcloud sl file volume-detail $id.id --output json | ConvertFrom-Json
    $bytes = $bn.bytesUsed
    $gb = [long]$bytes / 1000000000
    $porcent = [int](([int]$gb / [int]$id.capacityGb) * 100)
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
    $fsinfo = [PSCustomObject]@{
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
        'Usage in Porcentaje' = $porcent
        'Ubicacion' =""
        'Plataforma' =""
        'Cliente' =""
        'Tipo' =""
        'Componente' =""
        'Ambiente' = ""
        'Numeración' =""
    }
    $fsinfo | Export-Csv -NoTypeInformation -Path  $Filename1 -Encoding UTF8 -Append -Force;
    
} 
foreach ($id in (ibmcloud sl file volume-list --output json | ConvertFrom-Json))
{
    Get-FSinfo
}

