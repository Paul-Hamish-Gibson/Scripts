cd c:\
gci -r -ErrorAction SilentlyContinue -Force|
  sort -descending -property length | 
  select -first 25 name, @{Name="Gigabytes";Expression={[Math]::round($_.length / 1GB, 2)}}