Scriptname vFFP_Trophy_DLC01 extends vFFP_TrophyBase
{Various trophies for Dawnguard.}

;=== Imports ===--

Import Utility
Import Game

;=== Constants ===--

Int		Property	TROPHY_DG_CHOSEDAWNGUARD 	= 0x00000001	AutoReadonly Hidden
Int		Property	TROPHY_DG_CHOSEVAMPIRES 	= 0x00000002	AutoReadonly Hidden
Int		Property	TROPHY_DG_COMPLETED		 	= 0x00000004	AutoReadonly Hidden

;=== Properties ===--

GlobalVariable Property DLC1PlayingVampireLine Auto ; 1 = Vampires, 0 = Dawnguard

Quest Property DLC1VQ02 Auto ; Bloodline, last quest before allegiance	(02002F65)
Quest Property DLC1VQ08 Auto ; Last quest of Dawnguard

ObjectReference		Property	TemplateCrossbow		Auto
ObjectReference		Property	TemplateChalice			Auto
ObjectReference[]	Property 	TemplateCompletion 		Auto

;=== Variables ===--

Int		_iChoseDawnguardTrophyID
Int		_iChoseVampiresTrophyID
Int[]	_iCompletionTrophyIDs

;=== Events/Functions ===--

Event OnTrophyInit()
{Set properties, do anything else that needs doing at startup.}
	TrophyName  	= "DLC01"
	TrophyFullName  = "Dawnguard DLC"
	TrophyPriority 	= 2
	
	TrophyType 		= TROPHY_TYPE_OBJECT
	TrophySize		= TROPHY_SIZE_MEDIUM
	TrophyLoc		= TROPHY_LOC_PLINTH
	;TrophyExtras	= 0
	
	If GetModByName("Dawnguard.esm") != 255
		DLC1PlayingVampireLine = GetFormFromFile(0x0200587A,"Dawnguard.esm") as GlobalVariable
		DLC1VQ02 = Quest.GetQuest("DLC1VQ02") ; Player has chosen a side
		DLC1VQ08 = Quest.GetQuest("DLC1VQ08") ; Player has finished the DLC
		DebugTrace("DLC1VQ02 is " + DLC1VQ02 + "!")
		DebugTrace("DLC1VQ08 is " + DLC1VQ08 + "!")
	EndIf
EndEvent

Event OnSetTemplate()
	_iChoseDawnguardTrophyID 	= SetTemplate(TemplateCrossbow)
	_iChoseVampiresTrophyID 	= SetTemplate(TemplateChalice)
	_iCompletionTrophyIDs 		= SetTemplateArray(TemplateCompletion)
EndEvent

Event OnDisplayTrophy(Int aiDisplayFlags)
{User code for display.}
	If !aiDisplayFlags
		Return
	EndIf
	
	If Math.LogicalAnd(aiDisplayFlags,TROPHY_DG_CHOSEVAMPIRES)
		DisplayForm(_iChoseVampiresTrophyID)
	EndIf
	If Math.LogicalAnd(aiDisplayFlags,TROPHY_DG_CHOSEDAWNGUARD)
		DisplayForm(_iChoseDawnguardTrophyID)
	EndIf
	If Math.LogicalAnd(aiDisplayFlags,TROPHY_DG_COMPLETED)
		DisplayFormArray(_iCompletionTrophyIDs)
	EndIf
EndEvent

;Overwrites vFFP_TrophyBase@IsAvailable
Int Function IsAvailable()
{Return >1 if this trophy is available to the current player. Higher values may be used to indicate more complex results.}
	Int iTrophyFlags = 0
	If !DLC1VQ02
		CheckVars()
	EndIf
	If DLC1VQ02.IsCompleted() ; Only handle dawnguard if player is actually doing the questline
		If DLC1PlayingVampireLine.GetValue() == 1
			iTrophyFlags += TROPHY_DG_CHOSEVAMPIRES
		Else
			iTrophyFlags += TROPHY_DG_CHOSEDAWNGUARD
		EndIf
		If DLC1VQ08.IsCompleted()
			iTrophyFlags += TROPHY_DG_COMPLETED
		EndIf
	EndIf
	Return iTrophyFlags
EndFunction
