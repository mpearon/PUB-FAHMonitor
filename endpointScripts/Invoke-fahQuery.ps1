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
	'summary'	{
		$queueInfo = pwsh -file (-join($PSScriptRoot,'/Invoke-fahQuery.ps1')) -commandText 'queue' -format 'json' | ConvertFrom-Json
		$userInfo = pwsh -file (-join($PSScriptRoot,'/Invoke-fahQuery.ps1')) -commandText 'user' -format 'json' | ConvertFrom-Json
		$teamInfo = pwsh -file (-join($PSScriptRoot,'/Invoke-fahQuery.ps1')) -commandText 'team' -format 'json' | ConvertFrom-Json
		$statusInfo = pwsh -file (-join($PSScriptRoot,'/Invoke-fahQuery.ps1')) -commandText 'slot' -format 'json' | ConvertFrom-Json
		$powerInfo = pwsh -file (-join($PSScriptRoot,'/Invoke-fahQuery.ps1')) -commandText 'power' -format 'json' | ConvertFrom-Json
		$apiUserData = Invoke-RestMethod (-join('https://stats.foldingathome.org/api/donor/',$userInfo.user))
		$summaryObject = [PSCustomObject]@{
			foldHost = hostname
			user = $userInfo.user
			userLink = (-join('https://stats.foldingathome.org/donor/',($apiUserData).id))
			userWuCount = ($apiUserData).wus
			teamInfo = [int]$teamInfo.team
			teamLink = (-join('https://stats.foldingathome.org/team/',$teamInfo.team))
			status = switch($statusInfo.status){
					'STOPPED'	{ 0 }
					'RUNNING'	{ 1 }
					'PAUSED'	{ 2 }
					'FINISHING'	{ 3 }
				}
			power = switch($powerInfo.power){
					'full'		{ 3 }
					'medium'	{ 2 }
					'light'		{ 1 }
				}
			state = switch($queueInfo.state){
					'READY'		{ 0 }
					'RUNNING'	{ 1 }
			}
			error = switch($queueInfo.error){
					'NO_ERROR'	{ 0 }
					default		{ 1 }
			}
			project = $queueInfo.project
			projectLink = (-join('https://stats.foldingathome.org/project?p=',$queueInfo.project))
			unit = (-join('u',$queueInfo.unit))
			framesCompleted = $queueInfo.framesdone
			framesTotal = $queueInfo.totalframes
			percentComplete = [double]($queueInfo.percentdone -replace '%')
			eta = $queueInfo.eta
			assigned = (Get-Date $queueInfo.assigned -Format 'yyyy-MM-dd HH:mm')
			deadline = (Get-Date $queueInfo.deadline -Format 'yyyy-MM-dd HH:mm')
		}
		switch($format){
			'json'	{ $parsed = $summaryObject | ConvertTo-Json }
			'html'	{ $parsed = $summaryObject | ConvertTo-Html }
			$null	{ $parsed = $summaryObject | ConvertTo-Html }
		}
	}
	default	{
		$parsed = 'Invoke-fahQuery: Unknown Command'
	}
}

return $parsed