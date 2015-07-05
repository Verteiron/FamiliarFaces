Scriptname vFFP_Trophy_Gatherer extends vFFP_TrophyBase
{Trophy for hunting/gathering lots of food.}

;=== Imports ===--

Import Utility
Import Game

;=== Constants ===--

Int		Property	TROPHY_G_SHOWRACK1 	= 0x00000001	AutoReadonly Hidden
Int		Property	TROPHY_G_SHOWRACK2	= 0x00000002	AutoReadonly Hidden
Int		Property	TROPHY_G_SHOWRACK3	= 0x00000004	AutoReadonly Hidden
Int		Property	TROPHY_G_SHOWGAME	= 0x00000008	AutoReadonly Hidden
Int		Property	TROPHY_G_SHOWHERBS	= 0x00000016	AutoReadonly Hidden
Int		Property	TROPHY_G_SHOWLOTS	= 0x00000032	AutoReadonly Hidden
Int		Property	TROPHY_G_SHOWRABBIT	= 0x00000064	AutoReadonly Hidden

;=== Properties ===--

ObjectReference		Property	TemplateAnchor		Auto
ObjectReference		Property	TemplateRack1		Auto
ObjectReference		Property	TemplateRack2		Auto
ObjectReference		Property	TemplateRack3		Auto

ObjectReference[]	Property	TemplateHerbs1		Auto
ObjectReference[]	Property	TemplateGame1		Auto

ObjectReference[]	Property	TemplateHerbs2		Auto
ObjectReference[]	Property	TemplateGame2		Auto

ObjectReference[]	Property	TemplateHerbs3		Auto
ObjectReference[]	Property	TemplateGame3		Auto

;=== Variables ===--

Int		_iAnchorID
Int[]	_iRackIDs
Int[]	_iHerb1IDs
Int[]	_iGame1IDs
Int[]	_iHerb2IDs
Int[]	_iGame2IDs
Int[]	_iHerb3IDs
Int[]	_iGame3IDs

;=== Events/Functions ===--

Event OnTrophyInit()
{Set properties, do anything else that needs doing at startup.}
	TrophyName  	= "Gatherer"
	TrophyFullName  = "Hunting and Gathering"
	TrophyPriority 	= 10
	
	TrophyType 		= TROPHY_TYPE_CUSTOM
	TrophySize		= TROPHY_SIZE_MEDIUM
	TrophyLoc		= TROPHY_LOC_ENTRYINNER
	;TrophyExtras	= 0
	
EndEvent

Event OnSetTemplate()
	_iAnchorID = SetTemplate(TemplateAnchor)
	_iRackIDs = New Int[3]
	_iRackIDs[0] = SetTemplate(TemplateRack1)
	_iRackIDs[1] = SetTemplate(TemplateRack2)
	_iRackIDs[2] = SetTemplate(TemplateRack3)
	
	_iHerb1IDs = SetTemplateArray(TemplateHerbs1)
	_iGame1IDs = SetTemplateArray(TemplateGame1)
	_iHerb2IDs = SetTemplateArray(TemplateHerbs2)
	_iGame2IDs = SetTemplateArray(TemplateGame2)
	_iHerb3IDs = SetTemplateArray(TemplateHerbs3)
	_iGame3IDs = SetTemplateArray(TemplateGame3)
EndEvent

Event OnDisplayTrophy(Int aiDisplayFlags)
{User code for display.}
	If !aiDisplayFlags
		Return
	EndIf
	DisplayForm(_iAnchorID)
	
	Bool bShowGame 		= Math.LogicalAnd(aiDisplayFlags,TROPHY_G_SHOWGAME) as Bool
	Bool bShowHerbs 	= Math.LogicalAnd(aiDisplayFlags,TROPHY_G_SHOWHERBS) as Bool
	Bool bShowLots 		= Math.LogicalAnd(aiDisplayFlags,TROPHY_G_SHOWLOTS) as Bool
	Bool bShowRabbit 	= Math.LogicalAnd(aiDisplayFlags,TROPHY_G_SHOWRABBIT) as Bool
	
	If Math.LogicalAnd(aiDisplayFlags,TROPHY_G_SHOWRACK1)
		DisplayForm(_iRackIDs[0])
		DisplayFormArray(_iHerb1IDs)
		If bShowGame
			DisplayFormArray(_iGame1IDs)
		EndIf
	EndIf
	If Math.LogicalAnd(aiDisplayFlags,TROPHY_G_SHOWRACK2)
		DisplayForm(_iRackIDs[1])
		DisplayFormArray(_iHerb2IDs)
		If bShowGame
			DisplayFormArray(_iGame2IDs)
		EndIf
	EndIf
	If Math.LogicalAnd(aiDisplayFlags,TROPHY_G_SHOWRACK3)
		DisplayForm(_iRackIDs[2])
		DisplayFormArray(_iHerb3IDs)
		If bShowGame
			DisplayFormArray(_iGame3IDs)
		EndIf
	EndIf
	If bShowLots
		; Really dedicated gatherer, but how do we show it?
	EndIf
	If bShowGame
		
	EndIf
	
	If bShowRabbit
		; Lots of bunnies slaughtered, but what do we do about it?
	EndIf
	
EndEvent

;Overwrites vFFP_TrophyBase@IsAvailable
Int Function IsAvailable()
{Return >1 if this trophy is available to the current player. Higher values may be used to indicate more complex results.}
	Int iTrophyFlags = 0
	
	Int iBunnies = QueryStat("Bunnies Slaughtered")
	Int iAnimals = QueryStat("Animals Killed")
	Int iIngredients = QueryStat("Ingredients Harvested")

	Float fPlaytime = GetRealHoursPassed()

	If (iIngredients + iAnimals) > 100
		iTrophyFlags += TROPHY_G_SHOWRACK1
	EndIf
	
	If (iIngredients + iAnimals) > 2000
		iTrophyFlags += TROPHY_G_SHOWRACK2
	EndIf
	
	If (iIngredients + iAnimals) > 4000
		iTrophyFlags += TROPHY_G_SHOWRACK3
	EndIf
	
	If (iIngredients + iAnimals) / fPlayTime > 50
		iTrophyFlags += TROPHY_G_SHOWLOTS
	EndIf	
	
	If iAnimals / fPlayTime > 2
		iTrophyFlags += TROPHY_G_SHOWGAME
	EndIf
	
	If iBunnies > 3
		iTrophyFlags += TROPHY_G_SHOWRABBIT
	EndIf
	
	Return iTrophyFlags
EndFunction
