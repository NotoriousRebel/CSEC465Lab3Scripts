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
$timeout = 50
foreach( $i in $ip ){
    foreach( $j in $port ){
        #tcp
        $socket = New-Object Net.Sockets.TcpClient
        $socket.BeginConnect($i,$j,$null,$null) | Out-Null
        Start-Sleep -milli $timeout
        if( $socket.Connected ){
            $ipstring = INT64-toIP($i)
            "$ipstring`t: TCP/$j`tis open"
        }
        $socket.Close()
        #udp
        $socket = New-Object Net.Sockets.UdpClient
        $socket.client.ReceiveTimeout = $timeout
        $a = New-Object System.Text.AsciiEncoding
        $byte = $a.GetBytes("$(Get-Date)")
        $socket.Connect($i,$j) #| Out-Null
        [void]$socket.Send($byte,$byte.Length)
        $remoteendpoint = New-Object Net.IPEndpoint([Net.IPAddress]::Any,0)
        try{
            $recv = $socket.Receive([ref]$remoteendpoint)
            if( $recv ){
                $ipstring = INT64-toIP($i)
                "$ipstring`t: UDP/$j`tis open"
            }
        }
        catch{}
        $socket.Close()
    }
}