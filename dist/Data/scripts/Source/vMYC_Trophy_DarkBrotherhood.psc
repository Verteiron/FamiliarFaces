Scriptname vMYC_Trophy_DarkBrotherhood extends vMYC_TrophyBase
{Player has completed the Dark Brotherhood quests, or destroyed the DB.}

;--=== Imports ===--

Import Utility
Import Game

;=== Constants ===--

;--=== Properties ===--

;--=== Variables ===--

;--=== Events/Functions ===--

Function CheckVars()

	TrophyName  	= "DarkBrotherhood"
	TrophyFullName  = "Dark Brotherhood"
	TrophyPriority 	= 4
	
	TrophyType 		= TROPHY_TYPE_BANNER
	TrophySize		= TROPHY_SIZE_LARGE
	TrophyLoc		= TROPHY_LOC_PLINTH
	;TrophyExtras	= 0
	
EndFunction

Int Function IsAvailable()
{Return >1 if this trophy is available to the current player. Higher values may be used to indicate more complex results.}
	
	;If brotherhood is destroyed, trophy is available
	Quest kGoalQuest = Quest.GetQuest("DBDestroy")
	If kGoalQuest
		If kGoalQuest.IsCompleted()
			Return 2
		EndIf
	EndIf
	
	;If brotherhood is NOT destroyed, trophy is available only if you completed the quest
	kGoalQuest = Quest.GetQuest("DB11") 
	If kGoalQuest
		Return kGoalQuest.IsCompleted() as Int
	EndIf
	
	Return 0
EndFunction

Int Function Display(Int aiDisplayFlags = 0)
{User code for display}
	
	;If aiDisplayFlags == 2, then the Brotherhood was destroyed
	
	
	;Otherwise, display the usual trophy
	
	
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
