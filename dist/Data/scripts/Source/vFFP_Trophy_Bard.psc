Scriptname vFFP_Trophy_Bard extends vFFP_TrophyBase
{Player has completed the bard quests.}

;=== Imports ===--

Import Utility
Import Game

;=== Constants ===--

;=== Properties ===--

ObjectReference		Property	BardStatic		Auto

;=== Variables ===--

Int		_iTrophyID

;=== Events/Functions ===--

Event OnTrophyInit()

	TrophyName  	= "Bard"
	TrophyFullName  = "Graduate of the Bard College"
	TrophyPriority 	= 4
	
	TrophyType 		= TROPHY_TYPE_OBJECT
	TrophySize		= TROPHY_SIZE_MEDIUM
	TrophyLoc		= TROPHY_LOC_PLINTHBASE
	;TrophyExtras	= 0
	
EndEvent

Event OnSetTemplate()
	_iTrophyID = SetTemplate(BardStatic)
EndEvent

;Overwrites vFFP_TrophyBase@IsAvailable
Int Function IsAvailable()
{Return >1 if this trophy is available to the current player. Higher values may be used to indicate more complex results.}
	Quest kGoalQuest = Quest.GetQuest("MS05") 
	If kGoalQuest
		Return kGoalQuest.IsCompleted() as Int
	EndIf
	Return 0
EndFunction

Event OnDisplayTrophy(Int aiDisplayFlags)
{User code for display.}
	If aiDisplayFlags
		DisplayForm(_iTrophyID)
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
