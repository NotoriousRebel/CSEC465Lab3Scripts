[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]
    $filename
)
<#
.SYNOPSIS
Script which is used to resolve dns names for host addresses
.DESCRIPTION
The script gets the contents of a file and for each hostname returns the ipv4 addresses associated with
it after a dns A query
.PARAMETER filename
Required parameter that contains filename to be read 
.NOTES
Version:        1.0
Author:         Matthew Brown
Creation Date:  10/3/19
.EXAMPLE
PS C:\> .\resolve.ps1 -filename test_file.txt
#>

function make_query($host_name){
     <#
    .SYNOPSIS
    A helper function that makes a dns A query for a given hostname
    .DESCRIPTION
    This function takes in a hostname and performs a dns A query and returns the ipv4 addresses
    .PARAMETER host_name
    hostname to perform dns query on
    .OUTPUTS
    returns an empty string if it errors out or the ipv4 addresses 
    #>

    try{
        return (Resolve-DnsName -Name $host_name -Type "A" -erroraction 'ignore').IPAddress
    }
    Catch{
        return ""
    }
}

function resolve([string]$file) {
    <#
    .SYNOPSIS
    Function that takes in a file and does a dns A query for each hostname in the file
    .DESCRIPTION
    This function takes in a file and foreach hostname in the file 
    calls the make_query function and stores it in hashmap
    .PARAMETER file
    File to parse through
    .OUTPUTS
    returns a hashmap mapping hostname to ipv4 addresses resolved
    #>
   $dct = @{ }
   $results = Get-Content $file | ForEach-Object {$dct[$_] = make_query($_)}
   return $dct
}

if (Test-Path -Path $filename) {
    $dct = resolve($filename)
    $keys = $dct.Keys | Sort-Object
    foreach($key in $keys){
        if([string]$dct[$key] -match ' '){
            $val = [string]$dct[$key]
            $val = $val.Replace(" ", ", ")
            Write-Host "$($key): $($val)"
        }
        else{
            Write-Host "$($key): $([string]$dct[$key])"
        }
    }
}

else {
    Write-Error -Message "Error file does not exist!"
}