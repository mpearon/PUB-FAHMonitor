Param(
	$commandText
)

switch($commandText){
	'slot'	{
		$unparsed = FAHClient --send-command "slot-info"
		$parsed = ( $unparsed | Select-Object -Skip 2 ) -replace "---" -replace '\sFalse','"False"' -replace '\sTrue','"True"' | ConvertFrom-Json | Out-String
	}
	'queue'	{
		$unparsed = FAHClient --send-command "queue-info"
		$parsed = $unparsed | Select-String -Pattern '{.+?}' | ConvertFrom-JSON | Out-String
	}
	'power'	{
		$unparsed = FAHClient --send-command "options power"
		$parsed = ( $unpased | Select-String -Pattern '{.+?}' | ConvertFrom-JSON ).power
	}
	'user'	{
		$unparsed = FAHClient --send-command "options user"
		$parsed = ( $parsed | Select-String -Pattern '{.+?}' | ConvertFrom-JSON ).user
	}
	'team'	{
		$unparsed = FAHClient --send-command "options team"
		$parsed = ( $parsed | Select-String -Pattern '{.+?}' | ConvertFrom-JSON ).team
	}
	default	{
		$parsed = 'Invoke-fahQuery: Unknown Command'
	}
}

return $parsed