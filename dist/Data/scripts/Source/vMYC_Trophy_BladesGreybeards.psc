Scriptname vMYC_Trophy_BladesGreybeards extends vMYC_TrophyBase
{Player has chosen the Greybeards or Blades (or both, thanks Arthmoor!)}

;--=== Imports ===--

Import Utility
Import Game

;=== Constants ===--

Int				Property	TROPHY_GB_GREYBEARDS 	= 0x00000001	AutoReadonly Hidden
Int				Property	TROPHY_GB_BLADES	 	= 0x00000002	AutoReadonly Hidden
Int				Property	TROPHY_GB_KILLEDPAARTH 	= 0x00000004	AutoReadonly Hidden

;--=== Properties ===--

Actor		Property	PlayerREF			Auto

Faction 	Property	BladesFaction		Auto
Faction 	Property	GreybeardFaction	Auto

ObjectReference		Property	TemplateBladesSword		Auto
ObjectReference		Property	TemplateBladesShield	Auto
ObjectReference		Property	TemplateBladesHelmet	Auto
ObjectReference		Property	TemplateBladesPillar	Auto
ObjectReference		Property	TemplateGreybeardBanner	Auto
ObjectReference		Property	TemplateGreybeardTablet	Auto
ObjectReference		Property	TemplateGreybeardShrine	Auto

;--=== Variables ===--

;--=== Events/Functions ===--

Event OnTrophyInit()

	TrophyName  	= "BladesGreybeards"
	TrophyFullName  = "Dragonborn's path"
	TrophyPriority 	= 4
	
	TrophyType 		= TROPHY_TYPE_BANNER
	TrophySize		= TROPHY_SIZE_LARGE
	TrophyLoc		= TROPHY_LOC_WALLBACK
	;TrophyExtras	= 0
	
EndEvent

Int Function IsAvailable()
{Return >1 if this trophy is available to the current player. Higher values may be used to indicate more complex results.}
	
	Int iTrophyFlags = 0
	
	;Don't bother unless the player has chosen a side
	If !Quest.GetQuest("MQ206").IsCompleted()
		DebugTrace("Player has not chosen a side! iTrophyFlags = " + iTrophyFlags)
		Return iTrophyFlags
	EndIf
	
	If PlayerREF.IsInFaction(BladesFaction)
		iTrophyFlags += TROPHY_GB_BLADES
		DebugTrace("Player is in Blades faction! iTrophyFlags = " + iTrophyFlags)
	ElseIf PlayerREF.IsInFaction(GreybeardFaction)
		iTrophyFlags += TROPHY_GB_GREYBEARDS
		DebugTrace("Player is in Greybeards faction! iTrophyFlags = " + iTrophyFlags)
	EndIf

	;See if Paarthurnax is alive
	ReferenceAlias rPaarthurnax = GetAliasByName("Paarthurnax") as ReferenceAlias
	If rPaarthurnax.GetReference() as Actor
		If (rPaarthurnax.GetReference() as Actor).IsDead()
			iTrophyFlags += TROPHY_GB_KILLEDPAARTH
			DebugTrace("Player is a horrible person :( iTrophyFlags = " + iTrophyFlags)
		Else
			DebugTrace("Player is a lovely, forgiving person! iTrophyFlags = " + iTrophyFlags)
		EndIf
	EndIf
	
	Return iTrophyFlags
EndFunction

Event OnDisplayTrophy(Int aiDisplayFlags)
{User code for display}
	
	;If aiDisplayFlags == 2, then the Brotherhood was destroyed
	
	
	;Otherwise, display the usual trophy
	
	
EndEvent

Int Function Remove()
{User code for hide}
	Return 1
EndFunction

Int Function ActivateTrophy()
{User code for activation}
	Return 1
EndFunction
