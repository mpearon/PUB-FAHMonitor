Param(
	$commandText,
	$argument
)

switch($commandText){
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
		if($argument -match 'full|medium|light'){
			$parsed = FAHClient --send-command "option power $argument"
		}
		else{
			$parsed = 'Invoke-fahCommand\setPower: Expected (full|medium|light)'
		}
	}
	'onIdle'	{
		if($argument -as [bool]){
			$parsed = FAHClient --send-command "option power $argument"
		}
		$parsed = 'Invoke-fahCommand\onIdle: Expected boolean'
	}
	default		{
		$parsed = 'Invoke-fahCommand: Unknown Command'
	}
}

return $parsed