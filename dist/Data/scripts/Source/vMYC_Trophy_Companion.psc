Scriptname vMYC_Trophy_Companion extends vMYC_TrophyBase
{Player has completed the Companions quests.}

;--=== Imports ===--

Import Utility
Import Game

;=== Constants ===--

;--=== Properties ===--

;--=== Variables ===--

;--=== Events/Functions ===--

Function CheckVars()

	TrophyName  	= "Companion"
	TrophyFullName  = "Companion"
	TrophyPriority 	= 4
	
	TrophyType 		= TROPHY_TYPE_BANNER
	TrophySize		= TROPHY_SIZE_MEDIUM
	TrophyLoc		= TROPHY_LOC_PLINTHBASE
	;TrophyExtras	= 0
	
EndFunction

Int Function IsAvailable()
{Return >1 if this trophy is available to the current player. Higher values may be used to indicate more complex results.}
	Quest kGoalQuest = Quest.GetQuest("C06") 
	If kGoalQuest
		Return kGoalQuest.IsCompleted() as Int
	EndIf
	Return 0
EndFunction

Int Function Display(Int aiDisplayFlags = 0)
{User code for display}
	
	Return 1
EndFunction

Int Function Remove()
{User code for hide}
	Return 1
EndFunction

Int Function ActivateTrophy()
{User code for activation}
	Return 1
EndFunction
