# Folding@Home Monitor

## Purpose
This script's purpose is to make monitoring and controlling remote Folding@Home instances easier.

## Featues
*As features are implemented, the will be added to this list*

## Proposed Features
*Ideas for new features will be added to this list*
- [ ] Listener
	- [ ] HTTP/HTTPS Listener implemented in PowerShell
		- [ ] Support Authentication
			- Basic
			- Header
	- [ ] Will access FAH Shell locally, parse results then return requested information
	- Supported Requests
		- [ ] GET Queue Info ( ```queue-info``` )
		- [ ] GET Power Level ( ```options power``` )
		- [ ] SET Power Level ( ```option power <light|medium|full>```
		- [ ] GET Donor ID / Name ( ```options user``` )
		- [ ] GET Team ID / Name ( ```options team``` )
		- [ ] SET Pause All Slots ( ```pause *``` )
		- [ ] SET Unpause All Slots ( ```unpause *``` )
		- [ ] SET onIdle All Slots ( ```on_idle *``` )
		- [ ] SET Finish All Slots ( ```finish *``` )
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