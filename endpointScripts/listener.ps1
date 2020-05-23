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
			$return = pwsh -file ./Invoke-fahQuery.ps1 -ArgumentList 'slot'
		}
		'queueInfo'	{
			$return = pwsh -file ./Invoke-fahQuery.ps1 -ArgumentList 'queue'
		}
		'powerInfo'	{
			$return = pwsh -file ./Invoke-fahQuery.ps1 -ArgumentList 'power'
		}
		'userInfo'	{
			$return = pwsh -file ./Invoke-fahQuery.ps1 -ArgumentList 'user'
		}
		'teamInfo'	{
			$return = pwsh -file ./Invoke-fahQuery.ps1 -ArgumentList 'team'
		}
		'setPower'	{
			switch($requestedVariable){
				'high'	{
					pwsh -file ./Invoke-fahCommand.ps1 -ArgumentList 'setPower','high'
				}
				'medium'	{
					pwsh -file ./Invoke-fahCommand.ps1 -ArgumentList 'setPower','medium'
				}
				'low'	{
					pwsh -file ./Invoke-fahCommand.ps1 -ArgumentList 'setPower','low'
				}
				default	{
					$return = 'listener\setPower: Expected high|medium|low'
				}
			}
			$return = pwsh -file ./Invoke-fahQuery.ps1 -ArgumentList 'power'
		}
		'setPause'	{
			switch($requestedVariable){
				$true	{
					pwsh -file ./Invoke-fahCommand.ps1 -ArgumentList 'pause'
				}
				$false	{
					pwsh -file ./Invoke-fahCommand.ps1 -ArgumentList 'unpause'
				}
				default	{
					$return = 'listener\setPause: Expected boolean'
				}
			}
			$return = pwsh -file ./Invoke-fahQuery.ps1 -ArgumentList 'slot'
		}
		'setOnIde'	{
			switch($requestedVariable){
				$true	{
					pwsh -file ./Invoke-fahCommand.ps1 -ArgumentList 'onIdle','true'
				}
				$false	{
					 pwsh -file ./Invoke-fahCommand.ps1 -ArgumentList 'onIdle','false' 
				}
				default	{
					$return = 'listener\setOnIdle: Expected boolean'
				}
			}
			$return =  pwsh -file ./Invoke-fahQuery.ps1 -ArgumentList 'slot' 
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
			$stopServer = $true
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
