Param(
	$commandText,
	[string]$format = 'html'
)

switch($commandText){
	'slot'	{
		$unparsed = FAHClient --send-command "slot-info"
		switch($format){
			'html'	{ $parsed = ( $unparsed | Select-Object -Skip 2 ) -replace "---" -replace '\sFalse','"False"' -replace '\sTrue','"True"' | ConvertFrom-Json | ConvertTo-HTML }
			'json'	{ $parsed = (( $unparsed | Select-Object -Skip 2 ) -replace "---" -replace '\sFalse','"False"' -replace '\sTrue','"True"' -replace '\[|\]' ).trim() }
		}
	}
	'queue'	{
		$unparsed = FAHClient --send-command "queue-info"
		switch($format){
			'html'	{ $parsed = ($unparsed | Select-String -Pattern '{.+?}').Matches.Value | ConvertFrom-JSON | ConvertTo-HTML }
			'json'	{ $parsed = ($unparsed | Select-String -Pattern '{.+?}').Matches.Value }
		}
	}
	'power'	{
		$unparsed = FAHClient --send-command "options power"
		switch($format){
			'html'		{ $parsed = ($unparsed | Select-String -Pattern '{.+?}').Matches.Value | ConvertFrom-Json | ConvertTo-Html }
			'json'		{ $parsed = ($unparsed | Select-String -Pattern '{.+?}').Matches.Value }
			'influx'	{
				$object = ($unparsed | Select-String -Pattern '{.+?}').Matches.Value | ConvertFrom-Json 
				$parsed = (-join('powerInfo,foldHost=',(hostname),' power=',$object.power))
			}
		}
	}
	'user'	{
		$unparsed = FAHClient --send-command "options user"
		switch($format){
			'html'		{ $parsed = ($unparsed | Select-String -Pattern '{.+?}').Matches.Value | ConvertFrom-Json | ConvertTo-Html }
			'json'		{ $parsed = ($unparsed | Select-String -Pattern '{.+?}').Matches.Value }
			'influx'	{
				$object = ($unparsed | Select-String -Pattern '{.+?}').Matches.Value | ConvertFrom-Json 
				$parsed = (-join('powerInfo,foldHost=',(hostname),' power=',$object.power))
			}
		}
	}
	'team'	{
		$unparsed = FAHClient --send-command "options team"
		switch($format){
			'html'		{ $parsed = ($unparsed | Select-String -Pattern '{.+?}').Matches.Value | ConvertFrom-Json | ConvertTo-Html }
			'json'		{ $parsed = ($unparsed | Select-String -Pattern '{.+?}').Matches.Value }
			'influx'	{
				$object = ($unparsed | Select-String -Pattern '{.+?}').Matches.Value | ConvertFrom-Json 
				$parsed = (-join('powerInfo,foldHost=',(hostname),' power=',$object.power))
			}
		}
	}
	default	{
		$parsed = 'Invoke-fahQuery: Unknown Command'
	}
}

return $parsed