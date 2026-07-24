# Static file server (TcpListener avoids HttpListener URL-ACL admin requirements).
# Each client is handled on its own runspace so a single idle/half-open socket
# (browsers open speculative connections) can never wedge the accept loop.
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$listener = [System.Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, 8321)
$listener.Start()
Write-Host "Serving $root on http://localhost:8321/"

$handler = {
  param($client, $root)
  try {
    $client.ReceiveTimeout = 4000
    $client.SendTimeout = 4000
    $stream = $client.GetStream()
    $reader = New-Object IO.StreamReader($stream)
    $requestLine = $reader.ReadLine()
    if ([string]::IsNullOrEmpty($requestLine)) { return }
    while (($line = $reader.ReadLine()) -ne $null -and $line -ne '') { }
    $path = ($requestLine -split ' ')[1]
    if ([string]::IsNullOrEmpty($path) -or $path -eq '/') { $path = '/frostfell.html' }
    $path = $path.Split('?')[0]
    $file = Join-Path $root ($path.TrimStart('/') -replace '/', '\')
    if (Test-Path $file -PathType Leaf) {
      $bytes = [IO.File]::ReadAllBytes($file)
      $ext = [IO.Path]::GetExtension($file).ToLower()
      $types = @{'.html'='text/html; charset=utf-8'; '.js'='text/javascript'; '.css'='text/css'; '.png'='image/png'; '.jpg'='image/jpeg'; '.json'='application/json'; '.ico'='image/x-icon'}
      $ct = $types[$ext]; if (-not $ct) { $ct = 'application/octet-stream' }
      $header = "HTTP/1.1 200 OK`r`nContent-Type: $ct`r`nContent-Length: $($bytes.Length)`r`nCache-Control: no-cache, no-store`r`nConnection: close`r`n`r`n"
    } else {
      $bytes = [Text.Encoding]::UTF8.GetBytes('404 Not Found')
      $header = "HTTP/1.1 404 Not Found`r`nContent-Type: text/plain`r`nContent-Length: $($bytes.Length)`r`nConnection: close`r`n`r`n"
    }
    $hb = [Text.Encoding]::ASCII.GetBytes($header)
    $stream.Write($hb, 0, $hb.Length)
    $stream.Write($bytes, 0, $bytes.Length)
    $stream.Flush()
  } catch {} finally { try { $client.Close() } catch {} }
}

$jobs = New-Object System.Collections.ArrayList
while ($true) {
  try {
    $client = $listener.AcceptTcpClient()
    $ps = [PowerShell]::Create()
    $null = $ps.AddScript($handler).AddArgument($client).AddArgument($root)
    $h = $ps.BeginInvoke()
    [void]$jobs.Add(@{ ps = $ps; h = $h })
    for ($i = $jobs.Count - 1; $i -ge 0; $i--) {
      if ($jobs[$i].h.IsCompleted) {
        try { $jobs[$i].ps.EndInvoke($jobs[$i].h) } catch {}
        $jobs[$i].ps.Dispose()
        $jobs.RemoveAt($i)
      }
    }
  } catch {}
}
