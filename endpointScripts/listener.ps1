$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add('http://*:8614/')
$listener.Start()

$stopServer = $false
while(($listener.IsListening -eq $true) -and ($stopServer -eq $false)){
	$context = $listener.GetContext()
	$requestedFunction = $context.Request.RawUrl -replace '/'
	if($requestedFunction -match '\?|\&'){
		$requestedFunction = (($context.Request.RawUrl -replace '/').split('?')[0])
		$requestedVariable = (($context.Request.RawUrl -replace '/').split('?')[1])
		$requestedformat = ((($context.Request.RawUrl) -split 'format=')[1])
	}
	switch($requestedFormat){
		''		{ $requestedformat = 'html' }
		$null	{ $requestedformat = 'html' }
	}
	switch($requestedFunction){
		'slotInfo'	{
			$return = pwsh -file (-join($PSScriptRoot,'/Invoke-fahQuery.ps1')) -commandText 'slot' -format $requestedFormat
		}
		'queueInfo'	{
			$return = pwsh -file (-join($PSScriptRoot,'/Invoke-fahQuery.ps1')) -commandText 'queue' -format $requestedFormat
		}
		'powerInfo'	{
			$return = pwsh -file (-join($PSScriptRoot,'/Invoke-fahQuery.ps1')) -commandText 'power' -format $requestedFormat
		}
		'userInfo'	{
			$return = pwsh -file (-join($PSScriptRoot,'/Invoke-fahQuery.ps1')) -commandText 'user' -format $requestedFormat
		}
		'teamInfo'	{
			$return = pwsh -file (-join($PSScriptRoot,'/Invoke-fahQuery.ps1')) -commandText 'team' -format $requestedFormat
		}
		'setPower'	{
			switch($requestedVariable){
				'full'	{
					pwsh -file (-join($PSScriptRoot,'/Invoke-fahCommand.ps1')) -commandText 'setPower' -argument 'full'
					$return = pwsh -file (-join($PSScriptRoot,'/Invoke-fahQuery.ps1')) -commandText 'power' -format $requestedFormat
				}
				'medium'	{
					pwsh -file (-join($PSScriptRoot,'/Invoke-fahCommand.ps1')) -commandText 'setPower' -argument 'medium'
					$return = pwsh -file (-join($PSScriptRoot,'/Invoke-fahQuery.ps1')) -commandText 'power' -format $requestedFormat
				}
				'light'	{
					pwsh -file (-join($PSScriptRoot,'/Invoke-fahCommand.ps1')) -commandText 'setPower' -argument 'light'
					$return = pwsh -file (-join($PSScriptRoot,'/Invoke-fahQuery.ps1')) -commandText 'power' -format $requestedFormat
				}
				default	{
					$return = 'listener\setPower: Expected full|medium|light'
				}
			}
		}
		'setPause'	{
			switch($requestedVariable){
				$true	{
					pwsh -file (-join($PSScriptRoot,'/Invoke-fahCommand.ps1')) -commandText 'pause'
					$return = pwsh -file (-join($PSScriptRoot,'/Invoke-fahQuery.ps1')) -commandText 'slot' -format $requestedFormat
				}
				$false	{
					pwsh -file (-join($PSScriptRoot,'/Invoke-fahCommand.ps1')) -commandText 'unpause'
					$return = pwsh -file (-join($PSScriptRoot,'/Invoke-fahQuery.ps1')) -commandText 'slot' -format $requestedFormat
				}
				default	{
					$return = 'listener\setPause: Expected boolean'
				}
			}
		}
		'setOnIde'	{
			switch($requestedVariable){
				$true	{
					pwsh -file (-join($PSScriptRoot,'/Invoke-fahCommand.ps1')) -commandText 'onIdle' -argument 'true'
					$return =  pwsh -file (-join($PSScriptRoot,'/Invoke-fahQuery.ps1')) -commandText 'slot' -format $requestedFormat
				}
				$false	{
					 pwsh -file (-join($PSScriptRoot,'/Invoke-fahCommand.ps1')) -commandText 'onIdle' -argument 'false'
					 $return =  pwsh -file (-join($PSScriptRoot,'/Invoke-fahQuery.ps1')) -commandText 'slot' -format $requestedFormat
				}
				default	{
					$return = 'listener\setOnIdle: Expected boolean'
				}
			}
		}
		'setFinish'	{
			pwsh -file (-join($PSScriptRoot,'/Invoke-fahCommand.ps1')) -commandText 'finish' -argument 'false'
			$return =  pwsh -file (-join($PSScriptRoot,'/Invoke-fahQuery.ps1')) -commandText 'slot' -format $requestedFormat
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
						<ul>
							<li><a href="slotInfo?format=html">slotInfo</a></li>
							<li><a href="queueInfo?format=html">queueInfo</a></li>
							<li><a href="userInfo">userInfo</a></li>
							<li><a href="teamInfo">teamInfo</a></li>
							<li><a href="setFinish">setFinish</a></li>
							<li><a href="setPower?high">setPower - full</a></li>
							<li><a href="setPower?medium">setPower - medium</a></li>
							<li><a href="setPower?light">setPower - light</a></li>
							<li><a href="setPause?true">setPause - true</a></li>
							<li><a href="setPause?false">setPause - false</a></li>
							<li><a href="setOnIdle?true">setOnIdle - true</a></li>
							<li><a href="setOnIdle?false">setOnIdle - false</a></li>
						</ul>
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
