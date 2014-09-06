Scriptname vMYC_CharacterManagerScript extends Quest
{Save and restore character data independently of save files. Requires SKSE and PapyrusUtils}

;--=== Imports ===--

Import Utility
Import Game
Import vMYC_Config

;--=== Properties ===--

vMYC_HangoutManager Property HangoutManager Auto

Int Property SerializationVersion = 3 Auto Hidden

String[] Property CharacterNames Hidden
{List of character names}
	String[] Function Get()
		Int jCharacterNames = JMap.allKeys(JValue.solveObj(_jMYC,".CharacterList"))
		String[] sCharacterNames = New String[32]
		Int i = JArray.Count(jCharacterNames)
		While i > 0
			i -= 1
			sCharacterNames[i] = JArray.getStr(jCharacterNames,i)
		EndWhile
		Return sCharacterNames
	EndFunction
EndProperty

String[] Property AVNames Hidden
{List of actor values}
	String[] Function Get()
		Return _sAVNames
	EndFunction
EndProperty

Int Property jMYC Hidden
	Int Function Get()
		Return JDB.solveObj(".vMYC")
	EndFunction
EndProperty

vMYC_PlayerInventoryTrackerScript	Property	PlayerInventoryTracker	Auto

ObjectReference Property LoadPoint Auto

Activator Property vMYC_CustomMapMarker	Auto

String[] Property sHangoutNames Auto Hidden

String	Property	DataPath	Auto Hidden

ReferenceAlias[] Property kHangoutRefAliases Auto Hidden

ReferenceAlias	Property	CustomLocMarkerAlias	Auto

LocationAlias	Property	kLastPlayerLocation Auto

LocationAlias[]	Property	kCustomLocations Auto

ObjectReference[] Property	CustomMapMarkers Auto

Formlist Property	vMYC_CustomLocationsList Auto

String[] Property sClassNames Auto

Class[] Property kClasses Auto

CombatStyle[] Property kCombatStyles Auto

Formlist Property vMYC_CombatStyles Auto

Formlist Property vMYC_PlayerShoutCheckList Auto

Bool[] Property bMagicUser Auto

FavorJarlsMakeFriendsScript Property ThaneTracker Auto

Quest Property MQ305 Auto ; Main quest sequence

Quest Property C06 Auto ; Companions

Quest Property TG09 Auto ; Thieves Guild

Quest Property DB11 Auto ; Dark Brotherhood completion

Quest Property DBDestroy Auto ; Destroy the Dark Brotherhood

Quest Property MQ206 Auto ; Has Sky Haven and knows Paarthurnax

Quest Property MQPaarthurnax Auto ; Kill Paarthurnax

Quest Property MS05 Auto ; Bard's college quest

Quest Property MG08 Auto ; Eye of Magnus quest

Spell Property	WerewolfChange Auto ; Beast form, if player has this then they're a worwelf

Spell Property	DLC1VampireChange	Auto ; Vampire lord form, if player has this then they're a wampire

;Dawnguard

GlobalVariable Property DLC1PlayingVampireLine Auto ; 1 = Vampires, 0 = Dawnguard

Quest Property DLC1MQ02 Auto ; Bloodline, last quest before allegiance	(02002F65)

Quest Property DLC1MQ08 Auto ; Last quest of Dawnguard

;Dragonborn

Quest Property DLC2MQ06 Auto ; Final fight with Miraak "Summit of Apocrypha"



Faction Property CWImperialFaction Auto

Faction Property CWSonsFaction Auto

Quest Property CWSiegeObj Auto ; Battle for Solitude/Windhelm

ReferenceAlias Property alias_MageCharacter Auto
{Hang around the College at Winterhold}

ReferenceAlias Property alias_ThiefCharacter Auto
{Hang around Riften and the Ragged Flagon}

