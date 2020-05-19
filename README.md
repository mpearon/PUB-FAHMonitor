# Folding@Home Monitor

## Purpose
This script's purpose is to make monitoring and controlling remote Folding@Home instances easier.

## Featues
*As features are implemented, the will be added to this list*
- HTTP Listener - Allows predefined FAHClient commands to be run on remote folder, returning results via HTTP endpoint

## Proposed Features
*Ideas for new features will be added to this list*
- [ ] Listener - *Access FAHClient locally, parse results and return via HTTP/HTTPS endpoint*
	- [X] HTTP/HTTPS Listener implemented in PowerShell
		- [ ] Support Authentication
			- Basic
			- Header
	- Supported Requests
		- [X] GET Queue Info ( ```queue-info``` )
		- [X] GET Power Level ( ```options power``` )
		- [X] SET Power Level ( ```option power <light|medium|full>``` )
		- [X] GET Donor ID / Name ( ```options user``` )
		- [X] GET Team ID / Name ( ```options team``` )
		- [X] SET Pause All Slots ( ```pause *``` )
		- [X] SET Unpause All Slots ( ```unpause *``` )
		- [X] SET onIdle All Slots ( ```on_idle *``` )
		- [X] SET Finish All Slots ( ```finish *``` )
- [ ] Output Options
	- [ ] Return InfluxDB output when requested
	- [ ] Return Prometheus output when requested
	- [ ] Return Custom output when requested

## Settings
No configurable settings at this time.

## Known Issues
To report issues, use [this link](https://github.com/mpearon/PUB-FAHMonitor/issues).

## Release Notes
Reference [CHANGELOG](https://github.com/mpearon/PUB-FAHMonitor/blob/master/CHANGELOG.md) for documentation about changes made to this repository