Param(
	$command,
	$argument
)

switch($command){
	'pause'		{
		$parsed = FAHClient --send-command "pause *"
	}
	'unpause'	{
		$parsed = FAHClient --send-command "unpause *"
	}
	'finish'	{
		$parsed = FAHClient --send-command "finish *"
	}
	'setPower' {
		if($argument -match 'high|medium|low'){
			$parsed = FAHClient --send-command "options power $argument"
		}
		else{
			$parsed = 'Invoke-fahCommand\setPower: Expected (high|medium|low)'
		}
	}
	'onIdle'	{
		if($argument -as [bool]){
			$parsed = FAHClient --send-command "options power $argument"
		}
		$parsed = 'Invoke-fahCommand\onIdle: Expected boolean'
	}
	default		{
		$parsed = 'Invoke-fahCommand: Unknown Command'
	}
}

return $parsed