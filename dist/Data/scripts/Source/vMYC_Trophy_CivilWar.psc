Scriptname vMYC_Trophy_CivilWar extends vMYC_TrophyBase
{Player has chosen a side in the civil war.}

;--=== Imports ===--

Import Utility
Import Game

;=== Constants ===--

Int				Property	TROPHY_CW_IMPERIALS 	= 0x00000001	AutoReadonly Hidden
Int				Property	TROPHY_CW_STORMCLOAKS 	= 0x00000002	AutoReadonly Hidden
Int				Property	TROPHY_CW_COMPLETED	 	= 0x00000004	AutoReadonly Hidden

;--=== Properties ===--

Actor		Property	PlayerREF			Auto

Faction 	Property	CWImperialFaction	Auto
Faction 	Property	CWSonsFaction		Auto

GlobalVariable	Property	CWPlayerAllegiance						Auto

Location 		Property 	SolitudeLocation 		Auto
Location 		Property 	WinterholdLocation 		Auto
Location 		Property 	WindhelmLocation 		Auto
Location 		Property 	RiftenLocation 			Auto
Location 		Property 	WhiterunLocation 		Auto
Location 		Property 	FalkreathLocation 		Auto
Location 		Property 	MorthalLocation 		Auto
Location 		Property 	MarkarthLocation 		Auto
Location 		Property 	DawnstarLocation 		Auto
Location 		Property 	KarthwastenLocation 	Auto
Location 		Property 	DragonBridgeLocation 	Auto
Location 		Property 	RoriksteadLocation 		Auto
Location 		Property 	HelgenLocation 			Auto
Location 		Property 	IvarsteadLocation 		Auto
Location 		Property 	ShorsStoneLocation 		Auto
Location 		Property 	RiverwoodLocation 		Auto
Location 		Property 	FortGreymoorLocation 	Auto
Location 		Property 	FortSungardLocation 	Auto
Location 		Property 	FortHraggstadLocation 	Auto
Location 		Property 	FortDunstadLocation 	Auto
Location 		Property 	FortKastavLocation 		Auto
Location 		Property 	FortAmolLocation 		Auto
Location 		Property 	FortGreenwallLocation 	Auto
Location 		Property 	FortNeugradLocation 	Auto
Location 		Property 	FortSnowhawkLocation 	Auto
	
Keyword 		Property 	CWOwner 				Auto
{Keyword to check on the location to figure out who owns it:
1 = Imperials
2 = Stormcloaks
-1 = nobody}

ObjectReference	Property	CWMapBoard				Auto
ObjectReference	Property	CWMap					Auto

;--=== Variables ===--

Location[] 	_kLocations

Int			_iCWMapBoardID
Int			_iCWMapID

;--=== Events/Functions ===--

Event OnTrophyInit()

	TrophyName  	= "CivilWar"
	TrophyFullName  = "Civil War"
	TrophyPriority 	= 4
	
	TrophyType 		= TROPHY_TYPE_BANNER
	TrophySize		= TROPHY_SIZE_LARGE
	TrophyLoc		= TROPHY_LOC_WALLBACK
	;TrophyExtras	= 0
	
	_kLocations = New Location[25]
	_kLocations[00] = SolitudeLocation
	_kLocations[01] = WinterholdLocation
	_kLocations[02] = WindhelmLocation
	_kLocations[03] = RiftenLocation
	_kLocations[04] = WhiterunLocation
	_kLocations[05] = FalkreathLocation
	_kLocations[06] = MorthalLocation
	_kLocations[07] = MarkarthLocation
	_kLocations[08] = DawnstarLocation
	_kLocations[09] = KarthwastenLocation
	_kLocations[10] = DragonBridgeLocation
	_kLocations[11] = RoriksteadLocation
	_kLocations[12] = HelgenLocation
	_kLocations[13] = IvarsteadLocation
	_kLocations[14] = ShorsStoneLocation
	_kLocations[15] = RiverwoodLocation
	_kLocations[16] = FortGreymoorLocation
	_kLocations[17] = FortSungardLocation
	_kLocations[18] = FortHraggstadLocation
	_kLocations[19] = FortDunstadLocation
	_kLocations[20] = FortKastavLocation
	_kLocations[21] = FortAmolLocation
	_kLocations[22] = FortGreenwallLocation
	_kLocations[23] = FortNeugradLocation
	_kLocations[24] = FortSnowhawkLocation
	
EndEvent

Event OnSetTemplate()
	_iCWMapBoardID 	= SetTemplate(CWMapBoard)
	_iCWMapID 		= SetTemplate(CWMap)
EndEvent

Int Function IsAvailable()
{Return >1 if this trophy is available to the current player. Higher values may be used to indicate more complex results.}
	
	;Don't bother with anything else unless the player has chosen a side
	If !Quest.GetQuest("CW02A").IsCompleted() && !Quest.GetQuest("CW02B").IsCompleted()
		;DebugTrace("Player has not chosen a side! iTrophyFlags = " + iTrophyFlags)
		Return iTrophyFlags
	EndIf

	Int iTrophyFlags = 0

	Int[] iLocationOwners = New Int[25]
	Int i = _kLocations.Length
	While i > 0
		i -= 1
		iLocationOwners[i] = GetCWOwner(_kLocations[i])
	EndWhile
	SaveIntArray(iLocationOwners,"LocationOwners")
	
	;Get player's CW faction
	If PlayerREF.IsInFaction(CWImperialFaction)
		iTrophyFlags += TROPHY_CW_IMPERIALS
		;DebugTrace("Player is in Imperial faction! iTrophyFlags = " + iTrophyFlags)
	ElseIf PlayerREF.IsInFaction(CWSonsFaction)
		iTrophyFlags += TROPHY_CW_STORMCLOAKS
		;DebugTrace("Player is in Stormcloak faction! iTrophyFlags = " + iTrophyFlags)
	EndIf

	;See if civil war is complete
	Quest kGoalQuest = Quest.GetQuest("CWSiegeObj")
	If kGoalQuest
		If kGoalQuest.IsCompleted()
			iTrophyFlags += TROPHY_CW_COMPLETED
			;DebugTrace("Player has finished the CW! iTrophyFlags = " + iTrophyFlags)
		EndIf
	EndIf
	
	Return iTrophyFlags
EndFunction

Int Function GetCWOwner(Location akLocation)
	Return akLocation.GetKeywordData(CWOwner) as Int
EndFunction

Event OnDisplayTrophy(Int aiDisplayFlags)
{User code for display}
	
	If aiDisplayFlags
		ReserveBanner(0) ; Prevent banner from being placed directly left of the statue
		DisplayForm(_iCWMapBoardID)
		DisplayForm(_iCWMapID)
	EndIf
	
EndEvent

Int Function Remove()
{User code for hide}
	Return 1
EndFunction

Int Function ActivateTrophy()
{User code for activation}
	Return 1
EndFunction
