# Chạy thử trên Windows: powershell -ExecutionPolicy Bypass -File chay-thu.ps1
# Mở http://localhost:8765  (dùng thư mục Drive riêng "QuanLyHopDong-Test", không đụng dữ liệu thật)
# Dừng: nhấn Ctrl+C (có thể mất tới ~1 giây) hoặc đóng cửa sổ.
param([int]$Port=8765)
$Root=$PSScriptRoot
$l=New-Object Net.HttpListener; $l.Prefixes.Add("http://localhost:$Port/"); $l.Start()
Write-Host "Dang chay: http://localhost:$Port  (Ctrl+C de dung)"
$mt=@{'.html'='text/html; charset=utf-8';'.js'='text/javascript';'.png'='image/png';'.webmanifest'='application/manifest+json'}
try{
 while($l.IsListening){
  $t=$l.GetContextAsync()
  while(-not $t.AsyncWaitHandle.WaitOne(300)){}      # chờ theo nhịp ngắn để Ctrl+C có tác dụng
  $c=$t.Result;$p=$c.Request.Url.LocalPath.TrimStart('/');if(-not $p){$p='index.html'}
  $f=[IO.Path]::GetFullPath((Join-Path $Root $p))
  if($f.StartsWith($Root) -and (Test-Path -LiteralPath $f -PathType Leaf)){$b=[IO.File]::ReadAllBytes($f);$c.Response.ContentType=$mt[[IO.Path]::GetExtension($f)];$c.Response.Headers.Add('Cache-Control','no-store');$c.Response.OutputStream.Write($b,0,$b.Length)}else{$c.Response.StatusCode=404}
  $c.Response.Close()}
}finally{$l.Stop();$l.Close()}
