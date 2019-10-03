#AUTHOR: Zack Cogswell
#int-IP conversion functions from Microsoft example

# Converts int64 to IP address string
function INT64-toIP() { 
    param ([int64]$int) 

    return (([math]::truncate($int/16777216)).tostring()+"."+([math]::truncate(($int%16777216)/65536)).tostring()+"."+([math]::truncate(($int%65536)/256)).tostring()+"."+([math]::truncate($int%256)).tostring() )
}

#Converts IP address string to int64
function IP-toINT64 () { 
    param ($ip) 

    $octets = $ip.split(".")
    return [int64]([int64]$octets[0]*16777216 +[int64]$octets[1]*65536 +[int64]$octets[2]*256 +[int64]$octets[3]) 
}

#Converts IP range string into an array of int64s
function Convert-Range () {
    param ($ip)
    if( $ip.IndexOf("-") -lt 0 ){
        if( $ip.IndexOf("/") -lt 0 ){
            return -1
        }
        $copy = $ip.Split("/")
        [int64[]]$ip = @()
        $ip += IP-toINT64($copy[0])
        $ip += [convert]::ToInt64(("1"*$copy[1]+"0"*(32-$copy[1])),2)
        $ip[0] = $ip[0] -band $ip[1]
        $ip[1] = (IP-toINT64("255.255.255.255")) -bxor $ip[1] -bor $ip[0]
    }
    else{
        $copy = $ip.Split("-")
        if( $copy.Count -gt 2 ){
            return -1
        }
        [int64[]]$ip = @()
        $ip += IP-toINT64($copy[0])
        $ip += IP-toINT64($copy[1])
        if ( $ip -gt $max32 ){
        }
    }
    $copy = $ip
    [int64[]]$ip = @()
    for( $i = $copy[0]; $i -le $copy[1]; $i++ ){
        $ip += $i
    }
    return $ip
}