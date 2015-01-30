Scriptname vMYC_Trophy_ThievesGuild extends vMYC_TrophyBase
{Player has mastered the Thieves Guild.}

;--=== Imports ===--

Import Utility
Import Game

;=== Constants ===--

;--=== Properties ===--

;--=== Variables ===--

;--=== Events/Functions ===--

Function CheckVars()
	TrophyName  	= "Master of the Thieves Guild"
	TrophyPriority 	= 4

	TrophyType 		= TROPHY_TYPE_OBJECT
	TrophySize		= TROPHY_SIZE_SMALL
	TrophyLoc		= TROPHY_LOC_PLINTHBASE
	;TrophyExtras	= 0
EndFunction

Bool Function IsAvailable()
{Return true if this trophy is available to the current player.}
	Quest kGoalQuest = Quest.GetQuest("TG09")
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
