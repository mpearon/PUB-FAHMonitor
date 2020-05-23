$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add('http://*:8614/')
$listener.Start()

$stopServer = $false
while(($listener.IsListening -eq $true) -and ($stopServer -eq $false)){
	$context = $listener.GetContext()
	$requestedFunction = $context.Request.RawUrl -replace '/'
	if($requestedFunction -match '\?'){
		$requestedFunction = (($requestedFunction).split('?')[0])
		$requestedVariable = (($requestedFunction).split('?')[1])
	}

	switch($requestedFunction){
		'slotInfo'	{
			$return = pwsh -file ./Invoke-fahQuery.ps1 -commandText 'slot'
		}
		'queueInfo'	{
			$return = pwsh -file ./Invoke-fahQuery.ps1 -commandText 'queue'
		}
		'powerInfo'	{
			$return = pwsh -file ./Invoke-fahQuery.ps1 -commandText 'power'
		}
		'userInfo'	{
			$return = pwsh -file ./Invoke-fahQuery.ps1 -commandText 'user'
		}
		'teamInfo'	{
			$return = pwsh -file ./Invoke-fahQuery.ps1 -commandText 'team'
		}
		'setPower'	{
			switch($requestedVariable){
				'full'	{
					pwsh -file ./Invoke-fahCommand.ps1 -commandText 'setPower' -argument 'full'
					$return = pwsh -file ./Invoke-fahQuery.ps1 -commandText 'power'
				}
				'medium'	{
					pwsh -file ./Invoke-fahCommand.ps1 -commandText 'setPower' -argument 'medium'
					$return = pwsh -file ./Invoke-fahQuery.ps1 -commandText 'power'
				}
				'light'	{
					pwsh -file ./Invoke-fahCommand.ps1 -commandText 'setPower' -argument 'light'
					$return = pwsh -file ./Invoke-fahQuery.ps1 -commandText 'power'
				}
				default	{
					$return = 'listener\setPower: Expected full|medium|light'
				}
			}
		}
		'setPause'	{
			switch($requestedVariable){
				$true	{
					pwsh -file ./Invoke-fahCommand.ps1 -commandText 'pause'
					$return = pwsh -file ./Invoke-fahQuery.ps1 -commandText 'slot'
				}
				$false	{
					pwsh -file ./Invoke-fahCommand.ps1 -commandText 'unpause'
					$return = pwsh -file ./Invoke-fahQuery.ps1 -commandText 'slot'
				}
				default	{
					$return = 'listener\setPause: Expected boolean'
				}
			}
		}
		'setOnIde'	{
			switch($requestedVariable){
				$true	{
					pwsh -file ./Invoke-fahCommand.ps1 -commandText 'onIdle' -argument 'true'
					$return =  pwsh -file ./Invoke-fahQuery.ps1 -commandText 'slot' 
				}
				$false	{
					 pwsh -file ./Invoke-fahCommand.ps1 -commandText 'onIdle' -argument 'false'
					 $return =  pwsh -file ./Invoke-fahQuery.ps1 -commandText 'slot' 
				}
				default	{
					$return = 'listener\setOnIdle: Expected boolean'
				}
			}
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
