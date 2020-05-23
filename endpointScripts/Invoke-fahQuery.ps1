Param(
	$commandText,
	[string]$format = 'html'
)

switch($commandText){
	'slot'	{
		$unparsed = FAHClient --send-command "slot-info"
		switch($format){
			'html'	{ $parsed = ( $unparsed | Select-Object -Skip 2 ) -replace "---" -replace '\sFalse','"False"' -replace '\sTrue','"True"' | ConvertFrom-Json | ConvertTo-HTML }
			'json'	{ $parsed = ( $unparsed | Select-Object -Skip 2 ) -replace "---" -replace '\sFalse','"False"' -replace '\sTrue','"True"' }
		}
	}
	'queue'	{
		$unparsed = FAHClient --send-command "queue-info"
		switch($format){
			'html'	{ $parsed = $unparsed | Select-String -Pattern '{.+?}' | ConvertFrom-JSON | ConvertTo-HTML }
			'json'	{ $parsed = $unparsed | Select-String -Pattern '{.+?}' }
		}
	}
	'power'	{
		$unparsed = FAHClient --send-command "options power"
		$parsed = ( $unparsed | Select-String -Pattern '{.+?}' | ConvertFrom-JSON ).power
	}
	'user'	{
		$unparsed = FAHClient --send-command "options user"
		$parsed = ( $unparsed | Select-String -Pattern '{.+?}' | ConvertFrom-JSON ).user
	}
	'team'	{
		$unparsed = FAHClient --send-command "options team"
		$parsed = ( $unparsed | Select-String -Pattern '{.+?}' | ConvertFrom-JSON ).team
	}
	default	{
		$parsed = 'Invoke-fahQuery: Unknown Command'
	}
}

return $parsed