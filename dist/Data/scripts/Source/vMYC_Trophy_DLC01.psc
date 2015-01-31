Scriptname vMYC_Trophy_DLC01 extends vMYC_TrophyBase
{Various trophies for Dawnguard.}

;--=== Imports ===--

Import Utility
Import Game

;=== Constants ===--

;--=== Properties ===--

GlobalVariable Property DLC1PlayingVampireLine Auto ; 1 = Vampires, 0 = Dawnguard

Quest Property DLC1MQ02 Auto ; Bloodline, last quest before allegiance	(02002F65)
Quest Property DLC1MQ08 Auto ; Last quest of Dawnguard

ObjectReference		Property	TemplateCrossbow		Auto
ObjectReference		Property	TemplateChalice			Auto
ObjectReference		Property	TemplateSunPedestal		Auto

;Static				Property	vMYC_ShrineDLC1ChaliceBlood	Auto
;Static				Property	vMYC_ShrineDLC1Crossbow		Auto
;Static				Property	vMYC_ShrineDLC1SunPedestal	Auto

;--=== Variables ===--

;--=== Events/Functions ===--

Function CheckVars()

	TrophyName  	= "DLC01"
	TrophyPriority 	= 2
	
	TrophyType 		= TROPHY_TYPE_OBJECT
	TrophySize		= TROPHY_SIZE_MEDIUM
	TrophyLoc		= TROPHY_LOC_PLINTH
	;TrophyExtras	= 0
	
	If GetModByName("Dawnguard.esm") != 255 && !DLC1PlayingVampireLine
		DLC1PlayingVampireLine = GetFormFromFile(0x0200587A,"Dawnguard.esm") as GlobalVariable
		DLC1MQ02 = Quest.GetQuest("DLC1MQ02") ; Player has chosen a side
		DLC1MQ08 = Quest.GetQuest("DLC1MQ08") ; Player has finished the DLC
	EndIf
	
	;If !vMYC_ShrineDLC1ChaliceBlood
	;	vMYC_ShrineDLC1ChaliceBlood = ChaliceObj.GetBaseObject() as Static
	;EndIf
	;If !vMYC_ShrineDLC1Crossbow
	;	vMYC_ShrineDLC1Crossbow = CrossbowObj.GetBaseObject() as Static
	;EndIf
	;If !vMYC_ShrineDLC1SunPedestal
	;	vMYC_ShrineDLC1SunPedestal = SunPedestalObj.GetBaseObject() as Static
	;EndIf
EndFunction

Bool Function IsAvailable()
{Return true if this trophy is available to the current player.}
	If DLC1MQ02
		Return True
	EndIf
	Return False
EndFunction

Int Function Display()
{User code for display}
;	If DLC1MQ02.IsCompleted() ; Only handle dawnguard if player is actually doing the questline
;		If DLC1PlayingVampireLine.GetValue() == 1
			PlaceTemplate(TemplateChalice)
;		Else
			PlaceTemplate(TemplateCrossbow)
;		EndIf
;		If DLC1MQ08.IsCompleted()
			PlaceTemplate(TemplateSunPedestal)
;		EndIf
;	EndIf
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
