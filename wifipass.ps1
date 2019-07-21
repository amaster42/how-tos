$ssids = netsh wlan show profiles
$ssid = ' '
$delin = ': '

#$ssid = $ssids.split(":")[1]
$ssid = (echo $ssids | ForEach-Object {$_.split(":")[1]})
#$ssid = (echo $ssid | ForEach-Object {$_.split(" ")})
#echo $ssid | ForEach-Object -replace '\s+', ' '

echo $ssid | Set-Content output.txt 
