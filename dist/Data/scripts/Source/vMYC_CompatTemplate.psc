Scriptname vMYC_CompatTemplate extends vMYC_CompatBase
{Template for compatibility modules.}

;=== Imports ===--

Import Utility
Import Game
Import vMYC_Registry

;=== Properties ===--

;=== Variables ===--

;=== Events/Functions ===--

Bool Function IsRequired()
{Return true if the mod that this module supports is installed.}

	Return False
EndFunction

Int Function StartModule()
{User code for startup.}
	Return 1
EndFunction

Int Function StopModule()
{User code for shutdown.}
	Return 1
EndFunction

Int Function UpkeepModule()
{User code for upkeep.}
	Return 1
EndFunction

Function CheckVars()
{Any extra variables that might need setting up during OnInit. Will also be run OnGameLoad.}

EndFunction
