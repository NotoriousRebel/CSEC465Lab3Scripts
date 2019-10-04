[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]
    $filename
)
<#
.SYNOPSIS
Script which can be used to find living off the land binaries and scripts on a target machine.
.DESCRIPTION
The script searches through known locations of Living off Land Binaries and Scripts
and identifies if they exist. In the case they do exist it will output the name of the binary or
script, the full path, and how to use it.
.PARAMETER Outfile
If specified output will be put into an outfile of this name
.NOTES
Version:        1.0
Author:         NotoriousRebel
Creation Date:  6/29/19
.EXAMPLE
PS C:\> .\Find-LOLBAS.ps1
PS C:\> .\Find-LOLBAS.ps1 -Outfile "results.txt"
.LINK
https://github.com/LOLBAS-Project/LOLBAS
#>

function make_query($host_name){
    try{
        return (Resolve-DnsName -Name $host_name -Type "A" -erroraction 'ignore').IPAddress
    }
    Catch{
        return ""
    }
}

function resolve([string]$file) {
   $dct = @{ }
   $results = Get-Content $file | ForEach-Object {$dct[$_] = make_query($_)}
   return $dct
}

if (Test-Path -Path $filename) {
    #$hosts.GetType()
    #$hosts
    $dct = resolve($filename)
    $keys = $dct.Keys | Sort-Object
    foreach($key in $keys){
        Write-Host "$($key): $($dct[$key])"
    }
    #$dct | Sort-Object
}

else {
    Write-Error -Message "Error file does not exist!"
}