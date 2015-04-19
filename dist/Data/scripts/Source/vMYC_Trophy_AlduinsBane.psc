Scriptname vMYC_Trophy_AlduinsBane extends vMYC_TrophyBase
{Player has killed Alduin.}

;=== Imports ===--

Import Utility
Import Game

;=== Constants ===--

;=== Properties ===--

ObjectReference[]	Property	TemplateObjects		Auto

;=== Variables ===--

Int[] _iTrophyIDs

;=== Events/Functions ===--

Event OnTrophyInit()
	TrophyName  	= "AlduinsBane"
	TrophyFullName  = "Alduin's Bane"
	TrophyPriority 	= 1
	
	TrophyType 		= TROPHY_TYPE_OBJECT
	TrophySize		= TROPHY_SIZE_LARGE
	TrophyLoc		= TROPHY_LOC_WALLBACK
	;TrophyExtras	= 0
	
EndEvent

Event OnSetTemplate()
	_iTrophyIDs 		= SetTemplateArray(TemplateObjects)
EndEvent

;Overwrites vMYC_TrophyBase@IsAvailable
Int Function IsAvailable()
{Return >1 if this trophy is available to the current player. Higher values may be used to indicate more complex results.}
	
	Quest kGoalQuest = Quest.GetQuest("MQ305")
	If kGoalQuest
		Return kGoalQuest.IsCompleted() as Int
	EndIf
	Return 0

EndFunction

Event OnDisplayTrophy(Int aiDisplayFlags)
{User code for display.}
	
	If aiDisplayFlags
		DisplayFormArray(_iTrophyIDs)
	EndIf

EndEvent

Int Function Remove()
{User code for hide.}
	Return 1
EndFunction

Int Function ActivateTrophy()
{User code for activation.}
	Return 1
EndFunction


Int Function Display(Int aiDisplayFlags = 0)
{User code for display.}
	Return 1
EndFunction

