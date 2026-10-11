param([int]$Port=9000,[string]$Destination='127.0.0.1',[int]$Seconds=20)
$ErrorActionPreference='Stop'
function OscString([string]$Text) {
    $raw=[Text.Encoding]::ASCII.GetBytes($Text)
    $padded=New-Object byte[] ([int]([Math]::Ceiling(($raw.Length+1)/4.0)*4))
    [Array]::Copy($raw,$padded,$raw.Length)
    return ,$padded
}
$oscAddress=OscString '/Face'
$tags=OscString (','+('f'*52))
$udp=New-Object System.Net.Sockets.UdpClient
$timer=[Diagnostics.Stopwatch]::StartNew()
try {
    Write-Output "Sending RhyLive-format continuous blink/jaw test to ${Destination}:$Port for $Seconds seconds."
    while($timer.Elapsed.TotalSeconds -lt $Seconds) {
        $t=$timer.Elapsed.TotalSeconds
        $vals=New-Object single[] 52
        $vals[8]=[single](0.5+0.5*[Math]::Sin($t*2.0))
        $vals[9]=[single](0.5+0.5*[Math]::Sin($t*2.0+1.5))
        $vals[24]=[single](0.5+0.5*[Math]::Sin($t*1.2))
        $packet=New-Object byte[] ($oscAddress.Length+$tags.Length+208)
        [Array]::Copy($oscAddress,0,$packet,0,$oscAddress.Length)
        [Array]::Copy($tags,0,$packet,$oscAddress.Length,$tags.Length)
        $offset=$oscAddress.Length+$tags.Length
        for($i=0;$i -lt 52;$i++) {
            $bytes=[BitConverter]::GetBytes($vals[$i])
            if([BitConverter]::IsLittleEndian) {[Array]::Reverse($bytes)}
            [Array]::Copy($bytes,0,$packet,$offset+4*$i,4)
        }
        $udp.Send($packet,$packet.Length,$Destination,$Port) | Out-Null
        Start-Sleep -Milliseconds 16
    }
} finally {$udp.Dispose()}
Write-Output 'Test stream ended; face drive should release after configured timeout.'
