Scriptname vMYC_Trophy_MiraakMask extends vMYC_TrophyBase
{Player has killed Miraak}

;--=== Imports ===--

Import Utility
Import Game

;=== Constants ===--

;--=== Properties ===--

Static	Property	vMYC_ShrineDLC2MiraakHelm	Auto

;--=== Variables ===--

;--=== Events/Functions ===--

Function CheckVars()

	BaseX 		= 	-77.0
	BaseY 		= 	 21.0
	BaseZ 		= 	  6.2352
	AngleX 		= 	-53.7840
	AngleY 		= 	 18.8350
	AngleZ 		= 	 13.3018
	Scale 		= 	  1.24
	
	TrophyName  	= "Miraak's Mask"
	TrophyPriority 	= 2
	
	TrophyType 		= TROPHY_TYPE_OBJECT
	TrophySize		= TROPHY_SIZE_SMALL
	TrophyLoc		= TROPHY_LOC_PLINTH
	;TrophyExtras	= 0
	
EndFunction

Bool Function IsAvailable()
{Return true if this trophy is available to the current player.}
	Quest kGoalQuest = Quest.GetQuest("DLC2MQ06") ;Only filled if Dragonborn is loaded
	If kGoalQuest
		Return kGoalQuest.IsCompleted()
	EndIf
	Return False
EndFunction

Int Function Display()
{User code for display}
	PlaceForm(vMYC_ShrineDLC2MiraakHelm)
	
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
