Scriptname vMYC_Trophy_CivilWar extends vMYC_TrophyBase
{Player has chosen a side in the civil war.}

;--=== Imports ===--

Import Utility
Import Game

;=== Constants ===--

Int				Property	TROPHY_CW_IMPERIALS 	= 0x00000001	AutoReadonly Hidden
Int				Property	TROPHY_CW_STORMCLOAKS 	= 0x00000002	AutoReadonly Hidden
Int				Property	TROPHY_CW_COMPLETED	 	= 0x00000004	AutoReadonly Hidden

;--=== Properties ===--

Actor		Property	PlayerREF			Auto

Faction 	Property	CWImperialFaction	Auto
Faction 	Property	CWSonsFaction		Auto

GlobalVariable	Property	CWPlayerAllegiance						Auto

;--=== Variables ===--

;--=== Events/Functions ===--

Function CheckVars()

	TrophyName  	= "CivilWar"
	TrophyFullName  = "Civil War"
	TrophyPriority 	= 4
	
	TrophyType 		= TROPHY_TYPE_BANNER
	TrophySize		= TROPHY_SIZE_LARGE
	TrophyLoc		= TROPHY_LOC_WALLBACK
	;TrophyExtras	= 0
	
EndFunction

Int Function IsAvailable()
{Return >1 if this trophy is available to the current player. Higher values may be used to indicate more complex results.}
	
	Int iTrophyFlags = 0
	
	;Don't bother unless the player has chosen a side
	If !Quest.GetQuest("CW02A").IsCompleted() && !Quest.GetQuest("CW02B").IsCompleted()
		;DebugTrace("Player has not chosen a side! iTrophyFlags = " + iTrophyFlags)
		Return iTrophyFlags
	EndIf
	
	;Get player's CW faction
	If PlayerREF.IsInFaction(CWImperialFaction)
		iTrophyFlags += TROPHY_CW_IMPERIALS
		;DebugTrace("Player is in Imperial faction! iTrophyFlags = " + iTrophyFlags)
	ElseIf PlayerREF.IsInFaction(CWSonsFaction)
		iTrophyFlags += TROPHY_CW_STORMCLOAKS
		;DebugTrace("Player is in Stormcloak faction! iTrophyFlags = " + iTrophyFlags)
	EndIf

	;See if civil war is complete
	Quest kGoalQuest = Quest.GetQuest("CWSiegeObj")
	If kGoalQuest
		If kGoalQuest.IsCompleted()
			iTrophyFlags += TROPHY_CW_COMPLETED
			;DebugTrace("Player has finished the CW! iTrophyFlags = " + iTrophyFlags)
		EndIf
	EndIf
	
	Return iTrophyFlags
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
