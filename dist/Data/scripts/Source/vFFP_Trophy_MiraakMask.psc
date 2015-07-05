Scriptname vFFP_Trophy_MiraakMask extends vFFP_TrophyBase
{Player has killed Miraak.}

;=== Imports ===--

Import Utility
Import Game

;=== Constants ===--

;=== Properties ===--

Static				Property	vFFP_ShrineDLC2MiraakHelm	Auto
ObjectReference[]	Property 	TemplateMiraakHelm	 		Auto


;=== Variables ===--

Int[]		iMaskIDs

;=== Events/Functions ===--

Event OnTrophyInit()
{Set properties, do anything else that needs doing at startup.}
	TrophyName  	= "DLC02"
	TrophyFullName  = "Miraak's Mask"
	TrophyPriority 	= 2
	
	TrophyType 		= TROPHY_TYPE_OBJECT
	TrophySize		= TROPHY_SIZE_SMALL
	TrophyLoc		= TROPHY_LOC_PLINTH
	;TrophyExtras	= 0
	LocalRotation	= True ; The mask spins about its local Z without this
EndEvent

Event OnSetTemplate()
{Create or set objects to be used as trophies.}
	;iMaskIDs = CreateTemplate(vFFP_ShrineDLC2MiraakHelm, -77.0, 21.0, 6.2352, -55.7451, 6.5581, 6.0, 1.24)
	iMaskIDs = SetTemplateArray(TemplateMiraakHelm)
EndEvent

Event OnDisplayTrophy(Int aiDisplayFlags)
{User code for display.}
	If aiDisplayFlags
		DisplayFormArray(iMaskIDs)
	EndIf
EndEvent

;Overwrites vFFP_TrophyBase@IsAvailable
Int Function IsAvailable()
{Return >1 if this trophy is available to the current player. Higher values may be used to indicate more complex results.}
	Quest kGoalQuest = Quest.GetQuest("DLC2MQ06") ;Only filled if Dragonborn is loaded
	If kGoalQuest
		Return kGoalQuest.IsCompleted() as Int
	EndIf
	Return 0
EndFunction
