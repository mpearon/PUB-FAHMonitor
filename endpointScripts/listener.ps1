$listener = New-Object -TypeName System.Net.HttpListener
$listener.Prefixes.Add('http://*:8614/')
$listener.Start()
while($listener.IsListening -eq $true){
	$context = $listener.GetContext()
}