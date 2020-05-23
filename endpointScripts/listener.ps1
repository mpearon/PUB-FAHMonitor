$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add('http://*:8614/')
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
		'slotInfo'	{
			$return = Start-Process pwsh -file ./Invoke-fahQuery.ps1 -ArgumentList 'slot' -Wait
		}
		'queueInfo'	{
			$return = Start-Process pwsh -file ./Invoke-fahQuery.ps1 -ArgumentList 'queue' -Wait
		}
		'powerInfo'	{
			$return = Start-Process pwsh -file ./Invoke-fahQuery.ps1 -ArgumentList 'power' -Wait
		}
		'userInfo'	{
			$return = Start-Process pwsh -file ./Invoke-fahQuery.ps1 -ArgumentList 'user' -Wait
		}
		'teamInfo'	{
			$return = Start-Process pwsh -file ./Invoke-fahQuery.ps1 -ArgumentList 'team' -Wait
		}
		'setPower'	{
			switch($requestedVariable){
				'high'	{
					Start-Process pwsh -file ./Invoke-fahCommand.ps1 -ArgumentList 'setPower','high' -Wait
				}
				'medium'	{
					Start-Process pwsh -file ./Invoke-fahCommand.ps1 -ArgumentList 'setPower','medium' -Wait
				}
				'low'	{
					Start-Process pwsh -file ./Invoke-fahCommand.ps1 -ArgumentList 'setPower','low' -Wait
				}
				default	{
					$return = 'listener\setPower: Expected high|medium|low'
				}
			}
			$return = Start-Process pwsh -file ./Invoke-fahQuery.ps1 -ArgumentList 'power' -Wait
		}
		'setPause'	{
			switch($requestedVariable){
				$true	{
					Start-Process pwsh -file ./Invoke-fahCommand.ps1 -ArgumentList 'pause' -Wait
				}
				$false	{
					Start-Process pwsh -file ./Invoke-fahCommand.ps1 -ArgumentList 'unpause' -Wait
				}
				default	{
					$return = 'listener\setPause: Expected boolean'
				}
			}
			$return = Start-Process pwsh -file ./Invoke-fahQuery.ps1 -ArgumentList 'slot' -Wait
		}
		'setOnIde'	{
			switch($requestedVariable){
				$true	{
					Start-Process pwsh -file ./Invoke-fahCommand.ps1 -ArgumentList 'onIdle','true' -Wait
				}
				$false	{
					Start-Process pwsh -file ./Invoke-fahCommand.ps1 -ArgumentList 'onIdle','false' -Wait
				}
				default	{
					$return = 'listener\setOnIdle: Expected boolean'
				}
			}
			$return = Start-Process pwsh -file ./Invoke-fahQuery.ps1 -ArgumentList 'slot' -Wait
		}
		'stopServer'	{
			$return = @"
				<html>
					<head>
						<meta http-equiv="refresh" content="2;URL=https://foldingathome.org" />
					</head>
					<body>
						<h1>Folding@Home Monitor</h1><br />
						<font color="red">[STOPPING]</font>
					</body>
				</html>
"@
		}
		default		{
			$return = @"
				<html>
					<head>
					</head>
					<body>
						<h1>Folding@Home Monitor</h1><br />
						<font color="green">[RUNNING]</font>
						<ol>
							<li>slotInfo</li>
							<li>queueInfo</li>
							<li>userInfo</li>
							<li>teamInfo</li>
							<li>setPower</li>
							<li>setPause</li>
							<li>setOnIdle</li>
						</ol>
					</body>
				</html>
"@
		}
	}

	$buffer = [System.Text.Encoding]::UTF8.GetBytes($return)
	$context.Response.ContentLength64 = $buffer.Length
	$context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
	$context.Response.OutputStream.Close()
}
$listener.Stop()
$listener.Close()
$listener = $null
exit;
