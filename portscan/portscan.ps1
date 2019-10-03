#AUTHOR: Zack Cogswell

param (
    [Parameter(Mandatory=$true)]
    [string]$ip,
    [Parameter(Mandatory=$true)]
    [string[]]$port
)

. ".\iprange.ps1"

#error messages
$badip = "ERROR: ip must be a range of IP addresses"
$badport = "ERROR: port must be a single, range, or list of port numbers"

#IP params
[int64[]]$ip = Convert-Range $ip
if( $ip -eq -1 ){
    Write-Error "$badip"
    exit
}

#port params
if( $port[0].IndexOf("-") -lt 0 ){
    if( $port -as [int32[]] -eq $null){
        Write-Error "$badport"
        exit
    }
    [int32[]]$port = $port
}
else{
    $copy = $port
    [int32[]]$port = @()
    foreach( $i in $copy ){
        $i = $i.split("-")
        if( $i.Count -gt 2 ){
            Write-Error "$badport"
            exit
        }
        [int32[]]$port += ($i[0]..$i[1])
    }
}

#connection tests
$timeout = 100
foreach( $i in $ip ){
    foreach( $j in $port ){
        $socket = New-Object Net.Sockets.TcpClient
        $socket.BeginConnect($i,$j,$null,$null) | Out-Null
        Start-Sleep -milli $timeout
        if( $socket.Connected ){
            $ipstring = INT64-toIP($i)
            "$ipstring`t: TCP/$j`tis open"
        }
        $socket.Close()
    }
}