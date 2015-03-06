Scriptname vMYC_TrophyTemplate extends vMYC_TrophyBase
{Template for trophy plugins. Don't modify this script! Extend it and modify that.}

;=== Imports ===--

Import Utility
Import Game

;=== Constants ===--

;=== Properties ===--

;=== Variables ===--

;=== Events/Functions ===--

Event OnTrophySelfMessage(String asMessage)
	
EndEvent

Function CheckVars()
{Can be used to set the trophy's properties if you don't want to do it in the quest.}
	;TrophyName  	= "A Pizza Trophy"
	;TrophyType  	= TROPHY_TYPE_WALLMOUNT
	;TrophyPriority = 0
EndFunction

Int Function IsAvailable()
{Return >1 if this trophy is available to the current player. Higher values may be used to indicate more complex results.}

	Return 0
EndFunction

Int Function Display(Int aiDisplayFlags = 0)
{User code for display.}
	Return 1
EndFunction

Int Function Remove()
{User code for hide.}
	Return 1
EndFunction

Int Function ActivateTrophy()
{User code for activation.}
	Return 1
EndFunction
