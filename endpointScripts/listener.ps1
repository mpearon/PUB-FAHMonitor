$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add('http://*:8614/')
$listener.AuthenticationSchemes = [System.Net.AuthenticationSchemes]::Anonymous
$listener.UnsafeConnectionNtlmAuthentication = $true
$listener.Start()

while($listener.IsListening -eq $true){
	$context = $listener.GetContext()
	$request = $context.Request
	$response = $context.Response

	switch($request.RawUrl){
		'/'					{ $html = 'Folding@Home Monitor' }
		'/getSlotInfo/'		{ $html = ( FAHClient --send-command "slot-info" | Select-String -Pattern '{.+?}' | ConvertFrom-JSON | Out-String ) }
		'/getQueueInfo/'	{ $html = ( (FAHClient --send-command "queue-info" | Select-String -Pattern '{.+?}' | ConvertFrom-JSON | Out-String ) }
		'/getPowerLevel/'	{ $html = ( (FAHClient --send-command "options power" | Select-String -Pattern '{.+?}' | ConvertFrom-JSON).power ) }
		'/setLightPower/'	{ $html = ( (FAHClient --send-command "options power light"); ( (FAHClient --send-command "options power" | Select-String -Pattern '{.+?}' | ConvertFrom-JSON).power ) ) }
		'/setMediumPower/'	{ $html = ( (FAHClient --send-command "options power medium"); ( (FAHClient --send-command "options power" | Select-String -Pattern '{.+?}' | ConvertFrom-JSON).power ) ) }
		'/setHighPower/'	{ $html = ( (FAHClient --send-command "options power high"); ( (FAHClient --send-command "options power" | Select-String -Pattern '{.+?}' | ConvertFrom-JSON).power ) ) }
		'/getUser/'			{ $html = ( (FAHClient --send-command "options user" | Select-String -Pattern '{.+?}' | ConvertFrom-JSON).user ) }
		'/getTeam/'			{ $html = ( (FAHClient --send-command "options team" | Select-String -Pattern '{.+?}' | ConvertFrom-JSON).team ) }
		'/pause/'			{ $html = ( (FAHClient --send-command "pause *"); ( (FAHClient --send-command "slot-info" | Select-String -Pattern '{.+?}' | ConvertFrom-JSON).status ) ) }
		'/unpause/'			{ $html = ( (FAHClient --send-command "unpause *"); ( (FAHClient --send-command "slot-info" | Select-String -Pattern '{.+?}' | ConvertFrom-JSON).status ) ) }
		'/onIdle/'			{ $html = ( (FAHClient --send-command "on_idle *"); ((FAHClient --send-command "slot-info" | Select-String -Pattern '{.+?}' | ConvertFrom-JSON).status ) ) }
		'/finish/'			{ $html = ( (FAHClient --send-command "finish *"); ((FAHClient --send-command "slot-info" | Select-String -Pattern '{.+?}' | ConvertFrom-JSON).status ) ) }
		default				{ $html = 'Unknown option' }
	}
	$request.RawUrl
	$buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
	$context.Response.ContentLength64 = $buffer.Length
	$context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
	$context.Response.OutputStream.Close()
}
$listener.Stop()
$listener.Close()
$listener = $null
