Scriptname vFFP_Trophy_ArchMage extends vFFP_TrophyBase
{Player has become Archmage.}

;=== Imports ===--

Import Utility
Import Game

;=== Constants ===--

;=== Properties ===--

ObjectReference[]	Property	ArchmageObjects		Auto

;=== Variables ===--

Int[] _iTrophyIDs

;=== Events/Functions ===--

Event OnTrophyInit()
	TrophyName  	= "Archmage"
	TrophyFullName  = "Archmage of Winterhold College"
	TrophyPriority 	= 4
	
	TrophyType 		= TROPHY_TYPE_SEAL
	TrophySize		= TROPHY_SIZE_LARGE
	TrophyLoc		= TROPHY_LOC_WALLBACK
	;TrophyExtras	= 0
	
EndEvent

Event OnSetTemplate()
	_iTrophyIDs 		= SetTemplateArray(ArchmageObjects)
EndEvent

;Overwrites vFFP_TrophyBase@IsAvailable
Int Function IsAvailable()
{Return >1 if this trophy is available to the current player. Higher values may be used to indicate more complex results.}
	
	Int iTrophyFlags = 0
	
	Quest kGoalQuest = Quest.GetQuest("MG08")
	If kGoalQuest
		iTrophyFlags = kGoalQuest.IsCompleted() as Int
	EndIf
	
	Return iTrophyFlags
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

