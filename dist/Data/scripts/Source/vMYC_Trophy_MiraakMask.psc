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
	
	TrophyName  	= "DLC02"
	TrophyFullName  = "Miraak's Mask"
	TrophyPriority 	= 2
	
	TrophyType 		= TROPHY_TYPE_OBJECT
	TrophySize		= TROPHY_SIZE_SMALL
	TrophyLoc		= TROPHY_LOC_PLINTH
	;TrophyExtras	= 0
	
EndFunction

Int Function IsAvailable()
{Return >1 if this trophy is available to the current player. Higher values may be used to indicate more complex results.}
	Quest kGoalQuest = Quest.GetQuest("DLC2MQ06") ;Only filled if Dragonborn is loaded
	If kGoalQuest
		Return kGoalQuest.IsCompleted() as Int
	EndIf
	Return 0
EndFunction

Int Function Display(Int aiDisplayFlags = 0)
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
