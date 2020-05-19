$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add('http://*:8614/')
#$listener.AuthenticationSchemes = [System.Net.AuthenticationSchemes]::Anonymous
#$listener.UnsafeConnectionNtlmAuthentication = $true
$listener.Start()

$stopServer = $false
while(($listener.IsListening -eq $true) -and ($stopServer -eq $false)){
	$context = $listener.GetContext()
	
	$requestedFunction = $context.Request.RawUrl -replace '/'
	if($requestedFunction -match '\?'){
		$requestedFunction = (($context.Request.RawUrl).split('?')[0]).replace('','')
		$requestedVariable = (($context.Request.RawUrl).split('?')[1])
	}

	switch($requestedFunction){
		'getSlotInfo'	{ $html = ((FAHClient --send-command "slot-info" | Select-Object -Skip 2) -replace "---" -replace '\sFalse','"False"' -replace '\sTrue','"True"' | ConvertFrom-Json | Out-String) }
		'getQueueInfo'	{ $html = ( FAHClient --send-command "queue-info" | Select-String -Pattern '{.+?}' | ConvertFrom-JSON | Out-String ) }
		'getPowerLevel'	{ $html = ( (FAHClient --send-command "options power" | Select-String -Pattern '{.+?}' | ConvertFrom-JSON).power ) }
		'setPowerLevel'	{ FAHClient --send-command "options power $requestedVariable"; $html = (FAHClient --send-command "options power" | Select-String -Pattern '{.+?}' | ConvertFrom-JSON).power }
		'getUser'		{ $html = ( (FAHClient --send-command "options user" | Select-String -Pattern '{.+?}' | ConvertFrom-JSON).user ) }
		'getTeam'		{ $html = ( (FAHClient --send-command "options team" | Select-String -Pattern '{.+?}' | ConvertFrom-JSON).team ) }
		'pause'			{ FAHClient --send-command "pause *"; $html = ((FAHClient --send-command "slot-info" | Select-Object -Skip 2) -replace "---" -replace '\sFalse','"False"' -replace '\sTrue','"True"' | ConvertFrom-Json).status }
		'unpause'		{ FAHClient --send-command "unpause *"; $html = ((FAHClient --send-command "slot-info" | Select-Object -Skip 2) -replace "---" -replace '\sFalse','"False"' -replace '\sTrue','"True"' | ConvertFrom-Json).status  }
		'onIdle'		{ FAHClient --send-command "on_idle *"; $html = ((FAHClient --send-command "slot-info" | Select-Object -Skip 2) -replace "---" -replace '\sFalse','"False"' -replace '\sTrue','"True"' | ConvertFrom-Json).status }
		'finish'		{ FAHClient --send-command "finish *"; $html = ((FAHClient --send-command "slot-info" | Select-Object -Skip 2) -replace "---" -replace '\sFalse','"False"' -replace '\sTrue','"True"' | ConvertFrom-Json).status }
		'stopServer'	{ $stopServer = $true; $html = '<html><head><meta http-equiv="refresh" content="2;URL=https://foldingathome.org" /></head><body><h1>Folding@Home Monitor</h1>&nbsp;<font color="red">[STOPPED]</font></body></html>' }
		default			{ $html = '<h1>Folding@Home Monitor</h1>' }
	}
	$buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
	$context.Response.ContentLength64 = $buffer.Length
	$context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
	$context.Response.OutputStream.Close()
}
$listener.Stop()
$listener.Close()
$listener = $null
exit;
