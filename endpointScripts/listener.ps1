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
        '/'                 { $html = 'Folding@Home Monitor' }
        '/getSlotInfo'     { $html = ( FAHClient --send-command "slot-info" ) }
        '/getQueueInfo'    { $html = ( FAHClient --send-command "queue-info" | Select-String -Pattern '{.+?}' | ConvertFrom-JSON | Out-String ) }
        '/getPowerLevel'   { $html = ( (FAHClient --send-command "options power" | Select-String -Pattern '{.+?}' | ConvertFrom-JSON).power ) }
        '/setLightPower'   { FAHClient --send-command "options power light"; $html = (FAHClient --send-command "options power" | Select-String -Pattern '{.+?}' | ConvertFrom-JSON).power }
        '/setMediumPower'  { FAHClient --send-command "options power medium"; $html = (FAHClient --send-command "options power" | Select-String -Pattern '{.+?}' | ConvertFrom-JSON).power }
        '/setHighPower'    { FAHClient --send-command "options power high"; $html = (FAHClient --send-command "options power" | Select-String -Pattern '{.+?}' | ConvertFrom-JSON).power }
        '/getUser'         { $html = ( (FAHClient --send-command "options user" | Select-String -Pattern '{.+?}' | ConvertFrom-JSON).user ) }
        '/getTeam'         { $html = ( (FAHClient --send-command "options team" | Select-String -Pattern '{.+?}' | ConvertFrom-JSON).team ) }
        '/pause'           { FAHClient --send-command "pause *"; $html = (FAHClient --send-command "slot-info") }
        '/unpause'         { FAHClient --send-command "unpause *"; $html = (FAHClient --send-command "slot-info") }
        '/onIdle'          { FAHClient --send-command "on_idle *"; $html = (FAHClient --send-command "slot-info") }
        '/finish'          { FAHClient --send-command "finish *"; $html = (FAHClient --send-command "slot-info") }
        default             { $html = 'Unknown option' }
    }
    $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
    $context.Response.ContentLength64 = $buffer.Length
    $context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
    $context.Response.OutputStream.Close()
}
$listener.Stop()
$listener.Close()
$listener = $null