ReferenceAlias Property alias_BardCharacter Auto
{Hang around the Bard's college}

ReferenceAlias Property alias_StormcloakCharacter Auto
{Hang around Windhelm and Ulfric's court}

ReferenceAlias Property alias_ImperialCharacter Auto
{Hang around the Blue Palace}

ReferenceAlias Property alias_CompanionCharacter Auto
{Hang around Jorrvaskr}

ReferenceAlias Property alias_GreybeardCharacter Auto
{Hang around High Hrothgar}

ReferenceAlias Property alias_BladeCharacter Auto
{Hang around in the Sky Haven Temple}

ReferenceAlias Property alias_DawnstarCharacter Auto
{Hang around Dawnstar}

ReferenceAlias Property alias_FalkreathCharacter Auto
{Hang around Falkreath}

ReferenceAlias Property alias_MarkarthCharacter Auto
{Hang around Markarth}

ReferenceAlias Property alias_MorthalCharacter Auto
{Hang around Morthal}

ReferenceAlias Property alias_WhiterunCharacter Auto
{Hang around Whiterun}

ReferenceAlias Property alias_CaravanCharacter Auto
{Travel with a caravan}

ReferenceAlias Property alias_OrcCharacter Auto
{Hang around a stronghold}

ReferenceAlias[] Property alias_CustomCharacters Auto
{12 custom character slots, set to sandbox at a LocationAlias}

Actor Property PlayerRef Auto
{The Player, duh}

ActorBase Property vMYC_InvisibleMActor	Auto
{Invisible actor for collecting custom weapons}

Formlist Property vMYC_PlayerFormlist Auto
{An empty formlist that will be used to store all the player's spells, shouts, etc.}

Formlist Property vMYC_DummyActorsMList Auto
{Formlist containing the male dummy actors}

Formlist Property vMYC_DummyActorsFList Auto
{Formlist containing the female dummy actors}

Formlist Property vMYC_PerkCheckList Auto
{A list of all the perks we want to check for.}

Formlist Property vMYC_PerkList Auto
{A list of all perks as found by ActorValueInfo.}

Formlist Property vMYC_ShoutList Auto
{A list of all shouts as found by HasShout/ShoutCheckList.}

Formlist Property vMYC_VoiceTypesFollowerList Auto
{A list of voicetypes that can be followers.}

Formlist Property vMYC_VoiceTypesSpouseList Auto
{A list of voicetypes that can be married.}

Formlist Property vMYC_VoiceTypesAdoptList Auto
{A list of voicetypes that can be parents.}

Formlist Property vMYC_VoiceTypesAllList Auto
{A list of all (except unique/special) voicetypes.}

Formlist Property vMYC_ModCompatibility_PerkList_Unsafe Auto
{A list of Perks that are known to be unsafe or unnecessary to load on NPCs.}

TextureSet Property vMYC_PlayerFaceTexture Auto

TextureSet Property vMYC_DummyTexture Auto

Message Property vMYC_CharactersLoadingMSG Auto
Message Property vMYC_CharactersLoadedMSG Auto
Message	Property vMYC_CharacterListLoadedMSG Auto
Message Property vMYC_ReqMissingNagMSG Auto
Message Property vMYC_ReqMissingCharMinorMSG Auto
Message Property vMYC_ReqMissingCharWarningMSG Auto
Message Property vMYC_ReqMissingCharCriticalMSG Auto


;--=== Config variables ===--

;--=== Variables ===--

Bool _bSavedPerks = False

Bool _bSavedSpells = False

Bool _bSavedEquipment = False

Bool _bSavedInventory = False

Bool _bDoInit = False

Bool _bDoUpkeep = False

Bool _bBusyLoading = False

Bool _bBusyEquipment = False

Bool _bFreeActorBaseBusy

Bool _bApplyPerksBusy = False

Bool _bApplyShoutsBusy = False

ActorBase[] _kDummyActors

;Because Formlists can't be trusted to stay in any sort of order

Actor[] _kLoadedCharacters

String[] _sAVNames

String[] _sCharacterNames

Int _jMYC

Float _fFlushTime

Location	_kLastPlayerLocation
Cell		_kLastPlayerCell
Float		_fLastPlayerPosX
Float		_fLastPlayerPosY
Float		_fLastPlayerPosZ

;--=== Events ===--


Event OnInit()
	_sCharacterNames = New String[128]

	_sAVNames = New String[86]
	_sAVNames[00] = "Health"
	_sAVNames[01] = "Magicka"
	_sAVNames[02] = "Stamina"
	_sAVNames[03] = "OneHanded"
	_sAVNames[04] = "TwoHanded"
	_sAVNames[05] = "Marksman"
	_sAVNames[06] = "Block"
	_sAVNames[07] = "Smithing"
	_sAVNames[08] = "HeavyArmor"
	_sAVNames[09] = "LightArmor"
	_sAVNames[10] = "Pickpocket"
	_sAVNames[11] = "Lockpicking"
	_sAVNames[12] = "Sneak"
	_sAVNames[13] = "Alchemy"
	_sAVNames[14] = "Speechcraft"
	_sAVNames[15] = "Alteration"
	_sAVNames[16] = "Conjuration"
	_sAVNames[17] = "Destruction"
	_sAVNames[18] = "Illusion"
	_sAVNames[19] = "Restoration"
	_sAVNames[20] = "Enchanting"
	;_sAVNames[21] = "Aggression"
	;_sAVNames[22] = "Confidence"
	;_sAVNames[23] = "Energy"
	;_sAVNames[24] = "Morality"
	;_sAVNames[25] = "Mood"
	;_sAVNames[26] = "Assistance"
	;_sAVNames[28] = "HealRate"
	;_sAVNames[29] = "MagickaRate"
	;_sAVNames[30] = "StaminaRate"
	;_sAVNames[31] = "attackDamageMult"
	;_sAVNames[32] = "SpeedMult"
	;_sAVNames[33] = "ShoutRecoveryMult"
	;_sAVNames[34] = "WeaponSpeedMult"
	;_sAVNames[35] = "InventoryWeight"
	;_sAVNames[36] = "CarryWeight"
	;_sAVNames[37] = "CritChance"
	_sAVNames[38] = "MeleeDamage"
	_sAVNames[39] = "UnarmedDamage"
	;_sAVNames[40] = "Mass"
	_sAVNames[41] = "VoicePoints"
	_sAVNames[42] = "VoiceRate"
	;_sAVNames[43] = "DamageResist"
	;_sAVNames[44] = "DiseaseResist"
	;_sAVNames[45] = "PoisonResist"
	;_sAVNames[46] = "FireResist"
	;_sAVNames[47] = "ElectricResist"
	;_sAVNames[48] = "FrostResist"
	;_sAVNames[49] = "MagicResist"
	;_sAVNames[50] = "Paralysis"
	;_sAVNames[51] = "Invisibility"
	;_sAVNames[52] = "NightEye"
	;_sAVNames[53] = "DetectLifeRange"
	;_sAVNames[54] = "WaterBreathing"
	;_sAVNames[55] = "WaterWalking"
	;_sAVNames[56] = "JumpingBonus"
	;_sAVNames[57] = "WardPower"
	;_sAVNames[58] = "WardDeflection"
;	_sAVNames[59] = "EquippedItemCharge"
;	_sAVNames[60] = "EquippedStaffCharge"
	;_sAVNames[61] = "ArmorPerks"
	;_sAVNames[62] = "ShieldPerks"
	;_sAVNames[63] = "BowSpeedBonus"
	;_sAVNames[64] = "DragonSouls"
;	_sAVNames[66] = "CombatHealthRegenMultMod"
;	_sAVNames[67] = "CombatHealthRegenMultPowerMod"
;	_sAVNames[68] = "PerceptionCondition"
;	_sAVNames[69] = "EnduranceCondition"
;	_sAVNames[70] = "LeftAttackCondition"
;	_sAVNames[71] = "RightAttackCondition"
;	_sAVNames[72] = "LeftMobilityCondition"
;	_sAVNames[73] = "RightMobilityCondition"
;	_sAVNames[74] = "BrainCondition"
;	_sAVNames[75] = "IgnoreCrippledLimbs"
;	_sAVNames[76] = "Fame"
;	_sAVNames[77] = "Infamy"
;	_sAVNames[78] = "FavorActive"
;	_sAVNames[79] = "FavorPointsBonus"
;	_sAVNames[80] = "FavorsPerDay"
;	_sAVNames[81] = "FavorsPerDayTimer"
;	_sAVNames[82] = "BypassVendorStolenCheck"
;	_sAVNames[83] = "BypassVendorKeywordCheck"
;	_sAVNames[84] = "LastBribedIntimidated"
;	_sAVNames[85] = "LastFlattered"

	sHangoutNames = New String[32]
	kHangoutRefAliases = New ReferenceAlias[32]

	sHangoutNames[0] = "$Winterhold College"
	sHangoutNames[1] = "$The Ragged Flagon"
	sHangoutNames[2] = "$Bard's College"
	sHangoutNames[3] = "$Palace of the Kings"
	sHangoutNames[4] = "$The Blue Palace"
	sHangoutNames[5] = "$Jorrvaskr"
	sHangoutNames[6] = "$High Hrothgar"
	sHangoutNames[7] = "$Sky Haven Temple"
	sHangoutNames[8] = "$Dawnstar"
	sHangoutNames[9] = "$Falkreath"
	sHangoutNames[10] = "$Markarth"
	sHangoutNames[11] = "$Morthal"
	sHangoutNames[12] = "$Whiterun"
	sHangoutNames[13] = "$Khajiit Caravan"
	sHangoutNames[14] = "$Dushnikh Yal"

	kHangoutRefAliases[0] = alias_MageCharacter
	kHangoutRefAliases[1] = alias_ThiefCharacter
	kHangoutRefAliases[2] = alias_BardCharacter
	kHangoutRefAliases[3] = alias_StormcloakCharacter
	kHangoutRefAliases[4] = alias_ImperialCharacter
	kHangoutRefAliases[5] = alias_CompanionCharacter
	kHangoutRefAliases[6] = alias_GreybeardCharacter
	kHangoutRefAliases[7] = alias_BladeCharacter
	kHangoutRefAliases[8] = alias_DawnstarCharacter
	kHangoutRefAliases[9] = alias_FalkreathCharacter
	kHangoutRefAliases[10] = alias_MarkarthCharacter
	kHangoutRefAliases[11] = alias_MorthalCharacter
	kHangoutRefAliases[12] = alias_WhiterunCharacter
	kHangoutRefAliases[13] = alias_CaravanCharacter
	kHangoutRefAliases[14] = alias_OrcCharacter

	kCombatStyles = New CombatStyle[20] ; Workaround since we can't set combatstyles as properties in CK

;0		Default
;1		AlftandTank
;2		Berserker
;3		Boss1H
;4		Boss2H
;5		Magic
;6		MeleeAllDefense
;7		Melee1
;8		Melee2
;9		Melee3
;10		Melee4
;11		Melee5
;12		Melee6
;13		Melee7
;14		Missile
;15		Tank1

	;CombatStyles match classes
	kCombatStyles[0] = vMYC_CombatStyles.GetAt(0) as CombatStyle ; Default
	kCombatStyles[1] = vMYC_CombatStyles.GetAt(7) as CombatStyle ; Assassin
	kCombatStyles[2] = vMYC_CombatStyles.GetAt(2) as CombatStyle ; Barbarian
	kCombatStyles[3] = vMYC_CombatStyles.GetAt(5) as CombatStyle ; Conjurer
	kCombatStyles[4] = vMYC_CombatStyles.GetAt(5) as CombatStyle ; Destruction
	kCombatStyles[5] = vMYC_CombatStyles.GetAt(5) as CombatStyle ; Elemental
	kCombatStyles[6] = vMYC_CombatStyles.GetAt(5) as CombatStyle ; Necro
	kCombatStyles[7] = vMYC_CombatStyles.GetAt(15) as CombatStyle ; Monk
	kCombatStyles[8] = vMYC_CombatStyles.GetAt(5) as CombatStyle ; Mystic
	kCombatStyles[9] = vMYC_CombatStyles.GetAt(10) as CombatStyle ; Nightblade
	kCombatStyles[10] = vMYC_CombatStyles.GetAt(13) as CombatStyle ; Nightengale
	kCombatStyles[11] = vMYC_CombatStyles.GetAt(14) as CombatStyle ; Ranger
	kCombatStyles[12] = vMYC_CombatStyles.GetAt(8) as CombatStyle ; Rogue
	kCombatStyles[13] = vMYC_CombatStyles.GetAt(14) as CombatStyle ; Scout
	kCombatStyles[14] = vMYC_CombatStyles.GetAt(5) as CombatStyle ; Sorcerer
	kCombatStyles[15] = vMYC_CombatStyles.GetAt(3) as CombatStyle ; Spellsword
	kCombatStyles[16] = vMYC_CombatStyles.GetAt(14) as CombatStyle ; Thief
	kCombatStyles[17] = vMYC_CombatStyles.GetAt(3) as CombatStyle ; Warrior1H
	kCombatStyles[18] = vMYC_CombatStyles.GetAt(4) as CombatStyle ; Warrior2H
	kCombatStyles[19] = vMYC_CombatStyles.GetAt(3) as CombatStyle ; Witchblade

EndEvent

Event OnUpdate()
	If _bDoInit
	EndIf
	If _bDoUpkeep
		_bDoUpkeep = False
		DoUpkeep(False)
	EndIf
EndEvent

Event OnSetLastPlayerLocation(string eventName, string strArg, float numArg, Form sender)
	If sender as Location
		_kLastPlayerLocation = sender as Location
	EndIf
	;Debug.Trace("MYC/CM: LastPlayerLocation is " + sender as Location + "(" + sender.GetName() + ")")
EndEvent

Event OnSetLastPlayerCell(string eventName, string strArg, float numArg, Form sender)
	If sender as Cell
		JMap.setForm(_jMYC,"LastCell",sender as Cell)
		_kLastPlayerCell = sender as Cell
	EndIf
	;Debug.Trace("MYC/CM: LastPlayerCell is " + sender as Cell + "(" + sender.GetName() + ")")
EndEvent

Event OnSetLastPlayerPos(string eventName, string strArg, float numArg, Form sender)
	If strArg == "x"
		_fLastPlayerPosX = numArg
	ElseIf strArg == "y"
		_fLastPlayerPosY = numArg
	ElseIf strArg == "z"
		_fLastPlayerPosZ = numArg
	EndIf
	;Debug.Trace("MYC/CM: LastPlayerPos is " + _fLastPlayerPosX + "," + _fLastPlayerPosY + "," + _fLastPlayerPosZ)
EndEvent

Event OnSetLocationAnchor(string eventName, string strArg, float numArg, Form sender)
	Int jLocationAnchors = JMap.getObj(_jMYC,"LocationAnchors")
	If !jLocationAnchors
		jLocationAnchors = JArray.Object()
		JMap.setObj(_jMYC,"LocationAnchors",jLocationAnchors)
	EndIf
	;Debug.Trace("MYC/CM: LocationAnchor: " + sender)
	JArray.AddForm(jLocationAnchors,sender as ObjectReference)
	;Debug.Trace("MYC/CM: LocationAnchor: " + sender + " added!")
EndEvent

;--=== Functions ===--

Function RegisterForModEvents()
	;Debug.Trace("MYC/CharacterManager: Registering for mod events...")
	RegisterForModEvent("vMYC_SetCustomHangout","OnSetCustomHangout")
EndFunction

Function DoUpkeep(Bool bInBackground = True)
	If bInBackground
		_bDoUpkeep = True
		RegisterForSingleUpdate(0)
		Return
	EndIf
	CleanupTempJContainers()
	SendModEvent("vMYC_UpkeepBegin")
	RegisterForModEvents()
	If !JContainers.fileExistsAtPath("Data/vMYC/vMYC_MovedFiles.txt")
		RepairSaves()
	EndIf
	LoadCharacterFiles()
	RefreshCharacters()
	SendModEvent("vMYC_UpkeepEnd")
EndFunction

Function DoInit()
	_bDoInit = True
	_jMYC = JDB.solveObj(".vMYC")
	If !_jMYC
		Debug.Trace("MYC/CM: JDB has no MYC data, creating it!")
		_jMYC = JMap.object()
		JDB.setObj("vMYC",_jMYC)
	EndIf
	RegisterForModEvents()
	SetUUIDIfMissing()
	_kDummyActors = New ActorBase[128]
	_kLoadedCharacters = New Actor[128]
	Int i = vMYC_DummyActorsFList.GetSize()
	Int idx = 0
	While i > 0
		i -= 1
		_kDummyActors[idx] = vMYC_DummyActorsFList.GetAt(i) as ActorBase
		idx += 1
	EndWhile
	i = vMYC_DummyActorsMList.GetSize()
	While i > 0
		i -= 1
		_kDummyActors[idx] = vMYC_DummyActorsMList.GetAt(i) as ActorBase
		idx += 1
	EndWhile
	idx = 0
	While idx < _kDummyActors.Length
		If _kDummyActors[idx]
			;Debug.Trace("MYC/CM: Slot " + idx + " is ActorBase " + _kDummyActors[idx].GetName() + " " + _kDummyActors[idx])
;			SetStringValue(_kDummyActors[idx],sKey + "Name","foo")
;			ExportFile(_kDummyActors[idx].GetName(),restrictForm = _kDummyActors[idx])
		EndIf
		idx += 1
	EndWhile
	If !JContainers.fileExistsAtPath("Data/vMYC/vMYC_MovedFiles.txt")
		RepairSaves()
	EndIf
	LoadCharacterFiles()
	If GetModByName("Dawnguard.esm") != 255
		DLC1PlayingVampireLine = GetFormFromFile(0x0200587A,"Dawnguard.esm") as GlobalVariable
		DLC1MQ02 = GetFormFromFile(0x02002F65,"Dawnguard.esm") as Quest
		DLC1MQ08 = GetFormFromFile(0x02007C25,"Dawnguard.esm") as Quest
		DLC1VampireChange = GetFormFromFile(0x0200283B,"Dawnguard.esm") as Spell
		vMYC_PlayerShoutCheckList.AddForm(GetFormFromFile(0x02007CB6,"Dawnguard.esm")) ; Soul Tear
	EndIf
	If GetModByName("Dragonborn.esm") != 255
		DLC2MQ06 = GetFormFromFile(0x020179D7,"Dragonborn.esm") as Quest
		vMYC_PlayerShoutCheckList.AddForm(GetFormFromFile(0x020179d8,"Dragonborn.esm")) ; Bend Will
		vMYC_PlayerShoutCheckList.AddForm(GetFormFromFile(0x0201df92,"Dragonborn.esm")) ; Dragon Aspect
		vMYC_PlayerShoutCheckList.AddForm(GetFormFromFile(0x020200c0,"Dragonborn.esm")) ; Cyclone
		vMYC_PlayerShoutCheckList.AddForm(GetFormFromFile(0x0202ad09,"Dragonborn.esm")) ; Battle Fury
	EndIf
	RegisterForSingleUpdate(1)
EndFunction

Function DoShutdown()
	UnregisterForUpdate()
	UnregisterForModEvent("vMYC_SetCustomHangout")
	
	String[] sCharacterNames = CharacterNames
	Int i = sCharacterNames.Length
	While i > 0
		i -= 1
		If sCharacterNames[i]
			EraseCharacter(sCharacterNames[i],True)
		EndIf
	EndWhile
	
EndFunction

Function RefreshCharacters()
	Int jActorMap = JMap.getObj(_jMYC,"ActorBaseMap")
	Int jActorBaseList = JFormMap.allKeys(jActorMap)
	Int i = JArray.Count(jActorBaseList)
	Int jDeferredActors = JArray.Object()
	JValue.Retain(jDeferredActors,"vMYC_CM")
	While i > 0
		i -= 1
		ActorBase kActorBase = JArray.getForm(jActorBaseList,i) as ActorBase
		If kActorBase
			String sCharacterName = JFormMap.getStr(jActorMap,kActorBase)
			Actor kTargetActor = GetCharacterActor(kActorBase)
			If kTargetActor.Is3DLoaded()
				;Debug.Trace("MYC/CM: Refreshing " + sCharacterName + ", ActorBase " + kActorBase)
				(kTargetActor as vMYC_CharacterDummyActorScript).DoUpkeep(True)
			Else
				JArray.AddForm(jDeferredActors,kTargetActor)
			EndIf
		EndIf
	EndWhile
	WaitMenuMode(8) ; Give loaded characters priority
	i = JArray.Count(jDeferredActors)
	While i > 0
		i -= 1
		Actor kTargetActor = JArray.getForm(jDeferredActors,i) as Actor
		;Debug.Trace("MYC/CM: Refreshing Actor " + kTargetActor)
		(kTargetActor as vMYC_CharacterDummyActorScript).DoUpkeep(True)
	EndWhile
	JValue.Release(jDeferredActors)
EndFunction

Function LoadCharacterFiles()
	Int jCharacterMap = JMap.Object()
	If !JMap.hasKey(_jMYC,"CharacterList")
		JMap.SetObj(_jMYC,"CharacterList",JMap.Object())
	EndIf
	jCharacterMap = JMap.getObj(_jMYC,"CharacterList")

	Int jCharacterNames = JMap.allKeys(jCharacterMap)
	;--- If there are any existing characters set their FilePresent to 0
	Int i = JArray.Count(jCharacterNames)
	While i > 0
		i -= 1
		SetLocalInt(jArray.getStr(jCharacterNames,i),"FilePresent",0)
	EndWhile

	;Debug.Trace("MYC/CM: Reading directory...")
	Int jDirectoryScan = JValue.readFromDirectory(JContainers.userDirectory() + "vMYC/")
	If !jDirectoryScan
		jDirectoryScan = JValue.readFromDirectory("Data/vMYC/")
	EndIf
	Int jCharFiles = JMap.allKeys(jDirectoryScan)
	Int jCharData = JMap.allValues(jDirectoryScan)
	
	JValue.AddToPool(jCharacterNames,"vMYC_CM_Load")
	JValue.AddToPool(jDirectoryScan,"vMYC_CM_Load")
	JValue.AddToPool(jCharFiles,"vMYC_CM_Load")
	JValue.AddToPool(jCharData,"vMYC_CM_Load")	
	
	;scan old location anyway, in case new character files have been copied there.
	Int jDirectoryScanOld = JValue.readFromDirectory("Data/vMYC/")
	Int jCharFilesOld = JMap.allKeys(jDirectoryScanOld)
	Int jCharDataOld = JMap.allValues(jDirectoryScanOld)
	
	JValue.AddToPool(jDirectoryScanOld,"vMYC_CM_Load")
	JValue.AddToPool(jCharFilesOld,"vMYC_CM_Load")
	JValue.AddToPool(jCharDataOld,"vMYC_CM_Load")	

	;If any files are in the old location but not the new one, add them to the list
	i = JMap.Count(jDirectoryScanOld)
	While i > 0
		i -= 1
		If JArray.FindStr(jCharFiles,JArray.GetStr(jCharFilesOld,i)) < 0
			Debug.Trace("MYC/CM: Adding file from Data/vMYC: " + JArray.getStr(jCharFilesOld,i))
			JArray.AddStr(jCharFiles,JArray.GetStr(jCharFilesOld,i))
			JArray.AddObj(jCharData,JArray.GetObj(jCharDataOld,i))
		EndIf
	EndWhile
	Bool _bHasFileSlot
	Bool _bHasFileTexture
	i = JArray.Count(jCharData)
	
	;--- Load and validate all files in the data directory
	While i > 0
		i -= 1
		Int jCharacterData = JArray.getObj(jCharData,i)
		If ValidateCharacterInfo(jCharacterData) > -1
			If UpgradeCharacterInfo(jCharacterData)
				;JValue.WriteToFile(jCharacterData,"Data/vMYC/" + JArray.getStr(jCharFiles,i)) ; write the file back if the data version was upgraded
				JValue.WriteToFile(jCharacterData,JContainers.userDirectory() + "vMYC/" + JArray.getStr(jCharFiles,i)) ; write the file back if the data version was upgraded
				WaitMenuMode(0.25)
			EndIf
			String sCharacterName = JValue.solveStr(jCharacterData,".Name")
			_bHasFileSlot = JContainers.fileExistsAtPath("Data/SKSE/Plugins/CharGen/Exported/" + sCharacterName + ".slot")
			_bHasFileTexture = JContainers.fileExistsAtPath("Data/Textures/CharGen/Exported/" + sCharacterName + ".dds")
			;Debug.Trace("MYC/CM: File " + i + " is " + JArray.getStr(jCharFiles,i) + " - " + sCharacterName)
			If !JMap.hasKey(jCharacterMap,sCharacterName) && _bHasFileSlot && _bHasFileTexture
				JMap.setStr(jCharacterMap,sCharacterName,JArray.getStr(jCharFiles,i))
				Int jCharacterInfo = JMap.Object()
				JMap.SetObj(_jMYC,sCharacterName,jCharacterInfo)
				JMap.SetObj(jCharacterInfo,"Data",jCharacterData)
				JMap.setObj(_jMYC,sCharacterName,jCharacterInfo)
				SetLocalInt(sCharacterName,"FilePresent",1)
				Message.ResetHelpMessage("vMYC_Nag")
				;Debug.Trace("MYC/CM: " + sCharacterName + " is a Level " + JValue.solveInt(jCharacterData,".Stats.Level") + " " + (JValue.solveForm(jCharacterData,".Race") as Race).GetName() + "!")
			Else
				;We're loading a file for a character we already have a record of.
				Int jCharacterInfo = JMap.getObj(_jMYC,sCharacterName)
				Float fFilePlayTime = JValue.solveFlt(jCharacterData,"._MYC.PlayTime")
				Float fLocalPlayTime = GetCharacterFlt(sCharacterName,"_MYC.PlayTime")
				If !HasLocalKey(sCharacterName,"PlayTime") ; added to 1.0.3
					SetLocalFlt(sCharacterName,"PlayTime",fLocalPlayTime)
				EndIf
				If fLocalPlayTime != fFilePlayTime
					Debug.Trace("MYC/CM: " + sCharacterName + "'s Local PlayTime is " + fLocalPlayTime + ", saved PlayTime is " + fFilePlayTime)
					Debug.Trace("MYC/CM: The saved data for " + sCharacterName + " HAS changed!")
					;SetLocalFlt(sCharacterName,"PlayTime",fFilePlayTime)
					JMap.setObj(jCharacterInfo,"Data",jCharacterData)
				Else
					;Debug.Trace("MYC/CM: The saved data for " + sCharacterName + " hasn't changed.")
					JMap.setObj(jCharacterInfo,"Data",jCharacterData) ; Set the object anyway in case new forms are available from the importing game
				EndIf
				If  _bHasFileSlot && _bHasFileTexture
					SetLocalInt(sCharacterName,"FilePresent",1)
				EndIf
			EndIf
		Else ; Validation failed
			;Debug.Trace("MYC/CM: File " + i + " is " + JArray.getStr(jCharFiles,i) + " - No valid character data!")
		EndIf
	EndWhile

	;--- See if any existing characters lost their files
	i = JArray.Count(jCharacterNames)
	While i > 0
		i -= 1
		String sCharacterName = jArray.getStr(jCharacterNames,i)
		If !GetLocalInt(sCharacterName,"FilePresent") && !GetLocalInt(sCharacterName,"ShowedMissingWarning")
			SetLocalInt(sCharacterName,"ShowedMissingWarning",1)
			Debug.Trace("MYC/CM: The saved data for " + sCharacterName + " is missing! :(")
			Debug.Notification("Familiar Faces: The saved data for " + sCharacterName + " is missing!")
		EndIf
	EndWhile
	
	;--- See if any existing characters have missing requirements
	Bool bShowNag = False
	i = JArray.Count(jCharacterNames)
	While i > 0
		i -= 1
		String sCharacterName = jArray.getStr(jCharacterNames,i)
		If CheckModReqs(sCharacterName)
			bShowNag = True
		EndIf
	EndWhile
	If bShowNag && GetConfigBool("WARNING_MISSINGMOD")
		vMYC_ReqMissingNagMSG.ShowAsHelpMessage("vMYC_Nag",8,1,1)
	Else
		Message.ResetHelpMessage("vMYC_Nag")
	EndIf
	
	JValue.CleanPool("vMYC_CM_Load")
EndFunction

Int Function ValidateCharacterInfo(Int jCharacterData)
	;Debug.Trace("MYC/CM: ValidateCharacterData!")
	If !JValue.hasPath(jCharacterData,"._MYC.SerializationVersion") && JMap.hasKey(jCharacterData,"Name")
		;Debug.Trace("MYC/CM: Character data is valid but from an early development version.")
		Return 0
	ElseIf JValue.hasPath(jCharacterData,"._MYC.SerializationVersion")
		Int iSVer = JValue.solveInt(jCharacterData,"._MYC.SerializationVersion")
		;Debug.Trace("MYC/CM: Character data is valid, serialization version " + iSVer)
		Return iSVer
	EndIf
	Return -1
EndFunction

Bool Function UpgradeCharacterInfo(Int jCharacterData)
	Bool bUpgraded = False
	If !JValue.hasPath(jCharacterData,"._MYC.SerializationVersion") && JMap.hasKey(jCharacterData,"Name")
		;Dev version, upgrade to version 1
		;Debug.Trace("MYC/CM: Upgrading dev version data to version 1...")
		Int jMetaInfo = JMap.Object()
		JMap.setInt(jMetaInfo,"SerializationVersion",1)
		JMap.setStr(jMetaInfo,"Name",JMap.getStr(jCharacterData,"Name"))
		JMap.setObj(jCharacterData,"_MYC",jMetaInfo)
		If !JMap.hasKey(jCharacterData,"ModList")
			JMap.setObj(jCharacterData,"Modlist",JArray.object()) ; Add empty modlist entry
		EndIf
		;Debug.Trace("MYC/CM: ...version 1 upgrade finished!")
		bUpgraded = True
	EndIf
	Int iDataVer = JValue.solveInt(jCharacterData,"._MYC.SerializationVersion")
	If iDataVer == 1
		;Debug.Trace("MYC/CM: Data serialization is version " + iDataVer + ", current version is " + SerializationVersion)
		;Debug.Trace("MYC/CM: Upgrading version 1 to version 2...")
		Int jMetaInfo = JMap.getObj(jCharacterData,"_MYC")
		JMap.setStr(jMetaInfo,"Name",JMap.getStr(jCharacterData,"Name"))
		JMap.setStr(jMetaInfo,"RaceText",(JMap.getForm(jCharacterData,"Race") as Race).GetName())
		JMap.setFlt(jMetaInfo,"Playtime",JMap.getFlt(jCharacterData,"PlayTime"))
		JMap.setObj(jMetaInfo,"ModList",JMap.getObj(jCharacterData,"ModList"))
		JMap.removeKey(jCharacterData,"Playtime")
		JMap.removeKey(jCharacterData,"ModList")
		JMap.setInt(jMetaInfo,"SerializationVersion",2)
		;Debug.Trace("MYC/CM: ...version 2 upgrade finished!")
		bUpgraded = True
	EndIf
	iDataVer = JValue.solveInt(jCharacterData,"._MYC.SerializationVersion")
	If iDataVer < SerializationVersion
		Debug.Trace("MYC/CM: Data serialization is version " + iDataVer + ", current version is " + SerializationVersion)
		If iDataVer == 2 
			Debug.Trace("MYC/CM: Upgrading this file to serialization version 3...")
;	Trying to generate this for old files was a terrible idea, don't do it!
;			If !JValue.HasPath(jCharacterData,"._MYC.ReqList")
;				Debug.Trace("MYC/CM: Attempting to generate character requirements, if this copy of the game is missing any they will not be added...")
;				
;				AddToReqList(jCharacterData,JValue.SolveForm(jCharacterData,".Race"),"Race")
;				
;				AddToReqList(jCharacterData,JValue.SolveForm(jCharacterData,".Equipment.Left"),"Equipment")
;				AddToReqList(jCharacterData,JValue.SolveForm(jCharacterData,".Equipment.Right"),"Equipment")
;				AddToReqList(jCharacterData,JValue.SolveForm(jCharacterData,".Equipment.Voice"),"Equipment")
;				
;				AddToReqList(jCharacterData,JValue.SolveForm(jCharacterData,".Equipment.Voice"),"Equipment")
;			
;				Int jArmor = JValue.SolveObj(jCharacterData,".Equipment.Armor")
;				Int i = JArray.Count(jArmor)
;				While i > 0
;					i -= 1
;					AddToReqList(jCharacterData,JArray.GetForm(jArmor,i),"Equipment")
;				EndWhile
;				
;				Int jHeadparts = JValue.SolveObj(jCharacterData,".Appearance.Headparts")
;				i = JArray.Count(jHeadparts)
;				While i > 0
;					i -= 1
;					AddToReqList(jCharacterData,JArray.GetForm(jHeadparts,i),"Headpart")
;				EndWhile
;				
;				Int jPerks = JValue.SolveObj(jCharacterData,".Perks")
;				i = JArray.Count(jPerks)
;				While i > 0
;					i -= 1
;					AddToReqList(jCharacterData,JArray.GetForm(jPerks,i),"Perk")
;				EndWhile
;				
;				Int jSpells = JValue.SolveObj(jCharacterData,".Spells")
;				i = JArray.Count(jSpells)
;				While i > 0
;					i -= 1
;					AddToReqList(jCharacterData,JArray.GetForm(jSpells,i),"Spell")
;				EndWhile
;			EndIf
			JValue.SolveIntSetter(jCharacterData,"._MYC.SerializationVersion",3)
			Debug.Trace("MYC/CM: Finished upgrading the file!")
			bUpgraded = True
		EndIf
		;Debug.Trace("MYC/CM: Unfortunately no upgrade function is in place, so we'll just have to hope for the best!")
	ElseIf iDataVer == SerializationVersion
		;Debug.Trace("MYC/CM: Data serialization is up to date!")
	Else
		Debug.Trace("MYC/CM: Data serialization is from a future version? Odd. We'll just have to hope it works.")
	EndIf
	Return bUpgraded
EndFunction

Function AddToReqList(Int jCharacterData, Form akForm, String asType)
{Take the form and add its provider/source to the required mods list of the specified jCharacterData.}
	If !jCharacterData || !akForm || !asType 
		Return
	EndIf
	Int jMetaInfo = JMap.getObj(jCharacterData,"_MYC")
	If !jMetaInfo
		jMetaInfo = JMap.Object()
		JMap.setObj(jCharacterData,"_MYC",jMetaInfo)
	EndIf
	Int jReqList = JMap.getObj(jMetaInfo,"ReqList")
	If !jReqList
		jReqList = JMap.Object()
		JMap.setObj(jMetaInfo,"ReqList",jReqList)
	EndIf
	String sModName = GetModName(akForm.GetFormID() / 0x1000000)
	If sModName
		Int JModFormTypes = JMap.getObj(jReqList,sModName)
		If !JModFormTypes
			JModFormTypes = JMap.Object()
			JMap.setObj(jReqList,sModName,JModFormTypes)
		EndIf
		If !JMap.HasKey(JModFormTypes,asType)
			JMap.SetObj(JModFormTypes,asType,JArray.Object())
		EndIf
		Int jModFormList = JMap.getObj(JModFormTypes,asType)
		String sFormName = akForm.GetName()
		If !sFormName
			sFormName = GetFormIDString(akForm)
		EndIf
		If JArray.FindStr(jModFormList,sFormName) < 0
			JArray.AddStr(jModFormList,sFormName)
		EndIf
	EndIf
			
EndFunction

Int Function CheckModReqs(String asCharacterName)
{Return 0 for no missing reqs, 1 for missing non-appearance reqs, 2 for missing armor/weapons reqs, 3 for missing headparts or race}
	Debug.Trace("MYC/CM: Checking mod requirements for " + asCharacterName + "...")
	If !GetCharacterForm(asCharacterName,"Race") as Race
		Return 3
	EndIf
	Int iReturn = 0
	Int jReqList = GetCharacterMetaObj(asCharacterName,"ReqList")
	Int jModList = JMap.AllKeys(jReqList)
	JValue.Retain(jModList,"vMYC_CM")
	Int jMissingMods = JArray.Object()
	JValue.Retain(jMissingMods,"vMYC_CM")
	Int i = 0
	Int iCount = JArray.Count(jModList)
	
	While i < iCount
		Debug.Trace("MYC/CM:   Checking forms from " + JArray.GetStr(jModList,i) + "...")
		Int jModObjTypes = JMap.AllKeys(JMap.GetObj(jReqList,JArray.GetStr(jModList,i)))
		If GetModByName(JArray.GetStr(jModList,i)) == 255 ; Mod is missing
			If JMap.HasKey(jModObjTypes,"HeadPart") || JMap.HasKey(jModObjTypes,"Race")
				Return 3
			ElseIf JMap.HasKey(jModObjTypes,"Equipment")
				Return 2
			ElseIf JMap.HasKey(jModObjTypes,"SPELL") || JMap.HasKey(jModObjTypes,"Perk") 
				Return 1
			EndIf
		EndIf
		i += 1
	EndWhile
	JValue.Release(jMissingMods)
	JValue.Release(jModList)	
	
	;Check older "sources" list
	
	Int jHeadPartSources = GetCharacterObj(asCharacterName,"HeadpartSources")
	i = JArray.Count(jHeadpartSources)
	While i > 0
		i -= 1
		If GetModByName(JArray.GetStr(jHeadpartSources,i)) == 255 ; Mod is missing
			Return 3
		EndIf
	EndWhile
	
	Return 0
EndFunction

String Function GetModReqReport(String asCharacterName)
{Return a string containing the missing mod report, formatted for SkyUI's ShowMessage.}
	Debug.Trace("MYC/CM: Creating ModReq report for " + asCharacterName + "...")
	String sReturn = ""
	String sCrit = ""
	String sWarn = ""
	String sMiss = ""
	String sInfo = ""
	Int jReqList = GetCharacterMetaObj(asCharacterName,"ReqList")
	Int jModList = JMap.AllKeys(jReqList)
	JValue.Retain(jModList,"vMYC_CM")
	Int jMissingMods = JArray.Object()
	JValue.Retain(jMissingMods,"vMYC_CM")
	If !GetCharacterStr(asCharacterName,"Appearance.HaircolorSource")
		sInfo += "\nOlder file, report will be inaccurate!\n"
	EndIf
	Int i = 0
	Int iCount = JArray.Count(jModList)
	While i < iCount
		Debug.Trace("MYC/CM:   Checking forms from " + JArray.GetStr(jModList,i) + "...")
		String sModName = JArray.GetStr(jModList,i)
		If GetModByName(sModName) < 255
			sInfo += "\n" + sModName + ":\n"
		EndIf
		Int jModObjTypes = JMap.AllKeys(JMap.GetObj(jReqList,sModName))
		Debug.Trace("MYC/CM:   Provides " + JArray.Count(jModObjTypes) + " forms")
		Int j = 0
		Int jCount = JArray.Count(jModObjTypes)
		While j < jCount
			String sModObj = JArray.GetStr(jModObjTypes,j)
			String sObjList = ""
			Int jMissingObjs = JMap.GetObj(JMap.GetObj(jReqList,sModName),sModObj)
			Int k = 0
			While k < JArray.Count(jMissingObjs)
				sObjList += jArray.GetStr(jMissingObjs,k) + "\n"
				k += 1
			EndWhile
			If GetModByName(sModName) == 255 ; Mod is missing
				If sModObj == "HeadPart" || sModObj == "Race"
					sCrit += sModName + " (" + JArray.Count(jMissingObjs) + " Missing):\n"
					sCrit += sObjList + "\n"
				ElseIf sModObj == "Equipment"
					sWarn += sModName + " (" + JArray.Count(jMissingObjs) + " Missing):\n"
					sWarn += sObjList + "\n"
				Else
					sMiss += sModName + " (" + JArray.Count(jMissingObjs) + " Missing):\n"
					sMiss += sObjList + "\n"
				EndIf
			Else
				sInfo += JArray.Count(jMissingObjs) + " " + sModObj
				If JArray.Count(jMissingObjs) == 1
					sInfo += " form\n"
				Else
					sInfo += " forms\n"
				EndIf
				;sInfo += "Using " + JArray.Count(jMissingObjs) + " " + sModObj + " forms from " + sModName + ":\n"
				;sInfo += sObjList
			EndIf
			j += 1
		EndWhile
		i += 1
	EndWhile
	JValue.Release(jMissingMods)
	JValue.Release(jModList)	

	If !GetCharacterForm(asCharacterName,"Race") as Race && !sCrit
		sCrit += "Missing Race from unknown source!\n"
	EndIf
	
	sReturn = "Mod requirements for " + asCharacterName + "\n" 
	If sCrit || sWarn || sMiss
		If sCrit 
			sReturn += "\n------=== Critical ===------\n" + sCrit
		EndIf
		If sWarn
			sReturn += "\n------=== Equipment ===-----\n" + sWarn
		EndIf
		If sMiss 
			sReturn += "\n--------==== Minor ===--------\n" + sMiss
		EndIf
	Else
		sReturn += sInfo
	EndIf
	
	Return sReturn
EndFunction

Bool Function IsCharacterFollower(String asCharacterName)
	Actor kCharacter = GetCharacterActorByName(asCharacterName)
	If !kCharacter as vMYC_CharacterDummyActorScript
		Return False
	EndIf
	Faction kCurrentFollowerFaction = (kCharacter as vMYC_CharacterDummyActorScript).CurrentFollowerFaction
	If kCharacter.IsPlayerTeammate() || kCharacter.GetFactionRank(kCurrentFollowerFaction) >= 0
		Return True
	EndIf
	Return False
EndFunction

ActorBase Function GetFreeActorBase(Int iSex)
{Returns the first available dummy actorbase of the right sex}
	While _bFreeActorBaseBusy
		;Debug.Trace("MYC/CM: Waiting for GetFreeActorBase...")
		Return None
	EndWhile
	_bFreeActorBaseBusy = True
	ActorBase kDummyActorBase = None
	
	Int jActorBaseMap = JValue.solveObj(_jMYC,".ActorBaseMap")
	Int i = 0
	While i < _kDummyActors.Length
		If _kDummyActors[i]
			If _kDummyActors[i].GetSex() == iSex
				If !JFormMap.hasKey(jActorBaseMap,_kDummyActors[i])
					kDummyActorBase = _kDummyActors[i]
				EndIf
			EndIf
		EndIf
		i += 1
	EndWhile
	_bFreeActorBaseBusy = False
	Return kDummyActorBase
EndFunction

Function SanityCheckActors()
	Int jActorList = JArray.Object()
	Int jActorInvalidList = JArray.Object()
	JValue.AddToPool(jActorList,"vMYC_SanityCheckPool")
	JValue.AddToPool(jActorInvalidList,"vMYC_SanityCheckPool")
	String[] sCharacterNames = CharacterNames
	Int i = sCharacterNames.Length
	While i > 0
		i -= 1
		If sCharacterNames[i]
			Actor kActor = GetCharacterActorByName(sCharacterNames[i])
			If kActor
				If JArray.FindForm(jActorList,kActor) >= 0
					JArray.AddForm(jActorInvalidList,GetCharacterActorByName(sCharacterNames[i]))
				EndIf
				JArray.AddForm(jActorList,GetCharacterActorByName(sCharacterNames[i]))
			EndIf
		EndIf
	EndWhile
	i = JArray.Count(jActorInvalidList)
	While i > 0
		i -= 1
		Actor kActor = JArray.GetForm(jActorInvalidList,i) as Actor
		If kActor as vMYC_CharacterDummyActorScript
			String sCharacterName = (kActor as vMYC_CharacterDummyActorScript).CharacterName
			If sCharacterName 
				DeleteCharacterActor(sCharacterName)
			Else
				kActor.Delete()
			EndIf
		Else
			kActor.Delete()
		EndIf
	EndWhile
	
	JValue.cleanPool("vMYC_SanityCheckPool")
EndFunction

ActorBase Function GetCharacterDummy(String sCharacterName)
	Int i = 0
	Return JValue.solveForm(_jMYC,"." + sCharacterName + ".!LocalData.ActorBase") as ActorBase
EndFunction

Actor Function GetCharacterActor(ActorBase kTargetDummy)
	Int i = 0
	While i < _kLoadedCharacters.Length
		If _kLoadedCharacters[i]
			If _kLoadedCharacters[i].GetActorBase() == kTargetDummy
				Return _kLoadedCharacters[i]
			EndIf
		EndIf
		i += 1
	EndWhile
EndFunction

Actor Function GetCharacterActorByName(String asCharacterName)
	Return GetCharacterActor(GetCharacterDummy(asCharacterName))
EndFunction

String Function GetCharacterMetaString(String asCharacterName, String asMetaName)
	Return JValue.solveStr(_jMYC,"." + asCharacterName + ".Data._MYC." + asMetaName)
EndFunction

Int Function GetCharacterMetaObj(String asCharacterName, String asMetaName)
	Return JValue.solveObj(_jMYC,"." + asCharacterName + ".Data._MYC." + asMetaName)
EndFunction

Int Function GetCharacterInt(String asCharacterName, String asPath)
	Return JValue.solveInt(_jMYC,"." + asCharacterName + ".Data." + asPath)
EndFunction

Float Function GetCharacterFlt(String asCharacterName, String asPath)
	Return JValue.solveFlt(_jMYC,"." + asCharacterName + ".Data." + asPath)
EndFunction

String Function GetCharacterStr(String asCharacterName, String asPath)
	Return JValue.solveStr(_jMYC,"." + asCharacterName + ".Data." + asPath)
EndFunction

Form Function GetCharacterForm(String asCharacterName, String asPath)
	Return JValue.solveForm(_jMYC,"." + asCharacterName + ".Data." + asPath)
EndFunction

Int Function GetCharacterObj(String asCharacterName, String asPath)
	Return JValue.solveObj(_jMYC,"." + asCharacterName + ".Data." + asPath)
EndFunction


String Function GetCharacterEquipmentName(String asCharacterName, String asPath)
{Returns custom name if available, otherwise the form name}
	Int jEquipment = JValue.solveObj(_jMYC,"." + asCharacterName + ".Data.Equipment." + asPath)
	If JMap.getInt(jEquipment,"IsCustom") as Bool
		Return JMap.getStr(jEquipment,"DisplayName")
	Else
		Form kEquipment = JMap.getForm(jEquipment,"Form")
		If kEquipment
			Return kEquipment.GetName()
		Else
			Return ""
		EndIf
	EndIf
	Return ""
EndFunction

String[] Function GetCharacterSpawnPoints(String asCharacterName)
	Int jSpawnPoints = JMap.getObj(JValue.solveObj(_jMYC,"." + asCharacterName + ".Data"),"SpawnPoints")
	Int i = JArray.Count(jSpawnPoints)
	String[] sSpawnPoints = New String[32]
	While i > 0
		i -= 1
		sSpawnPoints[i] = JArray.getStr(jSpawnPoints,i)
	EndWhile
	Return sSpawnPoints
EndFunction

Event OnSetCustomHangout(String sCharacterName, String sLocationName, Form kLocation, Form kCell, Form kAnchor1, Form kAnchor2, Form kAnchor3, Form kAnchor4, Form kAnchor5, Float fPlayerX, Float fPlayerY, Float fPlayerZ)
	If !sLocationName
		Return
	EndIf
	JMap.setStr(_jMYC,"PlayerHangout",sLocationName)
EndEvent


Int Function AddCustomLocation(Int jLocationData)
{Legacy function: DO NOT USE!}
	Return -1
EndFunction

String Function GetCharacterNameFromActorBase(ActorBase akActorBase)
	;Debug.Trace("MYC/CM: GetCharacterNameFromActorBase(ActorBase akActorBase)")
	Return JFormMap.getStr(JMap.getObj(_jMYC,"ActorBaseMap"),akActorBase)
EndFunction

Float Function GetCharacterStat(String asCharacterName,String asStatName)
	Return JValue.solveFlt(_jMYC,"." + asCharacterName + ".Data.Stats." + asStatName)
EndFunction

Float Function GetCharacterAV(String asCharacterName,String asAVName)
	Return JValue.solveFlt(_jMYC,"." + asCharacterName + ".Data.Stats.AV." + asAVName)
EndFunction

Function ResetCharacterPosition(String asCharacterName)
	;If GetLocalString(asCharacterName,"HangoutName")
	HangoutManager.MoveActorToHangout(GetCharacterActorByName(asCharacterName),GetLocalString(asCharacterName,"HangoutName"))
	;EndIf
EndFunction

Function SetCharacterEnabled(String asCharacterName, Bool abEnabled)

	ActorBase kTargetDummy = GetCharacterDummy(asCharacterName)
	SetLocalInt(asCharacterName, "Enabled", abEnabled as Int)
	Actor kTargetActor = GetCharacterActor(kTargetDummy)
	If abEnabled && kTargetActor.IsDisabled()
		kTargetActor.EnableNoWait(True)
	ElseIf !abEnabled && !kTargetActor.IsDisabled()
		kTargetActor.DisableNoWait(True)
	EndIf

EndFunction

VoiceType Function GetCharacterVoiceType(String asCharacterName)
	Return GetLocalForm(asCharacterName,"VoiceType") as VoiceType
EndFunction

Bool Function SetCharacterVoiceType(String asCharacterName, VoiceType akVoiceType)
	;Debug.Trace("MYC/CM: SetCharacterVoiceType(" + asCharacterName + ", " + akVoiceType + ")")
	ActorBase kTargetDummy = GetCharacterDummy(asCharacterName)
	kTargetDummy.SetVoiceType(akVoiceType)
	SetLocalForm(asCharacterName,"VoiceType",akVoiceType)
	Return True
EndFunction

Function SetCharacterClass(String asCharacterName, Class akClass)
	;Debug.Trace("MYC/CM: SetCharacterClass(" + asCharacterName + ", " + akClass + ")")
	ActorBase kTargetDummy = GetCharacterDummy(asCharacterName)
	Int iClassIndex = kClasses.Find(akClass)
	kTargetDummy.SetClass(akClass)
	kTargetDummy.SetCombatStyle(kCombatStyles[iClassIndex])
	SetLocalForm(asCharacterName,"Class",akClass)
	SetLocalForm(asCharacterName,"CombatStyle",kCombatStyles[iClassIndex])
	;SetFormValue(kTargetDummy,sKey + "CombatStyle",kCombatStyles[iClassIndex])
	If akClass ; If a class is set, then force a Race update to recalc the actor's stats
		Actor kTargetActor = GetCharacterActor(kTargetDummy)
		(kTargetActor as vMYC_CharacterDummyActorScript).DoUpkeep(True)
	EndIf
EndFunction

Bool Function SetCharacterHangout(String asCharacterName, ReferenceAlias akHangoutRefAlias)
{Legacy function, do not use!}
	
	Return True
EndFunction

Function SetCharacterTracking(String asCharacterName, Bool abEnable, Bool abChangeSetting = True)
{Tell HangoutManager to enable tracking for this character}
	If abChangeSetting
		SetLocalInt(asCharacterName,"TrackingEnabled",abEnable as Int)
	EndIf
	HangoutManager.EnableTracking(GetCharacterActorByName(asCharacterName),abEnable)
EndFunction

Function SetAllCharacterTracking(Bool abEnable)
	String[] sCharacterNames = CharacterNames
	Int i = 0
	While i < sCharacterNames.Length
		String sCharacterName = sCharacterNames[i]
		If sCharacterName
			SetLocalInt(sCharacterName,"TrackingEnabled",abEnable as Int)
			Actor kActor = GetCharacterActorByName(sCharacterName)
			If kActor && GetLocalInt(sCharacterName,"IsSummoned")
				HangoutManager.EnableTracking(kActor,abEnable)
			EndIf
		EndIf
		i += 1
	EndWhile
EndFunction

Function RepairSaves()
{Update/Repair saved files, fixing all known bugs and setting them to the latest revision}

	Int jCharacterMap = JMap.Object()
	If !JMap.hasKey(_jMYC,"CharacterList")
		JMap.SetObj(_jMYC,"CharacterList",JMap.Object())
	EndIf
	jCharacterMap = JMap.getObj(_jMYC,"CharacterList")

	Int jCharacterNames = JMap.allKeys(jCharacterMap)
	;--- If there are any existing characters set their FilePresent to 0
	Int i = JArray.Count(jCharacterNames)
	While i > 0
		i -= 1
		SetLocalInt(jArray.getStr(jCharacterNames,i),"FilePresent",0)
	EndWhile

	;Debug.Trace("MYC/CM: Reading directory...")
	Bool bNeedFilesMoved = False
	Int jDirectoryScan
	If !JContainers.fileExistsAtPath("Data/vMYC/vMYC_MovedFiles.txt")
		bNeedFilesMoved = True
		jDirectoryScan = JValue.readFromDirectory("Data/vMYC/")
	Else
		jDirectoryScan = JValue.readFromDirectory(JContainers.userDirectory() + "vMYC/")
	EndIf
	
	Int jCharFiles = JMap.allKeys(jDirectoryScan)
	Int jCharData = JMap.allValues(jDirectoryScan)
	i = JMap.Count(jDirectoryScan)
	
	JValue.AddToPool(jCharacterNames,"vMYC_CM_Repair")
	JValue.AddToPool(jDirectoryScan,"vMYC_CM_Repair")
	JValue.AddToPool(jCharFiles,"vMYC_CM_Repair")
	JValue.AddToPool(jCharData,"vMYC_CM_Repair")
	
	;--- Load and validate all files in the data directory
	While i > 0
		i -= 1
		Int jCharacterData = JArray.getObj(jCharData,i)
		If ValidateCharacterInfo(jCharacterData) > -1
			If UpgradeCharacterInfo(jCharacterData) || bNeedFilesMoved
				;JValue.WriteToFile(jCharacterData,"Data/vMYC/" + JArray.getStr(jCharFiles,i)) ; write the file back if the data version was upgraded
				JValue.WriteToFile(jCharacterData,JContainers.userDirectory() + "vMYC/" + JArray.getStr(jCharFiles,i)) ; write the file back if the data version was upgraded
				;WaitMenuMode(0.25)
			EndIf
		EndIf
	EndWhile
	JValue.WriteToFile(JMap.Object(),"Data/vMYC/vMYC_MovedFiles.txt")
	JValue.CleanPool("vMYC_CM_Repair")
EndFunction

Function ClearCharacterRefs(String asCharacterName)
	Actor kCharacterActor = GetCharacterActorByName(asCharacterName)
	If !kCharacterActor
		Return
	EndIf
	Int i = kCharacterActor.GetNumReferenceAliases()
	Debug.Trace("MYC/CM: (" + asCharacterName + ") Clearing the following RefAliases from " + asCharacterName + "...")
	While i > 0
		i -= 1
		ReferenceAlias kThisRefAlias = kCharacterActor.GetNthReferenceAlias(i)
		If kThisRefAlias
			Debug.Trace("MYC/CM: (" + asCharacterName + ")   " + kThisRefAlias)
			kThisRefAlias.Clear()
		EndIf
	EndWhile
EndFunction

Function DeleteCharacterActor(String asCharacterName)
	Int jActorBaseMap = JMap.getObj(_jMYC,"ActorBaseMap")
	Int jDeadManWalking = JMap.getObj(_jMYC,asCharacterName)
	ActorBase kDeadActorBase = GetCharacterDummy(asCharacterName)
	Actor kDeadActor = GetCharacterActorByName(asCharacterName)
	Debug.Trace("MYC/CM: (" + asCharacterName + ") Deleting actor " + kDeadActor + "!")
	Int iLCidx = _kLoadedCharacters.Find(kDeadActor)
	ClearCharacterRefs(asCharacterName)
	;CharGen.ClearPreset(kDeadActor,asCharacterName)
	_kLoadedCharacters[iLCidx] = None
	SetLocalInt(asCharacterName,"Enabled",0)
	SetLocalFlt(asCharacterName,"PlayTime",0.0)
	SetLocalForm(asCharacterName,"ActorBase",None)
	SetLocalForm(asCharacterName,"Actor",None)
	JFormMap.removeKey(jActorBaseMap,kDeadActorBase)
	If kDeadActor
		kDeadActor.Delete()
	EndIf
EndFunction

Function EraseCharacter(String asCharacterName, Bool bConfirm = False, Bool bPreserveLocal = True)
	Debug.Trace("MYC/CM: (" + asCharacterName + ") EraseCharacter called!")
	If !bConfirm
		Debug.Trace("MYC/CM: (" + asCharacterName + ") EraseCharacter not confirmed, returning...")
		Return
	EndIf
	Int jDeadManWalking = JMap.getObj(_jMYC,asCharacterName)
	Actor kDeadActor = GetCharacterActorByName(asCharacterName)
	FFUtils.DeleteFaceGenData(kDeadActor.GetActorBase())
	CharGen.DeleteCharacter(asCharacterName)
	DeleteCharacterActor(asCharacterName)
	If bPreserveLocal
		If !JMap.hasKey(_jMYC,"DeletedList")
			JMap.setObj(_jMYC,"DeletedList",JMap.Object())
		EndIf
		Int jDeletedList = JMap.getObj(_jMYC,"DeletedList")
		JMap.SetObj(jDeletedList,asCharacterName,JValue.SolveObj(_jMYC,"." + asCharacterName + ".!LocalData"))
	EndIf
	JDB.WriteToFile("Data/vMYC/JDB-post-delete.json")
	JMap.RemoveKey(_jMYC,asCharacterName)
	Int jCharacterList = JMap.GetObj(_jMYC,"CharacterList")
	JMap.RemoveKey(jCharacterList,asCharacterName)
	SendModEvent("vMYC_CharacterErased",asCharacterName)
	Debug.Trace("MYC/CM: (" + asCharacterName + ") erased character!")
EndFunction

Function SetAllowedSpells(String sCharacterName, Bool abAlteration = True, Bool abConjuration = True, Bool abDestruction = True, Bool abIllusion = True, Bool abRestoration = True, Bool abOther = True)

	SetLocalInt(sCharacterName,"MagicAllowAlteration",abAlteration as Int)
	SetLocalInt(sCharacterName,"MagicAllowConjuration",abConjuration as Int)
	SetLocalInt(sCharacterName,"MagicAllowDestruction",abDestruction as Int)
	SetLocalInt(sCharacterName,"MagicAllowIllusion",abIllusion as Int)
	SetLocalInt(sCharacterName,"MagicAllowRestoration",abRestoration as Int)
	SetLocalInt(sCharacterName,"MagicAllowOther",abOther as Int)

	SendModEvent("vMYC_UpdateCharacterSpellList",sCharacterName)

EndFunction

Int Function ApplyCharacterWeapons(String sCharacterName)
	Int i
	Int iCount
	;While _bBusyEquipment
		;Wait(1.0)
	;EndWhile
	_bBusyEquipment = True
	;Debug.Trace("MYC/CM/" + sCharacterName + ":  Setting equipped weapons...")
	SetLocalInt(sCharacterName,"BowEquipped",0)
	;SetLocalInt(sCharacterName,"SpellEquipped",0)

	Actor kCharacterActor = GetCharacterActorByName(sCharacterName)
	
	Int jCustomItems = GetCharacterObj(sCharacterName,"InventoryCustomItems")
	
	i = JArray.Count(jCustomItems)
	;Debug.Trace("MYC/CM/" + sCharacterName + ":  has " + i + " items to be customized!")
	While i > 0
		i -= 1
		Int jItem = JArray.GetObj(jCustomItems,i)
		LoadWeapon(kCharacterActor,jItem,1,False)
		iCount += 1
	EndWhile

	Int iHand = 1 ; start with right
	While iHand >= 0
		Bool bTwoHanded = False
		String sHand = "Right"
		If iHand == 0
			sHand = "Left"
		EndIf
		Int jItem = GetCharacterObj(sCharacterName,"Equipment." + sHand)
		LoadWeapon(kCharacterActor, jItem, iHand,False)
		;If iHand == 1 ; Equip in proper hand and prevent removal
			;kCharacterActor.UnEquipItem(kItem)
			;kCharacterActor.EquipItemEx(kItem,1,True) ; Right
		;ElseIf !bTwoHanded
			;kCharacterActor.UnEquipItem(kItem)
			;kCharacterActor.EquipItemEx(kItem,2,True) ; Left
		;EndIf
		iHand -= 1
		iCount += 1
		If bTwoHanded ; skip left hand
			;Debug.Trace("MYC/CM/" + sCharacterName + ":  two-handed weapon, so skipping further processing...")
			iHand -= 1
			iCount -= 1
		EndIf
	EndWhile
	;Debug.Trace("MYC/CM/" + sCharacterName + ":  Equipping power!")
	;kCharacterActor.EquipItemEx(GetCharacterForm(sCharacterName,"Equipment.Voice"),0)
	
	_bBusyEquipment = False

	If GetLocalInt(sCharacterName,"BowEquipped") == 0 && GetLocalForm(sCharacterName,"AmmoDefault")
		kCharacterActor.UnEquipItem(GetLocalForm(sCharacterName,"AmmoDefault"))
	EndIf
	
	Return iCount
EndFunction

Int Function ApplyCharacterArmor(String sCharacterName)
	Int i
	Int iCount
	
	;While _bBusyEquipment
		;Wait(1.0)
	;EndWhile
	_bBusyEquipment = True
	;Debug.Trace("MYC/CM/" + sCharacterName + ":  Setting equipment...")

	Int jCharacterArmor = GetCharacterObj(sCharacterName,"Equipment.Armor")
	Int jCharacterArmorInfo = GetCharacterObj(sCharacterName,"Equipment.ArmorInfo")

	Actor kCharacterActor = GetCharacterActorByName(sCharacterName)
	
	i = JArray.Count(jCharacterArmorInfo)
	While i > 0
		i -= 1
		Int jArmor = JArray.GetObj(jCharacterArmorInfo,i)
		Form kItem = JMap.GetForm(jArmor,"Form")
		If kItem
			If kCharacterActor.GetItemCount(kItem)
				kCharacterActor.RemoveItem(kItem)
			EndIf
			kCharacterActor.AddItem(kItem)
			kCharacterActor.EquipItemEx(kItem,0,True)
			iCount += 1
			Int h = (kItem as Armor).GetSlotMask()
			;Debug.Trace("MYC/CM/" + sCharacterName + ":  setting up " + kItem.GetName() + "...")
			Enchantment kItemEnchantment = JMap.GetForm(jArmor,"Enchantment") as Enchantment
			If kItemEnchantment && (kItem as Armor).GetEnchantment() != kItemEnchantment
				;Debug.Trace("MYC/CM/" + sCharacterName + ":  " + kItem.GetName() + " is enchanted!")
				WornObject.SetEnchantment(kCharacterActor,1,h,kItemEnchantment,JMap.GetFlt(jArmor,"ItemMaxCharge"))
				;WornObject.SetItemCharge(
			EndIf
			If JMap.GetInt(jArmor,"IsCustom")
				String sDisplayName = JMap.GetStr(jArmor,"DisplayName")
				;Debug.Trace("MYC/CM/" + sCharacterName + ":  " + kItem.GetName() + " is customized item " + sDisplayName + "!")
				WornObject.SetItemHealthPercent(kCharacterActor,1,h,JMap.GetFlt(jArmor,"ItemHealthPercent"))
				WornObject.SetItemMaxCharge(kCharacterActor,1,h,JMap.GetFlt(jArmor,"ItemMaxCharge"))
				If sDisplayName ; Will be blank if player hasn't renamed the item
					WornObject.SetDisplayName(kCharacterActor,1,h,sDisplayName)
				EndIf

				Float[] fMagnitudes = New Float[8]
				Int[] iDurations = New Int[8]
				Int[] iAreas = New Int[8]
				MagicEffect[] kMagicEffects = New MagicEffect[8]

				If JValue.solveInt(jArmor,".Enchantment.IsCustom")
					Int iNumEffects = JValue.SolveInt(jArmor,".Enchantment.NumEffects")
					;Debug.Trace("MYC/CM/" + sCharacterName + ":  " + sDisplayName + " has a customized enchantment with " + inumEffects + " magiceffects!")
					Int j = 0
					Int jArmorEnchEffects = JValue.SolveObj(jArmor,".Enchantment.Effects")
					While j < iNumEffects
						Int jArmorEnchEffect = JArray.getObj(jArmorEnchEffects,j)
						fMagnitudes[j] = JMap.GetFlt(jArmorEnchEffect,"Magnitude")
						iDurations[j] = JMap.GetFlt(jArmorEnchEffect,"Duration") as Int
						iAreas[j] = JMap.GetFlt(jArmorEnchEffect,"Area") as Int
						kMagicEffects[j] = JMap.GetForm(jArmorEnchEffect,"MagicEffect") as MagicEffect
						j += 1
					EndWhile
					WornObject.CreateEnchantment(kCharacterActor, 1, h, JMap.GetFlt(jArmor,"ItemMaxCharge"), kMagicEffects, fMagnitudes, iAreas, iDurations)
				EndIf
			EndIf
			;Load NIO dye, if applicable
			If GetConfigInt("NIO_UseDye")
				Int jNIODyeColors = JValue.solveObj(jArmor,".NIODyeColors")
				If JValue.isArray(jNIODyeColors)
					Int iHandle = NIOverride.GetItemUniqueID(kCharacterActor, 0, h, True)
					Int iMaskIndex = 0
					Int iIndexMax = 15
					While iMaskIndex < iIndexMax
						Int iColor = JArray.GetInt(jNIODyeColors,iMaskIndex)
						If Math.RightShift(iColor,24) > 0
							NiOverride.SetItemDyeColor(iHandle, iMaskIndex, iColor)
						EndIf
						iMaskIndex += 1
					EndWhile
				EndIf
			EndIf
		EndIf
	EndWhile

	_bBusyEquipment = False
	
	Return iCount
EndFunction

Int Function ApplyCharacterPerks(String sCharacterName)
{Apply perks to named character. Return -1 for failure, or number of perks applied for success.}
	If _bApplyPerksBusy
		Return -1
	EndIf
	_bApplyPerksBusy = True
	vMYC_Perklist.Revert()
	Int jCharacterPerks = GetCharacterObj(sCharacterName,"Perks")
	Int i = JArray.Count(jCharacterPerks)
	Int iMissingCount = 0
	While i > 0
		i -= 1
		Perk kPerk = JArray.getForm(jCharacterPerks,i) as Perk
		If !kPerk
			iMissingCount += 1
		Else
			If vMYC_ModCompatibility_PerkList_Unsafe.HasForm(kPerk)
				iMissingCount += 1
			Else
				vMYC_PerkList.AddForm(kPerk)
			EndIf
		EndIf
		;Debug.Trace("MYC/CM/" + sCharacterName + ":  Perk is from " + JArray.getStr(jCharacterPerks,i))
		;Debug.Trace("MYC/CM/" + sCharacterName + ":  Adding perk " + kPerk + " (" + kPerk.GetName() + ") to list...")
	EndWhile
	;Debug.Trace("MYC/CM/" + sCharacterName + ":  Loading " + vMYC_PerkList.GetSize() + " perks to Actorbase...")
	If vMYC_PerkList.GetSize() + iMissingCount != JArray.Count(jCharacterPerks)
		Debug.Trace("MYC/CM/" + sCharacterName + ":  PerkList size mismatch, probably due to simultaneous calls. Aborting!",1)
		_bApplyPerksBusy = False
		Return -1
	ElseIf vMYC_PerkList.GetSize() == 0
		;Debug.Trace("MYC/CM/" + sCharacterName + ":  PerkList size is 0. Won't attempt to apply this.")
		_bApplyPerksBusy = False
		Return 0
	EndIf
	If iMissingCount
		Debug.Trace("MYC/CM/" + sCharacterName + ":  Loading " + vMYC_PerkList.GetSize() + " Perks with " + iMissingCount + " skipped, probably due to missing mods.",1)
	Else
		;Debug.Trace("MYC/CM/" + sCharacterName + ":  Loaded " + vMYC_PerkList.GetSize() + " Perks.")
	EndIf
	FFUtils.LoadCharacterPerks(GetCharacterDummy(sCharacterName),vMYC_Perklist)
	WaitMenuMode(0.1)
	_bApplyPerksBusy = False
	Return vMYC_PerkList.GetSize()
EndFunction

Int Function ApplyCharacterShouts(String sCharacterName)
{Apply shouts to named character. Return -1 for failure, or number of shouts applied for success. Needed because AddShout causes savegame corruption. }
	If _bApplyShoutsBusy
		Return -1
	EndIf
	_bApplyShoutsBusy = True
	Int iConfigShoutHandling = GetConfigInt("SHOUTS_HANDLING")
	vMYC_Shoutlist.Revert()
	Int jCharacterShouts = GetCharacterObj(sCharacterName,"Shouts")
	Int i = JArray.Count(jCharacterShouts)
	Int iMissingCount = 0
	While i > 0
		i -= 1
		Shout kShout = JArray.getForm(jCharacterShouts,i) as Shout
		If !kShout
			iMissingCount += 1
		Else
			Shout kStormCallShout = GetFormFromFile(0x0007097D,"Skyrim.esm") as Shout
			Shout kDragonAspectShout
			If GetModByName("Dragonborn.esm")
				kDragonAspectShout = GetFormFromFile(0x0201DF92,"DragonBorn.esm") as Shout
			EndIf
			If kShout == kStormCallShout && (iConfigShoutHandling == 1 || iConfigShoutHandling == 3)
				;Don't add it
			ElseIf kShout == kDragonAspectShout && (iConfigShoutHandling == 2 || iConfigShoutHandling == 3)
				;Don't add it
			ElseIf GetConfigBool("SHOUTS_BLOCK_UNLEARNED")
				If PlayerREF.HasSpell(kShout)
					vMYC_ShoutList.AddForm(kShout)
				EndIf
			Else
				vMYC_ShoutList.AddForm(kShout)		
			EndIf
		EndIf
		;Debug.Trace("MYC/CM/" + sCharacterName + ":  Adding Shout " + kShout + " (" + kShout.GetName() + ") to list...")
	EndWhile
	;Debug.Trace("MYC/CM/" + sCharacterName + ":  Loading " + vMYC_ShoutList.GetSize() + " Shouts to Actorbase...")
	If vMYC_ShoutList.GetSize() == 0
		;Debug.Trace("MYC/CM/" + sCharacterName + ":  ShoutList size is 0. Won't attempt to apply this.")
		_bApplyShoutsBusy = False
		Return 0
	EndIf
	If iMissingCount
		Debug.Trace("MYC/CM/" + sCharacterName + ":  Loading " + vMYC_ShoutList.GetSize() + " Shouts with " + iMissingCount + " skipped.",1)
	Else
		Debug.Trace("MYC/CM/" + sCharacterName + ":  Loaded " + vMYC_ShoutList.GetSize() + " Shouts.")
	EndIf
	FFUtils.LoadCharacterShouts(GetCharacterDummy(sCharacterName),vMYC_Shoutlist)
	WaitMenuMode(0.1)
	_bApplyShoutsBusy = False
	Return vMYC_ShoutList.GetSize()
EndFunction

Function RemoveCharacterShouts(String sCharacterName)
{Remove all shouts from named character. Needed because RemoveShout causes savegame corruption. }
	While _bApplyShoutsBusy
		WaitMenuMode(0.1)
	EndWhile
	_bApplyShoutsBusy = True
	Debug.Trace("MYC/CM/" + sCharacterName + ":  Character is not allowed to use shouts, removing them!")
	vMYC_Shoutlist.Revert()
	Shout vMYC_NullShout = GetFormFromFile(0x0201f055,"vMYC_MeetYourCharacters.esp") as Shout
	vMYC_ShoutList.AddForm(vMYC_NullShout)
	FFUtils.LoadCharacterShouts(GetCharacterDummy(sCharacterName),vMYC_Shoutlist)
	WaitMenuMode(0.1)
	_bApplyShoutsBusy = False
EndFunction

Function PopulateInventory(String sCharacterName, Bool abResetAll = False)
	Form kEquippedAmmo

	;Debug.Trace("MYC/CM/" + sCharacterName + ":  Creating dummy's inventory...")
	Int jCharacterInventory = GetCharacterObj(sCharacterName,"Inventory")
	Actor kCharacterActor = GetCharacterActorByName(sCharacterName)
	Int i = JFormMap.Count(jCharacterInventory)
	Int jInvForms = JFormMap.allKeys(jCharacterInventory)
	Int jInvCounts = JFormMap.allValues(jCharacterInventory)
	Int iLastGoldValue = 0

	If abResetAll
		kCharacterActor.RemoveAllItems()
	EndIf
	While i > 0
		i -= 1
		Form kItem = JArray.getForm(jInvForms,i)
		If kItem
			Int iType = kItem.GetType()
			If iType == 42 ; Ammo
				Int iItemCount = kCharacterActor.GetItemCount(kItem)
				If iItemCount
					kCharacterActor.RemoveItem(kItem,iItemCount)
					kCharacterActor.AddItem(kItem,JArray.getInt(jInvCounts,i))
				Else
					kCharacterActor.AddItem(kItem,JArray.getInt(jInvCounts,i))
				EndIf
				;Debug.Trace("MYC/CM/" + sCharacterName + ":  Ammo " + kItem.GetName() + " value is " + kItem.GetGoldValue() + ", iLastGoldValue is " + iLastGoldValue)
				If kItem.GetGoldValue() > iLastGoldValue
					kEquippedAmmo = kItem
					SetLocalForm(sCharacterName,"AmmoDefault",kEquippedAmmo)
					iLastGoldValue = kItem.GetGoldValue()
				EndIf
			EndIf
		EndIf
	EndWhile
	If kEquippedAmmo
		kCharacterActor.EquipItem(kEquippedAmmo) ; Equip ammo but allow character to remove it, otherwise bow behavior gets messed up
		;Debug.Trace("MYC/CM/" + sCharacterName + ":  Ammo equipped: " + kEquippedAmmo.GetName())
	EndIf
EndFunction

Bool Function LoadCharacter(String sCharacterName)
	;Debug.Trace("MYC/CM/" + sCharacterName + ":  LoadCharacter called!")
	Int i = 0
	;If _bBusyLoading 
		;Debug.Trace("MYC/CM/" + sCharacterName + ":  LoadCharacter is busy, waiting...")
	;	Return False
	;Else
	If GetLocalConfigBool("CM_Loading_" + sCharacterName)
		Debug.Trace("MYC/CM/" + sCharacterName + ":  LoadCharacter called multiple times!")
		Return False
	EndIf
	SetLocalConfigBool("CM_Loading_" + sCharacterName,True)
	_bBusyLoading = True

	;----Load Character data from _jMYC--------------

	Int jCharacterData

	If JValue.hasPath(_jMYC,"." + sCharacterName + ".Data")
		;Debug.Trace("MYC/CM/" + sCharacterName + ":  Loading character data from _jMYC...")
		jCharacterData = JValue.solveObj(_jMYC,"." + sCharacterName + ".Data")
		;Debug.Trace("MYC/CM/" + sCharacterName + ":  " + sCharacterName + " is a Level " + JValue.solveInt(jCharacterData,".Stats.Level") + " " + (JValue.solveForm(jCharacterData,".Race") as Race).GetName() + "!")
	Else
		;Debug.Trace("MYC/CM/" + sCharacterName + ":  No _jMYC data for " + sCharacterName + "! BUT, we'll try loading a file by that name, just in case...")
		Int jCharacterFileData = JValue.ReadFromFile(JContainers.userDirectory() + "vMYC/" + sCharacterName + ".char.json")
		If !jCharacterFileData
			jCharacterFileData = JValue.ReadFromFile("Data/vMYC/" + sCharacterName + ".char.json")
		EndIf
		If jCharacterFileData
			;Debug.Trace("MYC/CM/" + sCharacterName + ":  Okay, weird, we apparently have data for this character after all and the character list is desynced.")
			Int jCharacterTopLevel = JMap.Object()
			JMap.SetObj(jCharacterTopLevel,"Data",jCharacterFileData)
			JMap.setObj(_jMYC,sCharacterName,jCharacterTopLevel)
			jCharacterData = JValue.solveObj(_jMYC,"." + sCharacterName + ".Data")
		Else
			;Debug.Trace("MYC/CM/" + sCharacterName + ":  Nope, no data, no file, no ticky, no shirty. ABORT! ABORT!")
			SetLocalConfigBool("CM_Loading_" + sCharacterName,False)
			_bBusyLoading = False
			Return False
		EndIf
	EndIf
	
	If JMap.hasKey(jCharacterData,"LocationData")
		;Compatibility with older saves
		HangoutManager.ImportCharacterHangout(JMap.getObj(jCharacterData,"LocationData"),sCharacterName)
	ElseIf JMap.hasKey(jCharacterData,"Hangout")
		HangoutManager.ImportCharacterHangout(JMap.getObj(jCharacterData,"Hangout"),sCharacterName)
	EndIf

	;----Load or create ActorBaseMap--------------

	Int jActorBaseMap
	If !JMap.hasKey(_jMYC,"ActorBaseMap")
		;Debug.Trace("MYC/CM/" + sCharacterName + ":  First character load on this save, creating ActorBaseMap...")
		jActorBaseMap = JFormMap.Object()
		JMap.setObj(_jMYC,"ActorBaseMap",jActorBaseMap)
	Else
		jActorBaseMap = JMap.getObj(_jMYC,"ActorBaseMap")
	EndIf

	;----Check if this character is already loaded--------------

	;Debug.Trace("MYC/CM/" + sCharacterName + ":  Finding ActorBase for " + sCharacterName + "...")
	ActorBase DummyActorBase = GetLocalForm(sCharacterName,"ActorBase") as ActorBase
	Actor kCharacterActor = GetLocalForm(sCharacterName,"Actor") as Actor
	If !kCharacterActor
		kCharacterActor = GetCharacterActorByName(sCharacterName)
	EndIf

	If kCharacterActor ; Already been loaded
		Debug.Trace("MYC/CM/" + sCharacterName + ":  This character is already assigned ActorBase " + DummyActorBase + " and is currently Actor " + kCharacterActor)
		SetLocalInt(sCharacterName,"Enabled", 1)
		;kCharacterActor.RemoveallItems()
		kCharacterActor.Enable()
		;Wait(1.0)
		(kCharacterActor as vMYC_CharacterDummyActorScript).DoUpkeep()
		;_bBusyLoading = False
		;Return True
	EndIf

	;----Get ActorBase for character--------------

	If !DummyActorBase ; Not loaded on this save session
		;Debug.Trace("MYC/CM/" + sCharacterName + ":  No saved ActorBase found, getting a new one...")
		DummyActorBase = GetFreeActorBase(JMap.getInt(jCharacterData,"Sex"))
		If !DummyActorBase ; Not loaded on this save session
			Debug.Trace("MYC/CM/" + sCharacterName + ":  Could not find available ActorBase for " + sCharacterName + "!")
			SetLocalConfigBool("CM_Loading_" + sCharacterName,False)
			_bBusyLoading = False
			Return False
		EndIf
		SetLocalForm(sCharacterName,"ActorBase",DummyActorBase)
		JFormMap.setStr(jActorBaseMap,DummyActorBase,sCharacterName) ; Assign character name to ActorBase as a sort of reverse lookup
	EndIf
	Debug.Trace("MYC/CM/" + sCharacterName + ":  ActorBase will use " + DummyActorBase + "!")
	
	;----Load Actor and begin setting up the ActorBase--------------

	DummyActorBase.SetEssential(True)
	DummyActorBase.SetName(sCharacterName)
	kCharacterActor = GetCharacterActor(DummyActorBase)

	;ApplyCharacterPerks(sCharacterName)

	If !kCharacterActor
		kCharacterActor = LoadPoint.PlaceAtMe(DummyActorBase, abInitiallyDisabled = True) as Actor
	EndIf

	;-----==== NIOverride support ====-----

	;-----====                    ====-----


	Debug.Trace("MYC/CM/" + sCharacterName + ":  " + sCharacterName + " is actor " + kCharacterActor)
	SetLocalForm(sCharacterName,"Actor",kCharacterActor)
	;Debug.Trace("MYC/CM/" + sCharacterName + ":  Made it through SetLocalForm...")
	vMYC_CharacterDummyActorScript CharacterDummy = kCharacterActor as vMYC_CharacterDummyActorScript
	CharacterDummy.NeedRefresh = True
	SetLocalForm(sCharacterName,"Script",CharacterDummy)
	SetLocalInt(sCharacterName,"TrackingEnabled",0)
	;Wait(0.5) ; Don't remove this, the following statement locks up without it, god knows why
	;Debug.Trace("MYC/CM/" + sCharacterName + ":  About to set CharacterDummy.CharacterName property...")
	CharacterDummy.CharacterName = JMap.getStr(jCharacterData,"Name")

	;Debug.Trace("MYC/CM/" + sCharacterName + ":  Stored name is " + CharacterDummy.CharacterName + "!")

	CharacterDummy.CharacterRace = JValue.solveForm(jCharacterData,".Race") as Race
	;Debug.Trace("MYC/CM/" + sCharacterName + ":  Stored race is " + CharacterDummy.CharacterRace + "!")

	;Debug.Trace("MYC/CM/" + sCharacterName + ":  Setting voicetype to " + JValue.solveForm(jCharacterData,".Race") as VoiceType)
	;DummyActorBase.SetVoiceType(JValue.solveForm(jCharacterData,".Race") as VoiceType)

	Int idx = _kLoadedCharacters.Find(None)
	_kLoadedCharacters[idx] = kCharacterActor

	CharacterDummy.DoInit()
	_bBusyLoading = False

	;----Load and equip armor--------------

	;Int iArmorCount = ApplyCharacterArmor(sCharacterName)
	
	
	;----Populate inventory--------------

	;PopulateInventory(sCharacterName)

	;----Add spells--------------

	SetLocalInt(sCharacterName,"MagicAutoSelect",1)

	;Debug.Trace("MYC/CM/" + sCharacterName + ":  Setting the dummy's actor values...")
	;i = 0
	;While i < _sAVNames.Length
		;If _sAVNames[i]
			;Float fAV = GetFloatValue(DummyActorBase,sKey + "Stat.AV." + _sAVNames[i])
			;kCharacterActor.ForceActorValue(_sAVNames[i],fAV)
			;Debug.Trace("MYC/CM/" + sCharacterName + ":  Set dummy's " + _sAVNames[i] + " to " + fAV)
		;EndIf
		;i += 1
	;EndWhile

	kCharacterActor.SetAV("Confidence",3)
	kCharacterActor.SetAV("Assistance",2)
	;kCharacterActor.SetAV("Confidence",3)

	kCharacterActor.Enable(True)
	Wait(1)

	;----Load and equip weapons/hand gear--------------
	;Int iWeaponCount = ApplyCharacterWeapons(sCharacterName)

	SetLocalInt(sCharacterName,"Enabled", 1)
	;Debug.Trace("MYC/CM/" + sCharacterName + ":  Enabling dummy...")

	SetLocalInt(sCharacterName,"HangoutIndexDefault",-1)
	SetLocalInt(sCharacterName,"HangoutIndex",-1)
	;PickHangout(sCharacterName)
	;CharacterDummy.DoUpkeep()
	;SetCharacterTracking(sCharacterName,True)
	SetLocalConfigBool("CM_Loading_" + sCharacterName,False)
	_bBusyLoading = False
	Return True
EndFunction

Function LoadWeapon(Actor kCharacterActor, Int jItem, Int iHand, Bool bLeaveEquipped = False)
	Bool bTwoHanded = False
	Form kItem = JMap.getForm(jItem,"Form")
	String sCharacterName = kCharacterActor.GetActorBase().GetName()
	If kItem as Weapon
		Int iWeaponType = (kItem as Weapon).GetWeaponType()
		If iWeaponType == 5 || iWeaponType == 6 || iWeaponType == 7 || iWeaponType == 9 ; Greatswords, axes, bows or crossbows
			bTwoHanded = True
		EndIf
		If iWeaponType == 7
			SetLocalInt(sCharacterName,"BowEquipped",1)
		EndIf
		;Debug.Trace("MYC/CM/" + sCharacterName + ":  adding " + kItem.GetName() +"...")
		If !(bTwoHanded && iHand == 0)
			If kCharacterActor.GetItemCount(kItem)
				kCharacterActor.RemoveItem(kItem)
			EndIf
			kCharacterActor.AddItem(kItem)
		EndIf
		;Wait(1)
		;kCharacterActor.DrawWeapon()
		;Wait(1)
		;WaitMenuMode(0.1)
		;Debug.Trace("MYC/CM/" + sCharacterName + ":  equipping " + kItem.GetName() +"...")
		If iHand == 1 ; Equip in proper hand and prevent removal
			kCharacterActor.EquipItemEx(kItem,1,True) ; Right
		ElseIf !bTwoHanded
			kCharacterActor.EquipItemEx(kItem,2,True) ; Left
		EndIf
		;Wait(1)
		;kCharacterActor.DrawWeapon()
		;Wait(1)
		;kCharacterActor.EquipItemEx(kItem)

		If JMap.getInt(jItem,"IsCustom")
			String sDisplayName = JMap.getStr(jItem,"DisplayName")
			;Debug.Trace("MYC/CM/" + sCharacterName + ":  " + kItem.GetName() + " is customized item " + sDisplayName + "!")
			;Debug.Trace("MYC/CM/" + sCharacterName + ":  WornObject.SetItemHealthPercent(kCharacterActor," + iHand + ",0," + JMap.getFlt(jItem,"ItemHealthPercent"))
			WornObject.SetItemHealthPercent(kCharacterActor,iHand,0,JMap.getFlt(jItem,"ItemHealthPercent"))
			;Debug.Trace("MYC/CM/" + sCharacterName + ":  WornObject.SetItemMaxCharge(kCharacterActor," + iHand + ",0," + JMap.getFlt(jItem,"ItemMaxCharge"))
			WornObject.SetItemMaxCharge(kCharacterActor,iHand,0,JMap.getFlt(jItem,"ItemMaxCharge"))
			If sDisplayName ; Will be blank if player hasn't renamed the item
				;Debug.Trace("MYC/CM/" + sCharacterName + ":  WornObject.SetDisplayName(kCharacterActor," + iHand + ",0," + sDisplayName)
				WornObject.SetDisplayName(kCharacterActor,iHand,0,sDisplayName)
			EndIf

			Float[] fMagnitudes = New Float[8]
			Int[] iDurations = New Int[8]
			Int[] iAreas = New Int[8]
			MagicEffect[] kMagicEffects = New MagicEffect[8]
			;Wait(1)
			If JValue.solveInt(jItem,".Enchantment.IsCustom")
				Int iNumEffects = JValue.solveInt(jItem,".Enchantment.NumEffects")
				;Debug.Trace("MYC/CM/" + sCharacterName + ":  " + sDisplayName + " has a customized enchantment with " + inumEffects + " magiceffects!")
				Int j = 0
				Int jWeaponEnchEffects = JValue.SolveObj(jItem,".Enchantment.Effects")
				While j < iNumEffects
					Int jWeaponEnchEffect = JArray.getObj(jWeaponEnchEffects,j)
					fMagnitudes[j] = JMap.GetFlt(jWeaponEnchEffect,"Magnitude")
					iDurations[j] = JMap.GetFlt(jWeaponEnchEffect,"Duration") as Int
					iAreas[j] = JMap.GetFlt(jWeaponEnchEffect,"Area") as Int
					kMagicEffects[j] = JMap.GetForm(jWeaponEnchEffect,"MagicEffect") as MagicEffect
					j += 1
				EndWhile
				;Debug.Trace("MYC/CM/" + sCharacterName + ":  " + sDisplayName + " creating custom enchantment...")
				WornObject.CreateEnchantment(kCharacterActor,iHand,0,JMap.getFlt(jItem,"ItemMaxCharge"), kMagicEffects, fMagnitudes, iAreas, iDurations)

				;Debug.Trace("MYC/CM/" + sCharacterName + ":  " + sDisplayName + " done!")
			EndIf
			If iHand == 1
				kCharacterActor.SetActorValue("RightItemCharge",JMap.getFlt(jItem,"ItemCharge"))
			Else
				kCharacterActor.SetActorValue("LeftItemCharge",JMap.getFlt(jItem,"ItemCharge"))
			EndIf
		EndIf
		If iHand == 1 ; Equip in proper hand and allow removal
			kCharacterActor.EquipItemEx(kItem,1) ;,True) ; Right
		ElseIf !bTwoHanded
			kCharacterActor.EquipItemEx(kItem,2,True) ;Left, and prevent removal because otherwise the game immediately unequips the left hand
		EndIf
	ElseIf kItem ; Item is not a Weapon, probably a spell or shield. Just equip it.
		If iHand == 1 ; Equip in proper hand and prevent removal
			kCharacterActor.EquipItemEx(kItem,1) ;,True) ; Right
		ElseIf !bTwoHanded
			kCharacterActor.EquipItemEx(kItem,2) ;,True) ; Left
		EndIf
	EndIf
	If !bLeaveEquipped
		kCharacterActor.UnEquipItemEX(kItem,1)
		kCharacterActor.UnEquipItemEX(kItem,2)
	EndIf
EndFunction

Function PickHangout(String asCharacterName)
{Legacy function, do not use!}
EndFunction

Int Function CreateLocalDataIfMissing(String asCharacterName)
	Int jCharacter = JMap.getObj(_jMYC,asCharacterName)
	Int jCharLocalData = JMap.getObj(jCharacter,"!LocalData")
	If jCharLocalData
		Return jCharLocalData
	EndIf
	;Debug.Trace("MYC/CM: (" + asCharacterName + ") First local data access, creating LocalData key!")
	jCharLocalData = JMap.Object()
	JMap.setObj(jCharacter,"!LocalData",jCharLocalData)
	Return jCharLocalData
EndFunction

Bool Function HasLocalKey(String asCharacterName, String asPath)
	Int jCharacterLocal = CreateLocalDataIfMissing(asCharacterName)
	Return JMap.hasKey(jCharacterLocal,asPath)
EndFunction

Function SetLocalString(String asCharacterName, String asPath, String asString)
	Int jCharacterLocal = CreateLocalDataIfMissing(asCharacterName)
	JMap.setStr(jCharacterLocal,asPath,asString)
EndFunction

String Function GetLocalString(String asCharacterName, String asPath)
	Return JValue.solveStr(_jMYC,"." + asCharacterName + ".!LocalData." + asPath)
EndFunction

Function SetLocalInt(String asCharacterName, String asPath, Int aiInt)
	Int jCharacterLocal = CreateLocalDataIfMissing(asCharacterName)
	JMap.setInt(jCharacterLocal,asPath,aiInt)
EndFunction

Int Function GetLocalInt(String asCharacterName, String asPath)
	Return JValue.solveInt(_jMYC,"." + asCharacterName + ".!LocalData." + asPath)
EndFunction

Function SetLocalFlt(String asCharacterName, String asPath, Float afFloat)
	Int jCharacterLocal = CreateLocalDataIfMissing(asCharacterName)
	JMap.setFlt(jCharacterLocal,asPath,afFloat)
EndFunction

Float Function GetLocalFlt(String asCharacterName, String asPath)
	Return JValue.solveFlt(_jMYC,"." + asCharacterName + ".!LocalData." + asPath)
EndFunction

Function SetLocalForm(String asCharacterName, String asPath, Form akForm)
	Int jCharacterLocal = CreateLocalDataIfMissing(asCharacterName)
	JMap.setForm(jCharacterLocal,asPath,akForm)
EndFunction

Form Function GetLocalForm(String asCharacterName, String asPath)
	Return JValue.solveForm(_jMYC,"." + asCharacterName + ".!LocalData." + asPath)
EndFunction

Function SetLocalObj(String asCharacterName, String asPath, Int ajObj)
	Int jCharacterLocal = CreateLocalDataIfMissing(asCharacterName)
	JMap.setObj(jCharacterLocal,asPath,ajObj)
EndFunction

Int Function GetLocalObj(String asCharacterName, String asPath)
	Return JValue.solveObj(_jMYC,"." + asCharacterName + ".!LocalData." + asPath)
EndFunction

ReferenceAlias Function GetAvailableReference(String[] sSpawnPoints)
{Legacy function, do not use!}
	Return None
EndFunction

State SerializeBusy
	Function SerializeEquipment(Form kItem, Int jEquipmentInfo, Int iHand = 1, Int h = 0, Actor kWornObjectActor = None)
		Wait(RandomFloat(0.1,1))
		SerializeEquipment(kItem,jEquipmentInfo,iHand,h,kWornObjectActor)
	EndFunction
EndState

Function SerializeEquipment(Form kItem, Int jEquipmentInfo, Int iHand = 1, Int h = 0, Actor kWornObjectActor = None)
{Fills the JMap jEquipmentInfo with all info from Form kItem}
	GotoState("SerializeBusy")
	JMap.SetForm(jEquipmentInfo,"Form",kItem)

	If !kWornObjectActor
		kWornObjectActor = PlayerREF
	EndIf

	Bool isWeapon = False
	Bool isEnchantable = False
	Bool isTwoHanded = False
	Enchantment kItemEnchantment
	If kItem
		;Debug.Trace("MYC/CM: " + kItem.GetName() + " is Mod ID " + (kItem.GetFormID() / 0x1000000))
		JMap.SetStr(jEquipmentInfo,"Source",GetModName(kItem.GetFormID() / 0x1000000))
	EndIf
	;Debug.Trace("MYC/CM: Serializing " + kItem.GetName() + "...")
	If (kItem as Weapon)
		isWeapon = True
		isEnchantable = True
		Int iWeaponType = (kItem as Weapon).GetWeaponType()
		If iWeaponType > 4 && iWeaponType != 8
			IsTwoHanded = True
		EndIf
		kItemEnchantment = (kItem as Weapon).GetEnchantment()
	ElseIf (kItem as Armor)
		isEnchantable = True
		kItemEnchantment = (kItem as Armor).GetEnchantment()
	EndIf

	Int jEquipmentEnchantmentInfo = JMap.Object()
	If isEnchantable ; don't create enchantment block unless object can be enchanted
		JMap.SetObj(jEquipmentInfo,"Enchantment",jEquipmentEnchantmentInfo)
	EndIf

	If kItemEnchantment
		;PlayerEnchantments[newindex] = kItemEnchantment
		;Debug.Trace("MYC/CM: " + kItem.GetName() + " has enchantment " + kItemEnchantment.GetFormID() + ", " + kItemEnchantment.GetName())
		JMap.SetForm(jEquipmentEnchantmentInfo,"Form",kItemEnchantment)
		JMap.SetStr(jEquipmentInfo,"Source",GetModName(kItemEnchantment.GetFormID() / 0x1000000))
		JMap.SetStr(jEquipmentEnchantmentInfo,"Source",GetModName(kItemEnchantment.GetFormID() / 0x1000000))
		JMap.SetInt(jEquipmentEnchantmentInfo,"IsCustom",0)
	EndIf
	String sItemDisplayName = WornObject.GetDisplayName(kWornObjectActor,iHand,h)
	sItemDisplayName = StringUtil.SubString(sItemDisplayName,0,StringUtil.Find(sItemDisplayName,"(") - 1) ; Strip " (Legendary)"
	kItemEnchantment = WornObject.GetEnchantment(kWornObjectActor,iHand,h)
	If sItemDisplayName || kItemEnchantment
		;Debug.Trace("MYC/CM: " + kItem + " is enchanted/forged item " + sItemDisplayName)
		JMap.SetInt(jEquipmentInfo,"IsCustom",1)
		JMap.SetFlt(jEquipmentInfo,"ItemHealthPercent",WornObject.GetItemHealthPercent(kWornObjectActor,iHand,h))
		JMap.SetFlt(jEquipmentInfo,"ItemCharge",WornObject.GetItemCharge(kWornObjectActor,iHand,h))
		JMap.SetFlt(jEquipmentInfo,"ItemMaxCharge",WornObject.GetItemMaxCharge(kWornObjectActor,iHand,h))
		JMap.SetStr(jEquipmentInfo,"DisplayName",sItemDisplayName)
		kItemEnchantment = WornObject.GetEnchantment(kWornObjectActor,iHand,h)
		If kItemEnchantment
			JMap.SetForm(jEquipmentEnchantmentInfo,"Form",kItemEnchantment)
			JMap.SetStr(jEquipmentEnchantmentInfo,"Source",GetModName(kItemEnchantment.GetFormID() / 0x1000000))
			JMap.SetInt(jEquipmentEnchantmentInfo,"IsCustom",1)
			Int iNumEffects = kItemEnchantment.GetNumEffects()
			JMap.SetInt(jEquipmentEnchantmentInfo,"NumEffects",iNumEffects)
			Int jEffectsArray = JArray.Object()
			Int j = 0
			While j < iNumEffects
				Int jEffectsInfo = JMap.Object()
				JMap.SetFlt(jEffectsInfo, "Magnitude", kItemEnchantment.GetNthEffectMagnitude(j))
				JMap.SetFlt(jEffectsInfo, "Area", kItemEnchantment.GetNthEffectArea(j))
				JMap.SetFlt(jEffectsInfo, "Duration", kItemEnchantment.GetNthEffectDuration(j))
				JMap.SetForm(jEffectsInfo,"MagicEffect", kItemEnchantment.GetNthEffectMagicEffect(j))
				JMap.SetStr(jEffectsInfo,"Source",GetModName(kItemEnchantment.GetNthEffectMagicEffect(j).GetFormID() / 0x1000000))
				JArray.AddObj(jEffectsArray,jEffectsInfo)
				j += 1
			EndWhile
			JMap.SetObj(jEquipmentEnchantmentInfo,"Effects",jEffectsArray)
		EndIf
	Else
		JMap.SetInt(jEquipmentInfo,"IsCustom",0)
	EndIf
	
	;Save dye color, if applicable
	If GetConfigInt("NIO_UseDye") && kItem as Armor
		Bool bHasDye = False
		Int iHandle = NiOverride.GetItemUniqueID(kWornObjectActor, 0, (kItem as Armor).GetSlotMask(), False)
		Int[] iNIODyeColors = New Int[15]
		Int iMaskIndex = 0
		While iMaskIndex < iNIODyeColors.Length
			Int iColor = NiOverride.GetItemDyeColor(iHandle, iMaskIndex)
			If Math.RightShift(iColor,24) > 0
				bHasDye = True
				iNIODyeColors[iMaskIndex] = iColor
			EndIf
			iMaskIndex += 1
		EndWhile
		If bHasDye
			JMap.SetObj(jEquipmentInfo,"NIODyeColors",JArray.objectWithInts(iNIODyeColors))
		EndIf
	EndIf

	If !(iHand == 0 && IsTwoHanded) && kItem ; exclude left-hand iteration of two-handed weapons
		If kWornObjectActor == PlayerREF
			kItem.SendModEvent("vMYC_EquipmentSaved","",iHand)
		Else ;Was not saved from player, indicate this with iHand = -1
			kItem.SendModEvent("vMYC_EquipmentSaved","",-1)
		EndIf
	EndIf
	;Debug.Trace("MYC/CM: Finished serializing " + kItem.GetName() + ", JMap count is " + JMap.Count(jEquipmentInfo))
	GotoState("")
EndFunction

Event OnSaveCurrentPlayerEquipment(string eventName, string strArg, float numArg, Form sender)
	If sender != Self
		Return
	EndIf
	_bSavedEquipment = False

	Int jPlayerData = strArg as Int
	String sPlayerName = PlayerREF.GetActorBase().GetName()

	SendModEvent("vMYC_EquipmentSaveBegin")

	Int jPlayerEquipment = JMap.Object()
	JMap.SetObj(jPlayerData,"Equipment",jPlayerEquipment)

	Int jPlayerArmorList = JArray.Object()
	JMap.SetObj(jPlayerEquipment,"Armor",jPlayerArmorList)

	Int jPlayerArmorInfoList = JArray.Object()
	JMap.SetObj(jPlayerEquipment,"ArmorInfo",jPlayerArmorInfoList)

	Int h = 0x00000001
	While (h < 0x80000000)
		Form WornForm = PlayerREF.GetWornForm(h)
		If (WornForm)
			;Debug.Trace("MYC/CM: " + sPlayerName + " is wearing " + WornForm + ", " + WornForm.GetName() + " on slot " + h)
			If JArray.FindForm(jPlayerArmorList,WornForm) < 0
				JArray.AddForm(jPlayerArmorList,WornForm)
				Int iArmorIndex = JArray.FindForm(jPlayerArmorList,WornForm)
				If WornForm as Armor && iArmorIndex > -1
					;Debug.Trace("MYC/CM: Added " + WornForm.GetName())

					Int jPlayerArmorInfo = JMap.Object()

					JArray.AddObj(jPlayerArmorInfoList,jPlayerArmorInfo)
					AddToReqList(jPlayerData,WornForm,"Equipment")
					SerializeEquipment(WornForm,jPlayerArmorInfo,1,h)

				EndIf
			EndIf
		EndIf
		h = Math.LeftShift(h,1)
	endWhile

	Int jEquipLeft = JMap.Object()
	JMap.SetObj(jPlayerEquipment,"Left",jEquipLeft)
	Int jEquipRight = JMap.Object()
	JMap.SetObj(jPlayerEquipment,"Right",jEquipRight)

	SerializeEquipment(PlayerREF.GetEquippedObject(0),jEquipLeft,0,0)
	SerializeEquipment(PlayerREF.GetEquippedObject(1),jEquipRight,1,0)
	
	Int jEquipVoice = JMap.Object()
	JMap.SetForm(jEquipVoice,"Form",PlayerREF.GetEquippedObject(2))

	JMap.SetObj(jPlayerEquipment,"Voice",jEquipVoice)

	AddToReqList(jPlayerData,PlayerREF.GetEquippedObject(0),"Equipment")
	AddToReqList(jPlayerData,PlayerREF.GetEquippedObject(1),"Equipment")
	AddToReqList(jPlayerData,PlayerREF.GetEquippedObject(2),"Equipment")


	SendModEvent("vMYC_EquipmentSaveEnd")
	_bSavedEquipment = True
EndEvent

Event OnSaveCurrentPlayerSpells(string eventName, string strArg, float numArg, Form sender)
	If sender != Self
		Return
	EndIf
	_bSavedSpells = False

	Int jPlayerData = strArg as Int
	String sPlayerName = PlayerREF.GetActorBase().GetName()

	SendModEvent("vMYC_SpellsSaveBegin")
	Int jPlayerSpells = JArray.Object()
	JMap.SetObj(jPlayerData,"Spells",jPlayerSpells)
	
	Int jSpellSources = JArray.Object()
	JMap.SetObj(jPlayerData,"SpellSources",jSpellSources)
	
	Int iSpellCount = PlayerREF.GetSpellCount()
	Int iAddedCount = 0
	Int i = 0
	Bool bAddItem = False
	;Debug.Trace("MYC/CM: " + sPlayerName + " knows " + iSpellCount + " spells.")
	While i < iSpellCount
		bAddItem = False
		Spell kSpell = PlayerREF.GetNthSpell(i)
		If kSpell
			bAddItem = True
			Int iSpellID = kSpell.GetFormID()
			;Debug.Trace("MYC/CM: " + sPlayerName + " knows the spell " + kSpell + ", " + kSpell.GetName())
			If bAddItem
				;vMYC_PlayerFormlist.AddForm(kSpell)
				JArray.AddForm(jPlayerSpells,kSpell)
				JArray.AddStr(jSpellSources,GetModName(kSpell.GetFormID() / 0x1000000))
				AddToReqList(jPlayerData,kSpell,"Spell")
				iAddedCount += 1
				If iAddedCount % 2 == 0
					kSpell.SendModEvent("vMYC_SpellSaved")
				EndIf
			EndIf
		EndIf
		i += 1
	EndWhile
	SendModEvent("vMYC_SpellsSaveEnd",iAddedCount)
	;Debug.Trace("MYC/CM: Saved " + iAddedCount + " spells for " + sPlayerName + ".")

	Int jPlayerShouts = JArray.Object()
	JMap.SetObj(jPlayerData,"Shouts",jPlayerShouts)

	Int iShoutCount = vMYC_PlayerShoutCheckList.GetSize()
	i = 0
	While i < iShoutCount
		Shout kShout = vMYC_PlayerShoutCheckList.GetAt(i) as Shout
		If PlayerREF.HasSpell(kShout)
			JArray.AddForm(jPlayerShouts,kShout)
		EndIf
		i += 1
	EndWhile
	;Debug.Trace("MYC/CM: Saved " + JArray.Count(jPlayerShouts) + " shouts for " + sPlayerName + ".")

	_bSavedSpells = True
EndEvent

Event OnSaveCurrentPlayerInventory(string eventName, string strArg, float numArg, Form sender)
	If sender != Self
		Return
	EndIf
	_bSavedInventory = False

	Int jPlayerData = strArg as Int
	String sPlayerName = PlayerREF.GetActorBase().GetName()
	SendModEvent("vMYC_InventorySaveBegin")
	;Turn inventory into a formmap
	Int iSafety = 10
	While PlayerInventoryTracker.Busy && iSafety > 0
		iSafety -= 1
		Wait(1.0)
	EndWhile

	Int jInvMap = JMap.getObj(_jMYC,"PlayerInventory")
	Int jInvForms = JFormMap.allKeys(jInvMap)
	Int jInvCounts = JFormMap.allValues(jInvMap)
	JValue.Retain(jInvForms,"vMYC_CM")
	JValue.Retain(jInvCounts,"vMYC_CM")
	Int jPlayerInventory = JFormMap.Object()
	JMap.SetObj(jPlayerData,"Inventory",jPlayerInventory)

	Int jPlayerCustomItems = JArray.Object()
	JMap.SetObj(jPlayerData,"InventoryCustomItems",jPlayerCustomItems)

	Bool bAddItem = False

	Int iItemCount = JArray.Count(jInvForms)
	Int i = 0
	;Debug.Trace("MYC/CM: " + sPlayerName + " has " + iItemCount + " items.")
	Int iAddedCount = 0

	;===== Create dummy actor for custom weapon scans =====----

	Actor kWeaponDummy = PlayerREF.PlaceAtMe(vMYC_InvisibleMActor,abInitiallyDisabled = True) as Actor
	kWeaponDummy.SetScale(0.01)
	kWeaponDummy.SetGhost(True)
	kWeaponDummy.EnableAI(False)
	kWeaponDummy.EnableNoWait()
	Int iSafetyTimer = 30
	While !kWeaponDummy.Is3DLoaded() && iSafetyTimer
		iSafetyTimer -= 1
		Wait(0.1)
	EndWhile

	While i < iItemCount
		bAddItem = True
		Form kItem = JArray.getForm(jInvForms,i)

		Int iType = kItem.GetType()
		;Debug.Trace("MYC/CM: " + sPlayerName + " has " + kItem)

		;===== Save custom weapons =====----
		If iType == 41 ;kWeapon
			If !PlayerREF.IsEquipped(kItem)
				bAddItem = False
				PlayerREF.RemoveItem(kItem,1,True,kWeaponDummy)
				kWeaponDummy.EquipItemEX(kItem,1,preventUnequip = True,equipSound = False)
				If WornObject.GetDisplayName(kWeaponDummy,1,0) || WornObject.GetItemHealthPercent(kWeaponDummy,1,0) > 1.0
					Int jCustomWeapon = JMap.Object()

					JMap.setForm(jCustomWeapon,"Form",kItem)
					JMap.setInt(jCustomWeapon,"Count",JArray.getInt(jInvCounts,i))

					SerializeEquipment(kItem,jCustomWeapon,1,0,kWeaponDummy)
					JArray.AddObj(jPlayerCustomItems,jCustomWeapon)
				EndIf
				kWeaponDummy.RemoveItem(kItem,1,True,PlayerREF)

				;JArray.AddForm(jWeaponsToCheck,kItem)
			EndIf
		EndIf
		Int iItemID = kItem.GetFormID()
		If iItemID > 0x05000000 || iItemID < 0 && !(iItemID > 0xFF000000 && iItemID < 0xFFFFFFFF)
			; Item is NOT part of Skyrim, Dawnguard, Hearthfires, or Dragonborn and is not a custom item
			;Debug.Trace("MYC/CM: " + kItem + " is a mod-added item!")
			;bAddItem = False
		ElseIf (iItemID > 0xFF000000 && iItemID < 0xFFFFFFFF)
			; This is a custom-made item
			;Debug.Trace("MYC/CM: " + kItem + " is a customized/forged/mixed item!")
			bAddItem = False
		EndIf
		If kItem as ObjectReference
			;Debug.Trace("MYC/CM: " + kItem + " is an ObjectReference named " + (kItem as ObjectReference).GetDisplayName())
		EndIf
		If bAddItem
			JFormMap.SetInt(jPlayerInventory,kItem,JArray.getInt(jInvCounts,i))
			kItem.SendModEvent("vMYC_ItemSaved")
			iAddedCount += 1
		EndIf
		i += 1
	EndWhile
	;Debug.Trace("MYC/CM: Saved " + iAddedCount + " items for " + sPlayerName + ".")



;	i = jArray.Count(jWeaponsToCheck)
;	While i > 0
;		i -= 1
;		Form kItem = jArray.getForm(jWeaponsToCheck,i)
;	EndWhile
	;Debug.Trace("MYC/CM: Saved " + JArray.Count(jPlayerCustomItems) + " custom items for " + sPlayerName + ".")

	SendModEvent("vMYC_InventorySaveEnd",iAddedCount)
	_bSavedInventory = True
	JValue.Release(jInvForms)
	JValue.Release(jInvCounts)
	kWeaponDummy.RemoveAllItems(PlayerREF)
	kWeaponDummy.Delete()
EndEvent

Event OnSaveCurrentPlayerPerks(string eventName, string strArg, float numArg, Form sender)
	If sender != Self
		Return
	EndIf
	_bSavedPerks = False

	Int jPlayerData = strArg as Int
	String sPlayerName = PlayerREF.GetActorBase().GetName()

	SendModEvent("vMYC_PerksSaveBegin")

	String[] SkillNames = New String[24]

	SkillNames[6] = "OneHanded"
	SkillNames[7] = "TwoHanded"
	SkillNames[8] = "Marksman"
	SkillNames[9] = "Block"
	SkillNames[10] = "Smithing"
	SkillNames[11] = "HeavyArmor"
	SkillNames[12] = "LightArmor"
	SkillNames[13] = "Pickpocket"
	SkillNames[14] = "LockPicking"
	SkillNames[15] = "Sneak"
	SkillNames[16] = "Alchemy"
	SkillNames[17] = "SpeechCraft"
	SkillNames[18] = "Alteration"
	SkillNames[19] = "Conjuration"
	SkillNames[20] = "Destruction"
	SkillNames[21] = "Illusion"
	SkillNames[22] = "Restoration"
	SkillNames[23] = "Enchanting"

	Int jPerks = JArray.Object()
	JMap.SetObj(jPlayerData,"Perks",jPerks)

	Int jPerkCounts = JMap.Object()
	JMap.SetObj(jPlayerData,"PerkCounts",jPerkCounts)

	Int jPerkSources = JArray.Object()
	JMap.SetObj(jPlayerData,"PerkSources",jPerkSources)
	
	vMYC_PerkList.Revert()
	Int iAdvSkills = 6
	While iAdvSkills < 24
		ActorValueInfo AVInfo = ActorValueInfo.GetActorValueInfoByID(iAdvSkills)
		Int iLastCount = vMYC_PerkList.GetSize()
		AVInfo.GetPerkTree(vMYC_PerkList, PlayerREF, false, true)
		Int iThisCount = vMYC_PerkList.GetSize()
		JMap.SetInt(jPerkCounts,SkillNames[iAdvSkills],iThisCount - iLastCount)
		;Debug.Trace("MYC/CM: Saved " + (iThisCount - iLastCount) + " perks in the " + SkillNames[iAdvSkills] + " tree!")
		iAdvSkills += 1
	EndWhile

	Int iAddedCount = 0
	Int i = vMYC_PerkList.GetSize()
	While i > 0
		i -= 1
		Perk kPerk = vMYC_PerkList.GetAt(i) as Perk
		JArray.addForm(jPerks,kPerk)
		JArray.AddStr(jPerkSources,GetModName(kPerk.GetFormID() / 0x1000000))
		AddToReqList(jPlayerData,kPerk,"Perk")
		If iAddedCount % 3 == 0
			SendModEvent("vMYC_PerkSaved")
		EndIf
		iAddedCount += 1
	EndWhile

	SendModEvent("vMYC_PerksSaveEnd",iAddedCount)

	_bSavedPerks = True
EndEvent

Int Function NIO_GetOverlayData(String sTintTemplate, Int iTintCount, Actor kTargetActor = None)
	If !kTargetActor
		kTargetActor = PlayerREF
	EndIf
	Int i
	Int jOverlayData = JArray.Object()
	While i < iTintCount
		String nodeName = sTintTemplate + i + "]"
		Int iRGB = 0
		Int iGlow = 0
		Float fMultiple = 0.0
		Float fAlpha = 0
		String sTexture = ""
		If NetImmerse.HasNode(kTargetActor, nodeName, false) ; Actor has the node, get the immediate property
			iRGB = NiOverride.GetNodePropertyInt(kTargetActor, false, nodeName, 7, -1)
			iGlow = NiOverride.GetNodePropertyInt(kTargetActor, false, nodeName, 0, -1)
			fAlpha = NiOverride.GetNodePropertyFloat(kTargetActor, false, nodeName, 8, -1)
			sTexture = NiOverride.GetNodePropertyString(kTargetActor, false, nodeName, 9, 0)
			fMultiple = NiOverride.GetNodePropertyFloat(kTargetActor, false, nodeName, 1, -1)
		Else ; Doesn't have the node, get it from the override
			bool isFemale = kTargetActor.GetActorBase().GetSex() as bool
			iRGB = NiOverride.GetNodeOverrideInt(kTargetActor, isFemale, nodeName, 7, -1)
			iGlow = NiOverride.GetNodeOverrideInt(kTargetActor, isFemale, nodeName, 0, -1)
			fAlpha = NiOverride.GetNodeOverrideFloat(kTargetActor, isFemale, nodeName, 8, -1)
			sTexture = NiOverride.GetNodeOverrideString(kTargetActor, isFemale, nodeName, 9, 0)
			fMultiple = NiOverride.GetNodeOverrideFloat(kTargetActor, isFemale, nodeName, 1, -1)
		Endif
		Int iColor = Math.LogicalOr(Math.LogicalAnd(iRGB, 0xFFFFFF), Math.LeftShift((fAlpha * 255) as Int, 24))
		Int iGlowData = Math.LogicalOr(Math.LeftShift(((fMultiple * 10.0) as Int), 24), iGlow)
		If sTexture == ""
			sTexture = "Actors\\Character\\Overlays\\Default.dds"
		Endif
		If !(iRGB + iGlow + fAlpha + fMultiple == 0 && StringUtil.Find(sTexture,"Default.dds") > -1) || (iRGB && iRGB != -1 && iRGB != 16777215) || iGlow || (fAlpha && fAlpha != 1.0) || (fMultiple && fMultiple != 1.0) || (sTexture && sTexture != "Textures\\Actors\\Character\\Overlays\\Default.dds")
			Int jLayer = JMap.Object()
			JMap.setInt(jLayer,"RGB",iRGB)
			JMap.setInt(jLayer,"Glow",iGlow)
			JMap.setInt(jLayer,"GlowData",iGlowData)
			JMap.setFlt(jLayer,"Alpha",fAlpha)
			JMap.setFlt(jLayer,"Multiple",fMultiple)
			JMap.setInt(jLayer,"Color",iColor)
			JMap.setStr(jLayer,"Texture",sTexture)
			JArray.AddObj(jOverlayData,jLayer)
		EndIf
		i += 1
	EndWhile
	Return jOverlayData
EndFunction

Function NIO_DoApplyOverlay(Actor kCharacter, Int jLayers, String sNodeTemplate)
	If !kCharacter 
		Return
	EndIf
	Int iLayerCount = JArray.Count(jLayers)
	Int i = 0
	Bool bIsFemale = kCharacter.GetActorBase().GetSex()
	While i < iLayerCount
		Int jLayer = JArray.GetObj(jLayers,i)
		String sNodeName = sNodeTemplate + i + "]"

		;rgb = NiOverride.GetNodePropertyInt(_targetActor, false, nodeName, 7, -1)
		;glow = NiOverride.GetNodePropertyInt(_targetActor, false, nodeName, 0, -1)
		;alpha = NiOverride.GetNodePropertyFloat(_targetActor, false, nodeName, 8, -1)
		;texture = NiOverride.GetNodePropertyString(_targetActor, false, nodeName, 9, 0)
		;multiple = NiOverride.GetNodePropertyFloat(_targetActor, false, nodeName, 1, -1)

		NiOverride.AddNodeOverrideInt(kCharacter, bIsFemale, sNodeName, 7, -1, JMap.GetInt(jLayer,"RGB"), True) ; Set the tint color
		;NiOverride.AddNodeOverrideInt(kCharacter, bIsFemale, sNodeName, 0, -1, JMap.GetInt(jLayer,"Glow"), True) ; Set the glow
		NiOverride.AddNodeOverrideFloat(kCharacter, bIsFemale, sNodeName, 8, -1, JMap.GetFlt(jLayer,"Alpha"), True) ; Set the alpha
		NiOverride.AddNodeOverrideString(kCharacter, bIsFemale, sNodeName, 9, 0, JMap.GetStr(jLayer,"Texture"), True) ; Set the tint texture
		;NiOverride.AddNodeOverrideString(kCharacter, bIsFemale, sNodeName, 1, -1, JMap.GetFlt(jLayer,"Multiple"), True) ; Set the emissive multiple

		Int iGlowData = JMap.GetInt(jLayer,"GlowData")
		Int iGlowColor = iGlowData
		Int iGlowEmissive = Math.RightShift(iGlowColor, 24)
		NiOverride.AddNodeOverrideInt(kCharacter, bIsFemale, sNodeName, 0, -1, iGlowColor, True) ; Set the emissive color
		NiOverride.AddNodeOverrideFloat(kCharacter, bIsFemale, sNodeName, 1, -1, iGlowEmissive / 10.0, True) ; Set the emissive multiple
		i += 1
	EndWhile
EndFunction

Function NIO_ApplyCharacterOverlays(String sCharacterName)
	Int jOverlayData = GetCharacterObj(sCharacterName,"NIOverrideData")
	If !jOverlayData
		Return
	EndIf
	Actor kCharacter = GetCharacterActorByName(sCharacterName)
	If !NiOverride.HasOverlays(kCharacter)
		NiOverride.AddOverlays(kCharacter)
	EndIf
	NiOverride.RevertOverlays(kCharacter)
	NIO_DoApplyOverlay(kCharacter,JMap.GetObj(jOverlayData,"BodyOverlays"),"Body [Ovl")
	NIO_DoApplyOverlay(kCharacter,JMap.GetObj(jOverlayData,"HandOverlays"),"Hand [Ovl")
	NIO_DoApplyOverlay(kCharacter,JMap.GetObj(jOverlayData,"FeetOverlays"),"Feet [Ovl")
	NIO_DoApplyOverlay(kCharacter,JMap.GetObj(jOverlayData,"FaceOverlays"),"Face [Ovl")

EndFunction

Function SetUUIDIfMissing()
	If !GetLocalConfigStr("PlayerUUID")
		SetLocalConfigStr("PlayerUUID",GetUUIDTrue())
		Debug.Trace("MYC/CM: Set player UUID: " + GetLocalConfigStr("PlayerUUID"))
	EndIf
EndFunction

Function SaveCurrentPlayer(Bool bSaveEquipment = True, Bool SaveCustomEquipment = True, Bool bSaveInventory = True, Bool bSaveFullInventory = True, Bool bSavePluginItems = False, Bool bForceSave = False)
	_bSavedPerks = False
	_bSavedSpells = False
	_bSavedEquipment = False
	_bSavedInventory = False

	SetUUIDIfMissing()
	
	Form[] PlayerEquipment = New Form[64]
	Enchantment[] PlayerEnchantments = New Enchantment[64]

	ActorBase PlayerBase = PlayerREF.GetActorBase()
	ActorBase DummyActorBase = GetFreeActorBase(PlayerBase.GetSex())

	String sPlayerName = PlayerBase.GetName()
	If !sPlayerName
		sPlayerName = PlayerREF.GetActorBase().GetName()
		;Debug.Trace("MYC/CM: Name from GetActorBase: " + sPlayerName)
	EndIf
	If !sPlayerName
		sPlayerName = PlayerREF.GetBaseObject().GetName()
		;Debug.Trace("MYC/CM: Name from GetBaseObject: " + sPlayerName)
	EndIf

	Int jCharacterNames = JMap.allKeys(JValue.solveObj(_jMYC,".CharacterList"))

	If JArray.findStr(jCharacterNames,sPlayerName) > -1
		;Debug.Trace("MYC/CM: Player " + sPlayerName + " is already saved!")
		If bForceSave
			;Debug.Trace("MYC/CM: bForceSave is True, so saving anyway...")
		Else
			Return
		EndIf
	EndIf

	;Debug.Trace("MYC/CM: Getting basic data from " + sPlayerName + "...")

	;Debug.Trace("MYC/CM:            Race: " + PlayerREF.GetRace() + ", " + PlayerREF.GetRace().GetName())
	;Debug.Trace("MYC/CM:          Weight: " + PlayerREF.GetWeight() + ", " + PlayerREF.GetActorBase().GetWeight())
	;Debug.Trace("MYC/CM:          Height: " + PlayerREF.GetHeight() + ", " + PlayerREF.GetActorBase().GetHeight())

	Int iFree = 0
	While iFree < _sCharacterNames.Length && _sCharacterNames[iFree] != ""
		iFree += 1
	EndWhile

	_sCharacterNames[iFree] = sPlayerName
	Debug.Notification("Saving " + sPlayerName + "'s data, this may take a minute...")

	Int jPlayerData = JMap.Object()
	JValue.Retain(jPlayerData,"vMYC_CM") 

	JMap.SetStr(jPlayerData,"Name",sPlayerName)
	JMap.SetInt(jPlayerData,"Sex",PlayerREF.GetActorBase().GetSex())
	JMap.SetForm(jPlayerData,"Race",PlayerREF.GetActorBase().GetRace())

	;-----==== Save custom location data
	
	String sHangoutName = JMap.GetStr(_jMYC,"PlayerHangout")
	If sHangoutName
		JMap.SetObj(jPlayerData,"Hangout",HangoutManager.GetFullHangoutObj("sHangoutName"))
	EndIf
	
	;-----==== Save some metainfo. Some is duplicated for reasons that made sense at the time. I swear I wasn't drunk

	Int jPlayerModList = JArray.Object()
	Int iModCount = GetModCount()
	i = 0
	While i < iModCount
		JArray.AddStr(jPlayerModList,GetModName(i))
		i += 1
	EndWhile

	Int jMetaInfo = JMap.Object()
	JMap.setObj(jMetaInfo,"Modlist",jPlayerModList)

	JMap.setStr(jMetaInfo,"Name",sPlayerName)
	JMap.setStr(jMetaInfo,"RaceText",PlayerREF.GetActorBase().GetRace().GetName())
	JMap.setFlt(jMetaInfo,"Playtime",GetRealHoursPassed())
	JMap.setInt(jMetaInfo,"SerializationVersion",SerializationVersion)
	JMap.setStr(jMetaInfo,"UUID",GetLocalConfigStr("PlayerUUID"))
	JMap.setObj(jPlayerData,"_MYC",jMetaInfo)
	AddToReqList(jPlayerData,PlayerREF.GetActorBase().GetRace(),"Race")
	;-----==== Save actorvalues

	Float[] fPlayerBaseAVs = New Float[97]
	String sBlank = "                             "

	Int jPlayerAVs = JMap.Object()
	Int i = 0
	While i < _sAVNames.Length
		If _sAVNames[i]
			fPlayerBaseAVs[i] = PlayerREF.GetBaseActorValue(_sAVNames[i])
			JMap.SetFlt(jPlayerAVs,_sAVNames[i],fPlayerBaseAVs[i])
			;SetFloatValue(DummyActorBase,sKey + "Stat.AV." + _sAVNames[i],fPlayerBaseAVs[i])
			;Debug.Trace("MYC/CM: " + StringUtil.SubString(sBlank,0,StringUtil.GetLength(sBlank) - StringUtil.GetLength(_sAVNames[i])) + _sAVNames[i] + ":, " + fPlayerBaseAVs[i])
		EndIf
		i += 1
	EndWhile

	Int jPlayerStats = JMap.Object()
	JMap.SetInt(jPlayerStats,"Level",PlayerREF.GetLevel())
	JMap.SetFlt(jPlayerStats,"Weight",PlayerREF.GetActorBase().GetWeight())
	JMap.SetFlt(jPlayerStats,"Height",PlayerREF.GetActorBase().GetHeight())

	JMap.SetObj(jPlayerStats,"AV",jPlayerAVs)
	JMap.SetObj(jPlayerData,"Stats",jPlayerStats)


	;-----==== Save spawnpoints/trophies

	i = 0

	Int jPlayerSpawnPoints = JArray.Object()
	String[] sSpawnPoints = PickPlayerSpawnPoints()
	While i < sSpawnPoints.Length
		If sSpawnPoints[i]
			JArray.AddStr(jPlayerSpawnPoints,sSpawnPoints[i])
		EndIf
		i += 1
	EndWhile

	JMap.SetObj(jPlayerData,"SpawnPoints",jPlayerSpawnPoints)

	;-----==== Start parallel saving of equipment, perks, spells, and inventory

	RegisterForModEvent("vMYC_SaveCurrentPlayerEquipment","OnSaveCurrentPlayerEquipment")
	SendModEvent("vMYC_SaveCurrentPlayerEquipment",jPlayerData)

	RegisterForModEvent("vMYC_SaveCurrentPlayerPerks","OnSaveCurrentPlayerPerks")
	SendModEvent("vMYC_SaveCurrentPlayerPerks",jPlayerData)

	RegisterForModEvent("vMYC_SaveCurrentPlayerSpells","OnSaveCurrentPlayerSpells")
	SendModEvent("vMYC_SaveCurrentPlayerSpells",jPlayerData)

	RegisterForModEvent("vMYC_SaveCurrentPlayerInventory","OnSaveCurrentPlayerInventory")
	SendModEvent("vMYC_SaveCurrentPlayerInventory",jPlayerData)

	VoiceType kPlayerVoiceType = PlayerREF.GetVoiceType()
	If !kPlayerVoiceType
		kPlayerVoiceType = PlayerREF.GetActorBase().GetVoiceType()
	EndIf

	JMap.SetForm(jPlayerData,"VoiceType",kPlayerVoiceType)

	;-----==== Support for NIOverride ====-----

	If SKSE.GetPluginVersion("NiOverride") >= 1 ; Check for NIO
		Int jNIOData = JMap.Object()
		JMap.SetObj(jPlayerData,"NIOverrideData",jNIOData)
		JMap.setObj(jNIOData,"BodyOverlays",NIO_GetOverlayData("Body [Ovl",NIOverride.GetNumBodyOverlays()))
		JMap.setObj(jNIOData,"HandOverlays",NIO_GetOverlayData("Hand [Ovl",NIOverride.GetNumHandOverlays()))
		JMap.setObj(jNIOData,"FeetOverlays",NIO_GetOverlayData("Feet [Ovl",NIOverride.GetNumFeetOverlays()))
		JMap.setObj(jNIOData,"FaceOverlays",NIO_GetOverlayData("Face [Ovl",NIOverride.GetNumFaceOverlays()))
	EndIf

	;-----==== Support for RaceMenuPlugin.psc ====-----
	JMap.SetObj(jPlayerData,"NINodeData",GetNINodeInfo(PlayerREF))
		
	;-----==== None of this is needed anymore thanks to the new chargen
	;  function, but it doesn't take long to collect so why not ====-----

	Int jPlayerAppearance = JMap.Object()
	JMap.SetObj(jPlayerData,"Appearance",jPlayerAppearance)

	ColorForm kHairColor = PlayerBase.GetHairColor()
	JMap.SetForm(jPlayerAppearance,"Haircolor",kHairColor)
	If kHairColor
		JMap.SetStr(jPlayerAppearance,"HaircolorSource",GetModName(kHairColor.GetFormID() / 0x1000000))
		Int jHairColor = JValue.objectFromPrototype("{ \"r\": " + kHairColor.GetRed() + ", \"g\": " + kHairColor.GetGreen() + ", \"b\": " + kHairColor.GetBlue() + ", \"h\": " + kHairColor.GetHue() + ", \"s\": " + kHairColor.GetSaturation() + ", \"v\": " + kHairColor.GetValue() + " }")
		JMap.SetObj(jPlayerAppearance,"HaircolorDetails",jHairColor)
	EndIf
	JMap.SetForm(jPlayerAppearance,"Skin",PlayerBase.GetSkin())
	JMap.SetForm(jPlayerAppearance,"SkinFar",PlayerBase.GetSkinFar())

	Int jPlayerHeadparts = JArray.Object()
	JMap.SetObj(jPlayerAppearance,"Headparts",jPlayerHeadparts)
	Int jHeadpartSources = JArray.Object()
	JMap.SetObj(jPlayerAppearance,"HeadpartSources",jHeadpartSources)
	
	i = 0
	While i < PlayerBase.GetNumHeadParts()
		HeadPart kHeadPart = PlayerBase.GetNthHeadPart(i)
		Int j = 0
		If kHeadPart
			JArray.AddForm(jPlayerHeadparts,kHeadPart)
			JArray.AddStr(jHeadpartSources,GetModName(kHeadPart.GetFormID() / 0x1000000))
			AddToReqList(jPlayerData,kHeadPart,"Headpart")
			While j < kHeadPart.GetNumExtraParts()
				HeadPart kExtraHeadPart = kHeadPart.GetNthExtraPart(j)
				If kExtraHeadPart
					JArray.Addform(jPlayerHeadparts,kExtraHeadPart)
					JArray.AddStr(jHeadpartSources,GetModName(kExtraHeadPart.GetFormID() / 0x1000000))
					AddToReqList(jPlayerData,kExtraHeadPart,"Headpart")
				EndIf
				j += 1
			EndWhile
		EndIf
		i += 1
	EndWhile

	Int jPlayerFace = JMap.Object()
	JMap.SetObj(jPlayerAppearance,"Face",jPlayerFace)

	Int jPlayerFaceTextureSet = JMap.Object()
	JMap.SetObj(jPlayerFace,"TextureSet",jPlayerFaceTextureSet)
	Int jPlayerFaceTexturePaths = JArray.Object()
	JMap.SetObj(jPlayerFaceTextureSet,"Paths",jPlayerFaceTexturePaths)

	vMYC_PlayerFaceTexture = PlayerBase.GetFaceTextureSet()
	If vMYC_PlayerFaceTexture
		JMap.SetForm(jPlayerFaceTextureSet,"Form",vMYC_PlayerFaceTexture)
		i = 0
		While i < vMYC_PlayerFaceTexture.GetNumTexturePaths()
			;Debug.Trace("MYC/CM: PlayerFaceTexture path " + i + " is " + vMYC_PlayerFaceTexture.GetNthTexturePath(i))
			JArray.AddStr(jPlayerFaceTexturePaths,vMYC_PlayerFaceTexture.GetNthTexturePath(i))
			i += 1
		EndWhile
	EndIf

	Int jPlayerFacePresets = JArray.Object()
	JMap.SetObj(jPlayerFace,"Presets",jPlayerFacePresets)

	i = 0
	While i < PlayerBase.GetNumHeadParts()
		;Debug.Trace("MYC/CM: Copying face preset " + i)
		JArray.AddInt(jPlayerFacePresets,PlayerBase.GetFacePreset(i))
		i += 1
	EndWhile

	Int jPlayerFaceMorphs = JArray.Object()
	JMap.SetObj(jPlayerFace,"Morphs",jPlayerFaceMorphs)
	i = 0
	While i < 20 ; PlayerBase.GetNumHeadParts() * 4
		Float fFaceMorph = PlayerBase.GetFaceMorph(i)
		JArray.AddFlt(jPlayerFaceMorphs,fFaceMorph)
		i += 1
	EndWhile

	Bool bUseExternal = False
	If GetModByName("EnhancedCharacterEdit.esp") < 255
		Debug.Notification("ECE detected, using SaveExternalCharacter!")
		bUseExternal = True
	EndIf
	
	If CharGen.IsExternalEnabled() || bUseExternal
		 CharGen.SaveExternalCharacter(sPlayerName) 
	Else
		 CharGen.SaveCharacter(sPlayerName) 
	EndIf
	

	;Old head export function
	;Debug.MessageBox("Chargen Version is " + SKSE.GetPluginVersion("CharGen"))
	;If SKSE.GetPluginVersion("CharGen") > 0
		;Debug.Trace("MYC/CM: Exporting head with CharGen...")
		;UI.InvokeString("HUD Menu", "_global.skse.plugins.CharGen.ExportHead", "Data\\Textures\\actors\\character\\FaceGenData\\FaceTint\\vMYC_MeetYourCharacters.esp\\" + sPlayerName)
		;Debug.Trace("MYC/CM: Done!")
	;Else
	;	Debug.MessageBox("No CharGen, MAN!")
	;EndIf


	While !_bSavedEquipment || !_bSavedPerks || !_bSavedInventory || !_bSavedSpells
		Wait(0.5)
	EndWhile

	;JValue.WriteToFile(jPlayerData,"Data/vMYC/" + sPlayerName + ".char.json")
	JValue.WriteToFile(jPlayerData,JContainers.userDirectory() + "vMYC/" + sPlayerName + ".char.json")
	Debug.Notification("Exported character data!")
	JValue.Release(jPlayerData)

	LoadCharacterFiles()

EndFunction

Int Function GetNINodeInfo(Actor akActor)

	Int jNINodeList = JValue.ReadFromFile("Data/vMYC/vMYC_NodeList.json")
	JValue.Retain(jNINodeList,"vMYC_CM")
	Debug.Trace("MYC/CM: NINodeList contains " + JArray.Count(jNINodeList) + " entries!")
	
	
	Int jNINodes = JMap.Object()
	JValue.Retain(jNINodes,"vMYC_CM")
	Int i = 0
	Int iNodeCount = JArray.Count(jNINodeList)
	While i < iNodeCount
		String sNodeName = JArray.getStr(jNINodeList,i)
		If sNodeName
			If NetImmerse.HasNode(akActor,sNodeName,false)
				Float fNodeScale = NetImmerse.GetNodeScale(akActor,sNodeName,false)
				If fNodeScale != 1.0
					Debug.Trace("MYC/CM: Saving NINode " + sNodeName + " at scale " + fNodeScale + "!")
					Int jNINodeData = JMap.Object()
					JMap.SetFlt(jNINodeData,"Scale",fNodeScale)
					JMap.SetObj(jNINodes,sNodeName,jNINodeData)
				EndIf
			EndIf
		EndIf
		i += 1
	EndWhile
	JValue.Release(jNINodeList)
	JValue.Release(jNINodes)
	Return jNINodes
EndFunction

String[] Function PickPlayerSpawnPoints()
{Return an array of default spawn points based on accomplishments}
	String[] sResult = New String[32]
	Int idx = 0
	If MQ305.IsCompleted()
		sResult[idx] = "Hero"
		idx += 1
	EndIf
	If DB11.IsCompleted()
		sResult[idx] = "DarkBrotherhoodRestored"
		idx += 1
	ElseIf DBDestroy.IsCompleted()
		sResult[idx] = "DarkBrotherhoodDestroyed"
		idx += 1
	EndIf
	If MG08.IsCompleted()
		sResult[idx] = "Mage"
		idx += 1
	EndIf
	If TG09.IsCompleted()
		sResult[idx] = "Thief"
		idx += 1
	EndIf
	If MQ206.IsCompleted()
		If MQPaarthurnax.IsCompleted()
			sResult[idx] = "Blade"
		Else
			sResult[idx] = "Greybeard"
		EndIf
		idx += 1
	EndIf
	If CWSiegeObj.IsCompleted()
		If PlayerREF.IsInFaction(CWImperialFaction)
			sResult[idx] = "Imperial"
		ElseIf PlayerREF.IsInFaction(CWSonsFaction)
			sResult[idx] = "Stormcloak"
		EndIf
		idx += 1
	EndIf
	If MS05.IsCompleted()
		sResult[idx] = "Bard"
		idx += 1
	EndIf
	If C06.IsCompleted()
		sResult[idx] = "Companion"
		idx += 1
	EndIf

	; Dawnguard

	If PlayerREF.HasSpell(WerewolfChange) ; Player is a worwelf
		sResult[idx] = "Werewolf"
		idx += 1
	ElseIf DLC1VampireChange
		If PlayerREF.HasSpell(DLC1VampireChange) ; Player is a vampire lord
			sResult[idx] = "VampireLord"
			idx += 1
		EndIf
	EndIf

	If DLC1MQ02 ;Only filled if Dawnguard is loaded
		If DLC1MQ02.IsCompleted() ; Only handle dawnguard if player is actually doing the questline
			If DLC1PlayingVampireLine.GetValue() == 1
				sResult[idx] = "VampireFaction"
				idx += 1
			Else
				sResult[idx] = "DawnguardFaction"
				idx += 1
			EndIf
			If DLC1MQ08.IsCompleted()
				sResult[idx] = "DLC1Completed"
				idx += 1
			EndIf
		EndIf
		;DLC1SunPedestal 0201AAF1
		;DLC1SilverGobletBlood01 02011DB2 (*3 for 02)
		;DLC1BloodPotion 02018EF3
		;DLC1NightPowerShrine 02009404
	EndIf

	; Dragonborn
	If DLC2MQ06 ;Only filled if Dragonborn is loaded
		If DLC2MQ06.IsCompleted()
			sResult[idx] = "DLC2KilledMiraak"
			idx += 1
		EndIf
		;DLC2MiraakMaskNew 02029A62
	EndIf

	If ThaneTracker.PaleImpGetOutOfJail > 0 || ThaneTracker.PaleSonsGetOutOfJail > 0
		sResult[idx] = "Dawnstar"
		idx += 1
	EndIf
	If ThaneTracker.WhiterunImpGetOutofJail > 0 || ThaneTracker.WhiterunSonsGetOutofJail > 0
		sResult[idx] = "Whiterun"
		idx += 1
	EndIf
	If ThaneTracker.HjaalmarchImpGetOutofJail > 0 || ThaneTracker.HjaalmarchSonsGetOutofJail > 0
		sResult[idx] = "Morthal"
		idx += 1
	EndIf
	If ThaneTracker.ReachImpGetOutofJail > 0 || ThaneTracker.ReachSonsGetOutofJail > 0
		sResult[idx] = "Markarth"
		idx += 1
	EndIf
	If ThaneTracker.FalkreathImpGetOutofJail > 0 || ThaneTracker.FalkreathSonsGetOutofJail > 0
		sResult[idx] = "Falkreath"
		idx += 1
	EndIf


	;Debug.Trace("MYC/CM: PlayerREF.GetActorBase().GetRace().GetName() = " + PlayerREF.GetActorBase().GetRace().GetName())
	If StringUtil.Find(PlayerREF.GetActorBase().GetRace().GetName(),"Orc") > -1
		sResult[idx] = "Orc"
		idx += 1
	EndIf
	If StringUtil.Find(PlayerREF.GetActorBase().GetRace().GetName(),"Khajiit") > -1
		sResult[idx] = "Caravan"
		idx += 1
	EndIf
	Return sResult
EndFunction

String Function GetFormIDString(Form kForm)
	String sResult
	sResult = kForm as String ; [FormName < (FF000000)>]
	sResult = StringUtil.SubString(sResult,StringUtil.Find(sResult,"(") + 1,8)
	Return sResult
EndFunction

Function CleanupTempJContainers()
	JValue.ReleaseObjectsWithTag("vMYC_CM")
	JValue.CleanPool("vMYC_CM_Load")
	JValue.CleanPool("vMYC_CM_Repair")
EndFunction
