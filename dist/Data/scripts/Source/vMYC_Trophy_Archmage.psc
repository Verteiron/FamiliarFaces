Scriptname vMYC_Trophy_ArchMage extends vMYC_TrophyBase
{Player has become Archmage.}

;--=== Imports ===--

Import Utility
Import Game

;=== Constants ===--

;--=== Properties ===--

;--=== Variables ===--

;--=== Events/Functions ===--

Function CheckVars()
	TrophyName  	= "Archmage of Winterhold College"
	TrophyPriority 	= 4
	
	TrophyType 		= TROPHY_TYPE_SEAL
	TrophySize		= TROPHY_RADIUS_LARGE
	TrophyLoc		= TROPHY_LOC_WALLBACK
	;TrophyExtras	= 0
EndFunction

Bool Function IsAvailable()
{Return true if this trophy is available to the current player.}
	Quest kGoalQuest = Quest.GetQuest("MG08")
	If kGoalQuest
		Return kGoalQuest.IsCompleted()
	EndIf
	Return False
EndFunction

Int Function Display()
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
