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
	# $TTL 
	if($TTL -eq 128){
		Write-Host $array[$i].ToString() '= Windows'
	}
	elseif($TTL -eq 64){
		Write-Host $array[$i].ToString() '= Linux'
	}
	elseif($TTL -gt 0){
		Write-Output 'Unknown OS'
	}
}

# .\ostester.ps1 .\iplist.txt