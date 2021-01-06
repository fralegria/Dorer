$date = (Get-Date -UFormat "%Y-%m-%d-%H-%M-%S").ToString()
$Filename1 = "OSDetailBM -" + $date + '.csv';
$Filename2 = "OSDetailVS -" + $date + '.csv';

#Saca info BM

function Get-OSinfoBM {
    $OSinfo = [PSCustomObject]@{
        'Type'= 'Bare Metal'
        'Devide ID' = $hwd.id
        'Hostname' = $hwd.hostname
        'Dominio'=$hwd.domain
        'Status' = $hwd.hardwareStatus.status
        'ProvisionDate' = $hwd.provisionDate
        'Datacenter'=$hwd.datacenter.longName
        'O.S' = $hwd.operatingSystem.softwareLicense.softwareDescription.name
        'O.S Version' = $hwd.operatingSystem.softwareLicense.softwareDescription.version
        'IP Privada' = $hwd.primaryBackendIpAddress
        'IP Publica' = $hwd.primaryIpAddress
        'Cloud Provider' = "IBM Cloud"
    }
    $OSinfo | Export-Csv -NoTypeInformation -Path  $Filename1 -Encoding UTF8 -Append -Force;
} 

#Saca info VS

function Get-OSinfoVS {
    $OSinfo = [PSCustomObject]@{
        'Type'= 'Virtual Server'
        'Devide ID' = $hwd.id
        'Hostname' = $hwd.hostname
        'Dominio'=$hwd.domain
        'Status' = $hwd.status.name
        'PowerState' = $hwd.powerState.name
        'MaxMemory' = $hwd.maxMemory
        'CPU' = $hwd.maxCpu
        'CreateDate' = $hwd.createDate
        'ProvisionDate' = $hwd.provisionDate
        'Datacenter'=$hwd.datacenter.longName
        'O.S' = $hwd.operatingSystem.softwareLicense.softwareDescription.name
        'O.S Version' = $hwd.operatingSystem.softwareLicense.softwareDescription.version
        'IP Privada' = $hwd.primaryBackendIpAddress
        'IP Publica' = $hwd.primaryIpAddress
        'Cloud Provider' = "IBM Cloud"
    }
    $OSinfo | Export-Csv -NoTypeInformation -Path  $Filename2 -Encoding UTF8 -Append -Force;  
}

foreach ($id in (ibmcloud sl hardware list --output json | ConvertFrom-Json)){
    $sd = (ibmcloud sl hardware detail $id.id --output json | ConvertFrom-Json)
    foreach ($hwd in $sd ){
        Get-OSinfoBM
    }
}

foreach ($id in (ibmcloud sl vs list --output json | ConvertFrom-Json)){
    $sd = (ibmcloud sl vs detail $id.id --output json | ConvertFrom-Json)
    foreach ($hwd in $sd ){
        Get-OSinfoVS
    }
}

#foreach ($id in (ibmcloud sl vs list --output json | ConvertFrom-Json)){
#    Get-OSinfoVS
#}

