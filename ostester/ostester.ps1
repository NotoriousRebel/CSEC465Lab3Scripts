<#
.DESCRIPTION
Script that determines the OS of IP addresses given in a text file based off their TTL
.NOTES
Author:		Aaron Karenchak
Date:		10/3/2019
.EXAMPLE
PS C:\> .\ostester.ps1 iplist.txt
#>


if(!$args[0]){
	Write-Host "ERROR: must include file with IP addresses in argument"
	Write-Host ".\ostester <iplist file>"
	exit
}

$array =@()
ForEach($line in Get-Content $args[0]){
	$array = $array + $line
}

$count = $array.Count
For($i=0; $i -lt $count; $i++){
	$output1= ping $array[$i] -n 1;
	$output2= $output1 -match "TTL";
	$output3=$output2 -split 'TTL='; 
	$TTL=$output3[1];
	
	$TTL = [int]$TTL
	if($TTL -ge 65 -And $TTL -le 128){
		Write-Host $array[$i].ToString() '= Windows'
	}
	elseif($TTL -lt 65){
		Write-Host $array[$i].ToString() '= Linux'
	}
	elseif($TTL -gt 128){
		Write-Host $array[$i].ToString() '= Solaris/AIX'
	}
}