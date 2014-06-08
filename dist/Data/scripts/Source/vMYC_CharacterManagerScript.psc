Scriptname vMYC_CharacterManagerScript extends Quest  
{Save and restore character data independently of save files. Requires SKSE and PapyrusUtils}

;--=== Imports ===--

Import Utility
Import Game
;Import StorageUtil

;--=== Properties ===--

Int Property SerializationVersion = 2 Auto Hidden

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

String[] Property sHangoutNames Auto Hidden

ReferenceAlias[] Property kHangoutRefAliases Auto Hidden

LocationAlias	Property	kLastPlayerLocation Auto 

LocationAlias[]	Property	kCustomLocations Auto

String[] Property sClassNames Auto

Class[] Property kClasses Auto

CombatStyle[] Property kCombatStyles Auto

Formlist Property vMYC_CombatStyles Auto

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

Formlist Property vMYC_PlayerFormlist Auto
{An empty formlist that will be used to store all the player's spells, shouts, etc.}

Formlist Property vMYC_DummyActorsMList Auto
{Formlist containing the male dummy actors}

Formlist Property vMYC_DummyActorsFList Auto
{Formlist containing the female dummy actors}

Formlist Property vMYC_PerkList Auto
{A list of all the perks we want to check for.}

Formlist Property vMYC_VoiceTypesFollowerList Auto
{A list of voicetypes that can be followers.}

Formlist Property vMYC_VoiceTypesAllList Auto
{A list of all voicetypes.}

TextureSet Property vMYC_PlayerFaceTexture Auto

TextureSet Property vMYC_DummyTexture Auto

Message Property vMYC_CharactersLoadingMSG Auto
Message Property vMYC_CharactersLoadedMSG Auto
Message	Property vMYC_CharacterListLoadedMSG Auto

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

ActorBase[] _kDummyActors

;Because Formlists can't be trusted to stay in any sort of order

Actor[] _kLoadedCharacters

String[] _sAVNames

String[] _sCharacterNames

Int _jMYC

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

	sHangoutNames = New String[18]
	kHangoutRefAliases = New ReferenceAlias[18]
	
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

;--=== Functions ===--

Function DoUpkeep(Bool bInBackground = True)
	If bInBackground
		_bDoUpkeep = True
		RegisterForSingleUpdate(0)
		Return
	EndIf
	SendModEvent("vMYC_UpkeepBegin")
	LoadCharacterFiles()
	RefreshCharacters()
	SendModEvent("vMYC_UpkeepEnd")
	JDB.writeToFile("Data/vMYC/jdb_postupkeep.json")
	JValue.writeToFile(_jMYC,"Data/vMYC/jMYC_postupkeep.json")
EndFunction

Function DoInit()
	_bDoInit = True
	_jMYC = JDB.solveObj(".vMYC")
	If !_jMYC
		Debug.Trace("MYC: JDB has no MYC data, creating it!")
		_jMYC = JMap.object()
		JDB.setObj("vMYC",_jMYC)
	EndIf
	
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
			;;Debug.Trace("MYC: Slot " + idx + " is ActorBase " + _kDummyActors[idx].GetName() + " " + _kDummyActors[idx])
;			SetStringValue(_kDummyActors[idx],sKey + "Name","foo")
;			ExportFile(_kDummyActors[idx].GetName(),restrictForm = _kDummyActors[idx])
		EndIf
		idx += 1
	EndWhile
	LoadCharacterFiles()
	If GetModByName("Dawnguard.esm") != 255
		DLC1PlayingVampireLine = GetFormFromFile(0x0200587A,"Dawnguard.esm") as GlobalVariable
		DLC1MQ02 = GetFormFromFile(0x02002F65,"Dawnguard.esm") as Quest 
		DLC1MQ08 = GetFormFromFile(0x02007C25,"Dawnguard.esm") as Quest
		DLC1VampireChange = GetFormFromFile(0x0200283B,"Dawnguard.esm") as Spell
	EndIf
	If GetModByName("Dragonborn.esm") != 255
		DLC2MQ06 = GetFormFromFile(0x020179D7,"Dragonborn.esm") as Quest
	EndIf
	RegisterForSingleUpdate(1)
EndFunction

Function RefreshCharacters()
	Int jActorMap = JMap.getObj(_jMYC,"ActorBaseMap")
	Int jActorBaseList = JFormMap.allKeys(jActorMap)
	Int i = JArray.Count(jActorBaseList)
	While i > 0
		i -= 1
		ActorBase kActorBase = JArray.getForm(jActorBaseList,i) as ActorBase
		If kActorBase
			Debug.Trace("MYC: Refreshing " + JFormMap.getStr(jActorMap,kActorBase) + ", ActorBase " + kActorBase)
			Actor kTargetActor = GetCharacterActor(kActorBase)
			(kTargetActor as vMYC_CharacterDummyActorScript).DoUpkeep(True)
		EndIf
	EndWhile
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
	
	Debug.Trace("MYC: Reading directory...")
	Int jDirectoryScan = JValue.readFromDirectory("Data/vMYC/")
	Int jCharFiles = JMap.allKeys(jDirectoryScan)
	Int jCharData = JMap.allValues(jDirectoryScan)
	i = JMap.Count(jDirectoryScan)
	
	;--- Load and validate all files in the data directory
	While i > 0
		i -= 1
		Int jCharacterData = JArray.getObj(jCharData,i)
		If ValidateCharacterInfo(jCharacterData) > -1
			If UpgradeCharacterInfo(jCharacterData)
				JValue.WriteToFile(jCharacterData,"Data/vMYC/" + JArray.getStr(jCharFiles,i)) ; write the file back if the data version was upgraded
			EndIf
			String sCharacterName = JValue.solveStr(jCharacterData,".Name")
			Debug.Trace("MYC: File " + i + " is " + JArray.getStr(jCharFiles,i) + " - " + sCharacterName)
			If !JMap.hasKey(jCharacterMap,sCharacterName)
				JMap.setStr(jCharacterMap,sCharacterName,JArray.getStr(jCharFiles,i))
				Int jCharacterInfo = JMap.Object()
				JMap.SetObj(_jMYC,sCharacterName,jCharacterInfo)
				JMap.SetObj(jCharacterInfo,"Data",jCharacterData)
				JMap.setObj(_jMYC,sCharacterName,jCharacterInfo)
				SetLocalInt(sCharacterName,"FilePresent",1)
				Debug.Trace("MYC: " + sCharacterName + " is a Level " + JValue.solveInt(jCharacterData,".Stats.Level") + " " + (JValue.solveForm(jCharacterData,".Race") as Race).GetName() + "!")
			Else
				;We're loading a file for a character we already have a record of.
				Int jCharacterInfo = JMap.getObj(_jMYC,sCharacterName)
				If JValue.solveFlt(jCharacterInfo,".Data.!MYC.PlayTime") != JValue.solveFlt(jCharacterData,".!MYC.PlayTime")
					Debug.Trace("MYC: The saved data for " + sCharacterName + " HAS changed!")
					JMap.setObj(jCharacterInfo,"Data",jCharacterData)
				Else
					Debug.Trace("MYC: The saved data for " + sCharacterName + " hasn't changed.")
				EndIf
				SetLocalInt(sCharacterName,"FilePresent",1)
			EndIf
		Else ; Validation failed
			;Debug.Trace("MYC: File " + i + " is " + JArray.getStr(jCharFiles,i) + " - No valid character data!")
		EndIf
	EndWhile
	
	;--- See if any existing characters lost their files
	i = JArray.Count(jCharacterNames)
	While i > 0
		i -= 1
		String sCharacterName = jArray.getStr(jCharacterNames,i)
		If !GetLocalInt(sCharacterName,"FilePresent") && !GetLocalInt(sCharacterName,"ShowedMissingWarning")
			SetLocalInt(sCharacterName,"ShowedMissingWarning",1)
			Debug.Trace("MYC: The saved data for " + sCharacterName + " is missing! :(")
			Debug.MessageBox("The saved data for " + sCharacterName + " is missing! You can use MCM to remove (or restore) " + sCharacterName + "'s data from this session.")
		EndIf
	EndWhile
EndFunction

Int Function ValidateCharacterInfo(Int jCharacterData)
	;Debug.Trace("MYC: ValidateCharacterData!")
	If !JValue.hasPath(jCharacterData,".!MYC.SerializationVersion") && JMap.hasKey(jCharacterData,"Name")
		;Debug.Trace("MYC: Character data is valid but from an early development version.")
		Return 0
	ElseIf JValue.hasPath(jCharacterData,".!MYC.SerializationVersion")
		Int iSVer = JValue.solveInt(jCharacterData,"._MYC.SerializationVersion")
		;Debug.Trace("MYC: Character data is valid, serialization version " + iSVer)
		Return iSVer
	EndIf
	Return -1
EndFunction

Bool Function UpgradeCharacterInfo(Int jCharacterData)
	Bool bUpgraded = False
	If !JValue.hasPath(jCharacterData,".!MYC.SerializationVersion") && JMap.hasKey(jCharacterData,"Name")
		;Dev version, upgrade to version 1
		;Debug.Trace("MYC: Upgrading dev version data to version 1...")
		Int jMetaInfo = JMap.Object()
		JMap.setInt(jMetaInfo,"SerializationVersion",1)
		JMap.setStr(jMetaInfo,"Name",JMap.getStr(jCharacterData,"Name"))
		JMap.setObj(jCharacterData,"!MYC",jMetaInfo)
		If !JMap.hasKey(jCharacterData,"ModList")
			JMap.setObj(jCharacterData,"Modlist",JArray.object()) ; Add empty modlist entry
		EndIf
		;Debug.Trace("MYC: ...version 1 upgrade finished!")
		bUpgraded = True
	EndIf
	Int iDataVer = JValue.solveInt(jCharacterData,".!MYC.SerializationVersion")
	If iDataVer == 1
		;Debug.Trace("MYC: Data serialization is version " + iDataVer + ", current version is " + SerializationVersion)
		;Debug.Trace("MYC: Upgrading version 1 to version 2...")
		Int jMetaInfo = JMap.getObj(jCharacterData,"!MYC")
		JMap.setStr(jMetaInfo,"Name",JMap.getStr(jCharacterData,"Name"))
		JMap.setStr(jMetaInfo,"RaceText",(JMap.getForm(jCharacterData,"Race") as Race).GetName())
		JMap.setFlt(jMetaInfo,"Playtime",JMap.getFlt(jCharacterData,"PlayTime"))
		JMap.setObj(jMetaInfo,"ModList",JMap.getObj(jCharacterData,"ModList"))
		JMap.removeKey(jCharacterData,"Playtime")
		JMap.removeKey(jCharacterData,"ModList")
		JMap.setInt(jMetaInfo,"SerializationVersion",2)
		;Debug.Trace("MYC: ...version 2 upgrade finished!")
		bUpgraded = True
	EndIf
	iDataVer = JValue.solveInt(jCharacterData,".!MYC.SerializationVersion")
	If iDataVer < SerializationVersion
		;Debug.Trace("MYC: Data serialization is version " + iDataVer + ", current version is " + SerializationVersion)
		;Debug.Trace("MYC: Unfortunately no upgrade function is in place, so we'll just have to hope for the best!")
	ElseIf iDataVer == SerializationVersion
		;Debug.Trace("MYC: Data serialization is up to date!")
	Else
		;Debug.Trace("MYC: Data serialization is from a future version? Odd. We'll just have to hope it works.")
	EndIf
	Return bUpgraded
EndFunction

ActorBase Function GetFreeActorBase(Int iSex)
{Returns the first available dummy actorbase of the right sex}
	While _bFreeActorBaseBusy
		Debug.Trace("MYC: Waiting for GetFreeActorBase...")
		Wait(0.5)
	EndWhile
	_bFreeActorBaseBusy = True
	Int jActorBaseMap = JValue.solveObj(_jMYC,".ActorBaseMap")
	Int i = 0
	While i < _kDummyActors.Length
		If _kDummyActors[i]
			If _kDummyActors[i].GetSex() == iSex
				If !JFormMap.hasKey(jActorBaseMap,_kDummyActors[i])
					_bFreeActorBaseBusy = False
					Return _kDummyActors[i]
				EndIf
			EndIf
		EndIf
		i += 1
	EndWhile
	_bFreeActorBaseBusy = False
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
	Return JValue.solveStr(_jMYC,"." + asCharacterName + ".Data.!MYC." + asMetaName)
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

Function AddCustomLocation(Location kLocation)
	If !kLocation
		Return
	EndIf
	Int i = kCustomLocations.Length
	Int iEmptyIndex = -1
	While i > 0
		i -= 1
		Location kThisLocation = kCustomLocations[i].GetLocation()
		If kThisLocation == kLocation
			Return ; This location is already on the list
		ElseIf !kThisLocation
			iEmptyIndex = i
		EndIf
	EndWhile
	;--- If we got this far, then the new location is not on the list.
	kCustomLocations[i].ForceLocationTo(kLocation)
EndFunction

String Function GetCharacterNameFromActorBase(ActorBase akActorBase)
	;Debug.Trace("MYC: GetCharacterNameFromActorBase(ActorBase akActorBase)")
	Return JFormMap.getStr(JMap.getObj(_jMYC,"ActorBaseMap"),akActorBase)
EndFunction

Float Function GetCharacterStat(String asCharacterName,String asStatName)
	Return JValue.solveFlt(_jMYC,"." + asCharacterName + ".Data.Stats." + asStatName)
EndFunction

Float Function GetCharacterAV(String asCharacterName,String asAVName)
	Return JValue.solveFlt(_jMYC,"." + asCharacterName + ".Data.Stats.AV." + asAVName)
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
	GetLocalForm(asCharacterName,"VoiceType")
EndFunction

Bool Function SetCharacterVoiceType(String asCharacterName, VoiceType akVoiceType)
	;Debug.Trace("MYC: SetCharacterVoiceType(" + asCharacterName + ", " + akVoiceType + ")")
	ActorBase kTargetDummy = GetCharacterDummy(asCharacterName)
	kTargetDummy.SetVoiceType(akVoiceType)
	SetLocalForm(asCharacterName,"VoiceType",akVoiceType)
	Return True
EndFunction

Function SetCharacterClass(String asCharacterName, Class akClass)
	;Debug.Trace("MYC: SetCharacterClass(" + asCharacterName + ", " + akClass + ")")
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
	
	SetCharacterTracking(asCharacterName, False)
	
	Int i = 0
	ActorBase kTargetDummy = GetCharacterDummy(asCharacterName)
	Actor kTargetActor
	While i < _kLoadedCharacters.Length
		If _kLoadedCharacters[i]
			If _kLoadedCharacters[i].GetActorBase() == kTargetDummy
				kTargetActor = _kLoadedCharacters[i]
			EndIf
		EndIf
		i += 1
	EndWhile

	If !akHangoutRefAlias.GetReference()
		Int iHangoutIndex = JValue.solveInt(_jMYC,"." + asCharacterName + ".!LocalData.HangoutIndex")
		kHangoutRefAliases[iHangoutIndex].Clear()
		akHangoutRefAlias.ForceRefTo(kTargetActor)
		iHangoutIndex = kHangoutRefAliases.Find(akHangoutRefAlias)
		SetLocalInt(asCharacterName, "HangoutIndex", iHangoutIndex)
		;Debug.Trace("MYC: Set " + kTargetActor + " to HangoutIndex " + iHangoutIndex + " - " + akHangoutRefAlias)
	Else 
		Return False
	EndIf
	SetCharacterTracking(asCharacterName, True)
	Return True
EndFunction

Function SetCharacterTracking(String asCharacterName, Bool abEnable)
{Enable the quest objective for target character's refalias}
	Int iRefIndex = JValue.solveInt(_jMYC,"." + asCharacterName + ".!LocalData.HangoutIndex")
	If iRefIndex == -1 && abEnable
		PickHangout(asCharacterName)
	EndIf
	;Debug.Trace("MYC: SetCharacterTracking for " + asCharacterName + " at HangoutIndex " + iRefIndex + " to " + abEnable)
	SetObjectiveDisplayed(iRefIndex,False)
	SetObjectiveDisplayed(iRefIndex,abEnable)
EndFunction

Function RepairSaves()
{Update/Repair saved files, fixing all known bugs and setting them to the latest revision}
	Int i = 0
	While i < _sCharacterNames.Length
		i += 1
	EndWhile
EndFunction

Function EraseCharacter(String asCharacterName, Bool bConfirm = False)
	Debug.Trace("MYC: (" + asCharacterName + ") EraseCharacter called!")
	If !bConfirm
		Debug.Trace("MYC: (" + asCharacterName + ") EraseCharacter not confirmed, returning...")
		Return
	EndIf
	Debug.Trace("MYC: (" + asCharacterName + ") EraseCharacter was confirmed. Byebye, " + asCharacterName + "...")
;	Wait(0.1)
	Debug.Trace("MYC: Int jActorBaseMap = JMap.getObj(_jMYC,ActorBaseMap)")
	Int jActorBaseMap = JMap.getObj(_jMYC,"ActorBaseMap")
;	Wait(0.1)
	Debug.Trace("MYC: Int jDeadManWalking = JMap.getObj(_jMYC,asCharacterName)")
	Int jDeadManWalking = JMap.getObj(_jMYC,asCharacterName)
;	Wait(0.1)
	Debug.Trace("MYC: ActorBase kDeadActorBase = GetCharacterDummy(asCharacterName)")
	ActorBase kDeadActorBase = GetCharacterDummy(asCharacterName)
;	Wait(0.1)
	Debug.Trace("MYC: Actor kDeadActor = GetCharacterActorByName(asCharacterName)")
	Actor kDeadActor = GetCharacterActorByName(asCharacterName)
;	Wait(0.1)
	Debug.Trace("MYC: Int jCharacterList = JMap.getObj(_jMYC,CharacterList)")
	Int jCharacterList = JMap.getObj(_jMYC,"CharacterList")
;	Wait(0.1)
	Debug.Trace("MYC: Int iDeadManIndex = JArray.findStr(jCharacterList,asCharacterName)")
	Int iDeadManIndex = JArray.findStr(jCharacterList,asCharacterName)
;	Wait(0.1)
	Int iLCidx = _kLoadedCharacters.Find(kDeadActor)
	_kLoadedCharacters[iLCidx] = None
	Debug.Trace("MYC: SetLocalInt(asCharacterName,Enabled,0)")
	SetLocalInt(asCharacterName,"Enabled",0)
	Debug.Trace("MYC: SetLocalInt(asCharacterName,DoNotLoad,1)")
	SetLocalInt(asCharacterName,"DoNotLoad",1)
	Debug.Trace("MYC: SetLocalForm(asCharacterName,ActorBase,None)")
	SetLocalForm(asCharacterName,"ActorBase",None)
	Debug.Trace("MYC: JDB.writetoFile")
	JDB.writeToFile("Data/vMYC/jdb_preformdelete.json")
	Debug.Trace("MYC: SetLocalForm(asCharacterName,Actor,None)")
	SetLocalForm(asCharacterName,"Actor",None)
;	Wait(0.1)
	Debug.Trace("MYC: JMap.Clear(jDeadManWalking)")
	JMap.Clear(jDeadManWalking)
;	Wait(0.1)
	Debug.Trace("MYC: JArray.eraseIndex(jCharacterList,iDeadManIndex)")
	JArray.eraseIndex(jCharacterList,iDeadManIndex)
;	Wait(0.1)
	Debug.Trace("MYC: JFormMap.removeKey(jActorBaseMap,kDeadActorBase)")
	JFormMap.removeKey(jActorBaseMap,kDeadActorBase)
;	Wait(0.1)
	;kDeadActor.Disable(True)
	;Wait(2)
	kDeadActor.Delete()
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

Bool Function LoadCharacter(String sCharacterName)
	Debug.Trace("MYC: (" + sCharacterName + ") LoadCharacter called!")
	Int i = 0
	WaitMenuMode(RandomFloat(0.0,2.0)) ; Stagger startup slightly to be a little friendlier to the threading
	While _bBusyLoading
		;Debug.Trace("MYC: (" + sCharacterName + ") LoadCharacter is busy, waiting...")
		Wait(1)
	EndWhile
	_bBusyLoading = True
	
	;----Load Character data from _jMYC--------------

	Int jCharacterData
	
	If JValue.hasPath(_jMYC,"." + sCharacterName + ".Data")
		Debug.Trace("MYC: (" + sCharacterName + ") Loading character data from _jMYC...")
		jCharacterData = JValue.solveObj(_jMYC,"." + sCharacterName + ".Data")
		Debug.Trace("MYC: (" + sCharacterName + ") " + sCharacterName + " is a Level " + JValue.solveInt(jCharacterData,".Stats.Level") + " " + (JValue.solveForm(jCharacterData,".Race") as Race).GetName() + "!")	
	Else
		Debug.Trace("MYC: (" + sCharacterName + ") No _jMYC data for " + sCharacterName + "! BUT, we'll try loading a file by that name, just in case...")
		Int jCharacterFileData = JValue.ReadFromFile("Data/vMYC/" + sCharacterName + ".char.json")
		If jCharacterFileData
			Debug.Trace("MYC: (" + sCharacterName + ") Okay, weird, we apparently have data for this character after all and the character list is desynced.")
			Int jCharacterTopLevel = JMap.Object()
			JMap.SetObj(jCharacterTopLevel,"Data",jCharacterFileData)
			JMap.setObj(_jMYC,sCharacterName,jCharacterTopLevel)
			jCharacterData = JValue.solveObj(_jMYC,"." + sCharacterName + ".Data")
		Else
			Debug.Trace("MYC: (" + sCharacterName + ") Nope, no data, no file, no ticky, no shirty. ABORT! ABORT!")
			_bBusyLoading = False
			Return False
		EndIf
	EndIf
	
	Location kCustomLocation = JMap.getForm(jCharacterData,"Location") as Location
	If kCustomLocation
		AddCustomLocation(kCustomLocation)
	EndIf
	;----Load or create ActorBaseMap--------------
	
	Int jActorBaseMap
	If !JMap.hasKey(_jMYC,"ActorBaseMap")
		Debug.Trace("MYC: (" + sCharacterName + ") First character load on this save, creating ActorBaseMap...")
		jActorBaseMap = JFormMap.Object()
		JMap.setObj(_jMYC,"ActorBaseMap",jActorBaseMap)
	Else
		jActorBaseMap = JMap.getObj(_jMYC,"ActorBaseMap")
	EndIf

	;----Check if this character is already loaded--------------
	
	Debug.Trace("MYC: (" + sCharacterName + ") Finding ActorBase for " + sCharacterName + "...")	
	ActorBase DummyActorBase = GetLocalForm(sCharacterName,"ActorBase") as ActorBase
	Actor PlayerDupe = GetLocalForm(sCharacterName,"Actor") as Actor
	
	If PlayerDupe ; Already been loaded
		Debug.Trace("MYC: (" + sCharacterName + ") This character is already assigned ActorBase " + DummyActorBase + " and is currently Actor " + PlayerDupe)
		SetLocalInt(sCharacterName,"Enabled", 1)
		PlayerDupe.RemoveallItems()
		;PlayerDupe.Enable()
		Wait(1.0)
		(PlayerDupe as vMYC_CharacterDummyActorScript).DoUpkeep()
		;_bBusyLoading = False
		;Return True
	EndIf
	
	;----Get ActorBase for character--------------
	
	If !DummyActorBase ; Not loaded on this save session
		Debug.Trace("MYC: (" + sCharacterName + ") No saved ActorBase found, getting a new one...")
		DummyActorBase = GetFreeActorBase(JMap.getInt(jCharacterData,"Sex"))
		If !DummyActorBase ; Not loaded on this save session
			Debug.Trace("MYC: (" + sCharacterName + ") Could not find available ActorBase for " + sCharacterName + "!")
			_bBusyLoading = False
			Return False
		EndIf
	EndIf
	Debug.Trace("MYC: (" + sCharacterName + ") ActorBase will use " + DummyActorBase + "!")
	SetLocalForm(sCharacterName,"ActorBase",DummyActorBase)
	
	JFormMap.setStr(jActorBaseMap,DummyActorBase,sCharacterName) ; Assign character name to ActorBase as a sort of reverse lookup
	
	;----Load Actor and begin setting up the ActorBase--------------
	
	DummyActorBase.SetEssential(True)
	DummyActorBase.SetName(sCharacterName)
	PlayerDupe = GetCharacterActor(DummyActorBase)
	If !PlayerDupe
		PlayerDupe = LoadPoint.PlaceAtMe(DummyActorBase, abInitiallyDisabled = True) as Actor
	EndIf
	Debug.Trace("MYC: (" + sCharacterName + ") " + sCharacterName + " is actor " + PlayerDupe)
	SetLocalForm(sCharacterName,"Actor",PlayerDupe)
	;Debug.Trace("MYC: (" + sCharacterName + ") Made it through SetLocalForm...")
	vMYC_CharacterDummyActorScript CharacterDummy = PlayerDupe as vMYC_CharacterDummyActorScript
	CharacterDummy.NeedRefresh = True
	SetLocalForm(sCharacterName,"Script",CharacterDummy)

	;Wait(0.5) ; Don't remove this, the following statement locks up without it, god knows why
	;Debug.Trace("MYC: (" + sCharacterName + ") About to set CharacterDummy.CharacterName property...")
	CharacterDummy.CharacterName = JMap.getStr(jCharacterData,"Name")

	;Debug.Trace("MYC: (" + sCharacterName + ") Stored name is " + CharacterDummy.CharacterName + "!")

	CharacterDummy.CharacterRace = JValue.solveForm(jCharacterData,".Race") as Race
	;Debug.Trace("MYC: (" + sCharacterName + ") Stored race is " + CharacterDummy.CharacterRace + "!")
	
	;Debug.Trace("MYC: (" + sCharacterName + ") Setting voicetype to " + JValue.solveForm(jCharacterData,".Race") as VoiceType)
	DummyActorBase.SetVoiceType(JValue.solveForm(jCharacterData,".Race") as VoiceType)
	CharacterDummy.DoInit()
	_bBusyLoading = False
	
	;----Load and equip armor--------------	
	
	While _bBusyEquipment
		Wait(1.0)
	EndWhile
	_bBusyEquipment = True
	;Debug.Trace("MYC: (" + sCharacterName + ") Setting equipment...")
	
	Int jCharacterArmor = JValue.solveObj(jCharacterData,".Equipment.Armor")
	Int jCharacterArmorInfo = JValue.solveObj(jCharacterData,".Equipment.ArmorInfo")
	
	i = JArray.Count(jCharacterArmorInfo)
	While i > 0
		i -= 1
		Int jArmor = JArray.GetObj(jCharacterArmorInfo,i)
		Form kItem = JMap.GetForm(jArmor,"Form")
		If kItem
			PlayerDupe.AddItem(kItem)
			PlayerDupe.EquipItemEx(kItem,0,True)
			Int h = (kItem as Armor).GetSlotMask()
			;Debug.Trace("MYC: (" + sCharacterName + ") setting up " + kItem.GetName() + "...")
			Enchantment kItemEnchantment = JMap.GetForm(jArmor,"Enchantment") as Enchantment
			If kItemEnchantment && (kItem as Armor).GetEnchantment() != kItemEnchantment
				;Debug.Trace("MYC: (" + sCharacterName + ") " + kItem.GetName() + " is enchanted!")
				WornObject.SetEnchantment(PlayerDupe,1,h,kItemEnchantment,JMap.GetFlt(jArmor,"ItemMaxCharge"))
			EndIf
			If JMap.GetInt(jArmor,"IsCustom")
				String sDisplayName = JMap.GetStr(jArmor,"DisplayName")
				;Debug.Trace("MYC: (" + sCharacterName + ") " + kItem.GetName() + " is customized item " + sDisplayName + "!")
				WornObject.SetItemHealthPercent(PlayerDupe,1,h,JMap.GetFlt(jArmor,"ItemHealthPercent"))
				WornObject.SetItemMaxCharge(PlayerDupe,1,h,JMap.GetFlt(jArmor,"ItemMaxCharge"))
				If sDisplayName ; Will be blank if player hasn't renamed the item
					WornObject.SetDisplayName(PlayerDupe,1,h,sDisplayName)
				EndIf

				Float[] fMagnitudes = New Float[4]
				Int[] iDurations = New Int[4]
				Int[] iAreas = New Int[4]
				MagicEffect[] kMagicEffects = New MagicEffect[4]
				
				If JValue.solveInt(jArmor,".Enchantment.IsCustom")
					Int iNumEffects = JValue.SolveInt(jArmor,".Enchantment.NumEffects")
					;Debug.Trace("MYC: (" + sCharacterName + ") " + sDisplayName + " has a customized enchantment with " + inumEffects + " magiceffects!")				
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
					WornObject.CreateEnchantment(PlayerDupe, 1, h, JMap.GetFlt(jArmor,"ItemMaxCharge"), kMagicEffects, fMagnitudes, iAreas, iDurations)
				EndIf
			EndIf
		EndIf
	EndWhile

	_bBusyEquipment = False
	;----Populate inventory--------------
	
	Form kEquippedAmmo
	
	;Debug.Trace("MYC: (" + sCharacterName + ") Creating dummy's inventory...")
	Int jCharacterInventory = JValue.solveObj(jCharacterData,".Inventory")
	i = JFormMap.Count(jCharacterInventory)
	Int jInvForms = JFormMap.allKeys(jCharacterInventory)
	Int jInvCounts = JFormMap.allValues(jCharacterInventory)
	Int iLastGoldValue = 0
	While i > 0
		i -= 1
		Form kItem = JArray.getForm(jInvForms,i)
		If kItem
			Int iType = kItem.GetType()
			If iType == 42 ; Ammo
				PlayerDupe.AddItem(kItem,JArray.getInt(jInvCounts,i))
				;Debug.Trace("MYC: (" + sCharacterName + ") Ammo " + kItem.GetName() + " value is " + kItem.GetGoldValue() + ", iLastGoldValue is " + iLastGoldValue)
				If kItem.GetGoldValue() > iLastGoldValue
					PlayerDupe.EquipItem(kItem)
					kEquippedAmmo = kItem
					;Debug.Trace("MYC: (" + sCharacterName + ") Ammo equipped: " + kItem.GetName())
					iLastGoldValue = kItem.GetGoldValue()
				EndIf
			EndIf
		EndIf
	EndWhile
	
	;----Add spells--------------	

	SetAllowedSpells(sCharacterName)

	;;Debug.Trace("MYC: (" + sCharacterName + ") Setting the dummy's actor values...")
	;i = 0
	;While i < _sAVNames.Length
		;If _sAVNames[i]
			;Float fAV = GetFloatValue(DummyActorBase,sKey + "Stat.AV." + _sAVNames[i])
			;PlayerDupe.ForceActorValue(_sAVNames[i],fAV)
			;;Debug.Trace("MYC: (" + sCharacterName + ") Set dummy's " + _sAVNames[i] + " to " + fAV)
		;EndIf
		;i += 1
	;EndWhile

	PlayerDupe.SetAV("Confidence",3)
	PlayerDupe.SetAV("Assistance",2)
	;PlayerDupe.SetAV("Confidence",3)

	PlayerDupe.Enable(True)
	Wait(1)
	
	;----Load and equip weapons/hand gear--------------	
	While _bBusyEquipment
		Wait(1.0)
	EndWhile
	_bBusyEquipment = True
	;Debug.Trace("MYC: (" + sCharacterName + ") Setting equipped weapons...")
	SetLocalInt(sCharacterName,"BowEquipped",0)
	;SetLocalInt(sCharacterName,"SpellEquipped",0)
	Int iHand = 1 ; start with right
	While iHand >= 0
		Bool bTwoHanded = False
		String sHand = "Right"
		If iHand == 0
			sHand = "Left"
		EndIf
		Int jItem = JValue.solveObj(jCharacterData,".Equipment." + sHand)
		Form kItem = JMap.getForm(jItem,"Form")
		If kItem as Weapon
			Int iWeaponType = (kItem as Weapon).GetWeaponType()
			If iWeaponType == 5 || iWeaponType == 6 || iWeaponType == 7 || iWeaponType == 9 ; Greatswords, axes, bows or crossbows
				bTwoHanded = True
			EndIf
			If iWeaponType == 7
				SetLocalInt(sCharacterName,"BowEquipped",1)
			EndIf
			;Debug.Trace("MYC: (" + sCharacterName + ") adding " + kItem.GetName() +"...")
			If !(bTwoHanded && iHand == 0) 
				PlayerDupe.AddItem(kItem)
			EndIf
			;Wait(1)
			;PlayerDupe.DrawWeapon()
			;Wait(1)
			;WaitMenuMode(0.1)
			;Debug.Trace("MYC: (" + sCharacterName + ") equipping " + kItem.GetName() +"...")
			If iHand == 1 ; Equip in proper hand and prevent removal
				PlayerDupe.EquipItemEx(kItem,1,True) ; Right
			ElseIf !bTwoHanded
				PlayerDupe.EquipItemEx(kItem,2,True) ; Left
			EndIf
			;Wait(1)
			;PlayerDupe.DrawWeapon()
			;Wait(1)
			;PlayerDupe.EquipItemEx(kItem)
			;Debug.Trace("MYC: (" + sCharacterName + ") " + kItem.GetName() + " equipped in " + sHand + " hand.")

			If JMap.getInt(jItem,"IsCustom")
				String sDisplayName = JMap.getStr(jItem,"DisplayName")
				;Debug.Trace("MYC: (" + sCharacterName + ") " + kItem.GetName() + " is customized item " + sDisplayName + "!")
				;Debug.Trace("MYC: (" + sCharacterName + ") WornObject.SetItemHealthPercent(PlayerDupe," + iHand + ",0," + JMap.getFlt(jItem,"ItemHealthPercent"))
				WornObject.SetItemHealthPercent(PlayerDupe,iHand,0,JMap.getFlt(jItem,"ItemHealthPercent"))
				;Debug.Trace("MYC: (" + sCharacterName + ") WornObject.SetItemMaxCharge(PlayerDupe," + iHand + ",0," + JMap.getFlt(jItem,"ItemMaxCharge"))
				WornObject.SetItemMaxCharge(PlayerDupe,iHand,0,JMap.getFlt(jItem,"ItemMaxCharge"))
				If sDisplayName ; Will be blank if player hasn't renamed the item
					;Debug.Trace("MYC: (" + sCharacterName + ") WornObject.SetDisplayName(PlayerDupe," + iHand + ",0," + sDisplayName)
					WornObject.SetDisplayName(PlayerDupe,iHand,0,sDisplayName)
				EndIf

				Float[] fMagnitudes = New Float[4]
				Int[] iDurations = New Int[4]
				Int[] iAreas = New Int[4]
				MagicEffect[] kMagicEffects = New MagicEffect[4]
				;Wait(1)
				If JValue.solveInt(jItem,".Enchantment.IsCustom")
					Int iNumEffects = JValue.solveInt(jItem,".Enchantment.NumEffects")
					;Debug.Trace("MYC: (" + sCharacterName + ") " + sDisplayName + " has a customized enchantment with " + inumEffects + " magiceffects!")
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
					;Debug.Trace("MYC: (" + sCharacterName + ") " + sDisplayName + " creating custom enchantment...")
					WornObject.CreateEnchantment(PlayerDupe,iHand,0,JMap.getFlt(jItem,"ItemMaxCharge"), kMagicEffects, fMagnitudes, iAreas, iDurations)
					;Debug.Trace("MYC: (" + sCharacterName + ") " + sDisplayName + " done!")
				EndIf
			EndIf
			If iHand == 1 ; Equip in proper hand and allow removal
				PlayerDupe.EquipItemEx(kItem,1) ;,True) ; Right
			ElseIf !bTwoHanded
				PlayerDupe.EquipItemEx(kItem,2,True) ;Left, and prevent removal because otherwise the game immediately unequips the left hand
			EndIf
		ElseIf kItem ; Item is not a Weapon, probably a spell or shield. Just equip it.
			If iHand == 1 ; Equip in proper hand and prevent removal
				PlayerDupe.EquipItemEx(kItem,1) ;,True) ; Right
			ElseIf !bTwoHanded
				PlayerDupe.EquipItemEx(kItem,2) ;,True) ; Left
			EndIf
		EndIf
		;If iHand == 1 ; Equip in proper hand and prevent removal
			;PlayerDupe.UnEquipItem(kItem)
			;PlayerDupe.EquipItemEx(kItem,1,True) ; Right
		;ElseIf !bTwoHanded
			;PlayerDupe.UnEquipItem(kItem)
			;PlayerDupe.EquipItemEx(kItem,2,True) ; Left
		;EndIf
		iHand -= 1
		If bTwoHanded ; skip left hand
			;Debug.Trace("MYC: (" + sCharacterName + ") two-handed weapon, so skipping further processing...")				
			iHand -= 1
		EndIf
	EndWhile
	;Debug.Trace("MYC: (" + sCharacterName + ") Equipping power!")
	PlayerDupe.EquipItemEx(JValue.solveForm(jCharacterData,".Equipment.Voice"),0)

	If GetLocalInt(sCharacterName,"BowEquipped") == 0
		PlayerDupe.UnEquipItem(kEquippedAmmo)
	EndIf
	
	_bBusyEquipment = False
	
	Int idx = _kLoadedCharacters.Find(None)
	_kLoadedCharacters[idx] = PlayerDupe
	SetLocalInt(sCharacterName,"Enabled", 1)
	;Debug.Trace("MYC: (" + sCharacterName + ") Enabling dummy...")
	
	SetLocalInt(sCharacterName,"HangoutIndexDefault",-1)
	SetLocalInt(sCharacterName,"HangoutIndex",-1)
	PickHangout(sCharacterName)
	;CharacterDummy.DoUpkeep()
	;SetCharacterTracking(sCharacterName,True)
	_bBusyLoading = False
	Return True
EndFunction

Function PickHangout(String asCharacterName)
	String[] sSpawnPoints = New String[32]
	Int jSpawnPoints = GetCharacterObj(asCharacterName,"SpawnPoints")
	Int i = 0
	;Debug.Trace("MYC: (" + asCharacterName + ") Setting Spawnpoint to one of " + JArray.Count(jSpawnPoints))
	While i < JArray.Count(jSpawnPoints)
		sSpawnPoints[i] = JArray.getStr(jSpawnPoints,i)
		;Debug.Trace("MYC: (" + asCharacterName + ") Spawnpoint " + i + " is " + sSpawnPoints[i])
		i += 1
	EndWhile
	ReferenceAlias kDummyRef = GetAvailableReference(sSpawnPoints)
	Int iHangoutIndex = -1
	If kDummyRef
		kDummyRef.ForceRefTo(GetCharacterActorByName(asCharacterName))
		iHangoutIndex = kHangoutRefAliases.Find(kDummyRef)
	EndIf
	SetLocalInt(asCharacterName,"HangoutIndexDefault",iHangoutIndex)
	SetLocalInt(asCharacterName,"HangoutIndex",iHangoutIndex)

	;Debug.Trace("MYC: (" + asCharacterName + ") Set to " + kDummyRef)
EndFunction

Int Function CreateLocalDataIfMissing(String asCharacterName)

	Int jCharacter = JMap.getObj(_jMYC,asCharacterName)
	Int jCharLocalData = JMap.getObj(jCharacter,"!LocalData")
	If jCharLocalData
		Return jCharLocalData
	EndIf
	;Debug.Trace("MYC: (" + asCharacterName + ") First local data access, creating LocalData key!")
	jCharLocalData = JMap.Object()
	JMap.setObj(jCharacter,"!LocalData",jCharLocalData)
	Return jCharLocalData
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
{Return available ReferenceAlias based on the character's stored spawnpoints}
	ReferenceAlias kResult
	String[] sCommonCities = New String[5]
	sCommonCities[0] = "Dawnstar"
	sCommonCities[1] = "Markarth"
	sCommonCities[2] = "Morthal"
	sCommonCities[3] = "Falkreath"
	sCommonCities[4] = "Whiterun"
	
	ReferenceAlias[] kCityAliases = New ReferenceAlias[5]
	kCityAliases[0] = alias_DawnstarCharacter
	kCityAliases[1] = alias_MarkarthCharacter
	kCityAliases[2] = alias_MorthalCharacter
	kCityAliases[3] = alias_FalkreathCharacter
	kCityAliases[4] = alias_WhiterunCharacter
	
	Int iCityPick = RandomInt(0,4)

	;FIXME: There is no spawnpoint/package for the Dark Brotherhood, but there probably should be.
	
	If sSpawnPoints.Find("Mage") > -1 && !alias_MageCharacter.GetReference()
		Return alias_MageCharacter
	ElseIf sSpawnPoints.Find("Blade") > -1 && !alias_BladeCharacter.GetReference()
		Return alias_BladeCharacter
	ElseIf sSpawnPoints.Find("Greybeard") > -1 && !alias_GreyBeardCharacter.GetReference()
		Return alias_GreyBeardCharacter
	ElseIf sSpawnPoints.Find("Imperial") > -1 && !alias_ImperialCharacter.GetReference()
		Return alias_ImperialCharacter
	ElseIf sSpawnPoints.Find("Stormcloak") > -1 && !alias_StormcloakCharacter.GetReference()
		Return alias_StormcloakCharacter
	ElseIf sSpawnPoints.Find("Thief") > -1 && !alias_ThiefCharacter.GetReference()
		Return alias_ThiefCharacter
	ElseIf sSpawnPoints.Find("Companion") > -1 && !alias_CompanionCharacter.GetReference()
		Return alias_CompanionCharacter
	ElseIf sSpawnPoints.Find("Bard") > -1 && !alias_BardCharacter.GetReference()
		Return alias_BardCharacter
	ElseIf sSpawnPoints.Find("Orc") > -1 && !alias_OrcCharacter.GetReference()
		Return alias_OrcCharacter
	ElseIf sSpawnPoints.Find("Caravan") > -1 && !alias_CaravanCharacter.GetReference()
		Return alias_CaravanCharacter
	ElseIf sSpawnPoints.Find(sCommonCities[iCityPick]) > -1 && !kCityAliases[iCityPick].GetReference() ; Try a random city the character is thane of
		Return kCityAliases[iCityPick]
	Else ; Try all cities in order
		Int i = 0
		While i < kCityAliases.Length 
			If sSpawnPoints.Find(sCommonCities[i]) > -1 && !kCityAliases[i].GetReference()
				Return kCityAliases[i]
			EndIf
			i += 1
		EndWhile
		;If we get this far, character isn't thane of anything or all character slots are full
		iCityPick = RandomInt(0,4)
		If !kCityAliases[iCityPick].GetReference() ; Try a random city that's unfilled, regardless of thane status
			Return kCityAliases[iCityPick]
		EndIf
		While i > 0 ; Pick a city in reverse order regardless of thane-ness
			i -= 1
			If !kCityAliases[i].GetReference()
				Return kCityAliases[i]
			EndIf
		EndWhile
	EndIf
	;All slots must be full
	Return None
EndFunction

Function SaveCharacter(String sCharacterName)
	

	;Debug.Trace("MYC: Finding dummy for " + sCharacterName + "...")	
	ActorBase DummyActorBase = GetCharacterDummy(sCharacterName)

EndFunction

Function SerializeEquipment(Form kItem, Int jEquipmentInfo, Int iHand = 1, Int h = 0)
{Fills the JMap jEquipmentInfo with all info from Form kItem}
	JMap.SetForm(jEquipmentInfo,"Form",kItem)

	Bool isWeapon = False 
	Bool isEnchantable = False
	Bool isTwoHanded = False
	Enchantment kItemEnchantment

	;Debug.Trace("MYC: Serializing " + kItem.GetName() + "...")
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
		;Debug.Trace("MYC: " + kItem.GetName() + " has enchantment " + kItemEnchantment.GetFormID() + ", " + kItemEnchantment.GetName())
		JMap.SetForm(jEquipmentEnchantmentInfo,"Form",kItemEnchantment)
		JMap.SetInt(jEquipmentEnchantmentInfo,"IsCustom",0)
	EndIf
	String sItemDisplayName = WornObject.GetDisplayName(PlayerREF,iHand,h)
	sItemDisplayName = StringUtil.SubString(sItemDisplayName,0,StringUtil.Find(sItemDisplayName,"(") - 1) ; Strip " (Legendary)"
	kItemEnchantment = WornObject.GetEnchantment(PlayerREF,iHand,h)
	If sItemDisplayName || kItemEnchantment
		;Debug.Trace("MYC: " + kItem + " is enchanted/forged item " + sItemDisplayName)
		JMap.SetInt(jEquipmentInfo,"IsCustom",1)
		JMap.SetFlt(jEquipmentInfo,"ItemHealthPercent",WornObject.GetItemHealthPercent(PlayerREF,iHand,h))
		JMap.SetFlt(jEquipmentInfo,"ItemMaxCharge",WornObject.GetItemMaxCharge(PlayerREF,iHand,h))
		JMap.SetStr(jEquipmentInfo,"DisplayName",sItemDisplayName)
		kItemEnchantment = WornObject.GetEnchantment(PlayerREF,iHand,h)
		If kItemEnchantment
			JMap.SetForm(jEquipmentEnchantmentInfo,"Form",kItemEnchantment)
			JMap.SetInt(jEquipmentEnchantmentInfo,"IsCustom",1)
			Int iNumEffects = kItemEnchantment.GetNumEffects()
			JMap.SetInt(jEquipmentEnchantmentInfo,"NumEffects",iNumEffects)
			Int jEffectsArray = JArray.Object()
			Int j = 0
			While j < iNumEffects
				Int jEffectsInfo = JMap.Object()
				;String sEquEnchKey = sKey + "Equipment." + iItemIndex + ".Enchantment.Effects." + j + "."
				JMap.SetFlt(jEffectsInfo, "Magnitude", kItemEnchantment.GetNthEffectMagnitude(j))
				JMap.SetFlt(jEffectsInfo, "Area", kItemEnchantment.GetNthEffectArea(j))
				JMap.SetFlt(jEffectsInfo, "Duration", kItemEnchantment.GetNthEffectDuration(j))
				JMap.SetForm(jEffectsInfo,"MagicEffect", kItemEnchantment.GetNthEffectMagicEffect(j))
				JArray.AddObj(jEffectsArray,jEffectsInfo)
				j += 1
			EndWhile
			JMap.SetObj(jEquipmentEnchantmentInfo,"Effects",jEffectsArray)
		EndIf
	Else
		JMap.SetInt(jEquipmentInfo,"IsCustom",0)
	EndIf
	If !(iHand == 0 && IsTwoHanded) && kItem ; exclude left-hand iteration of two-handed weapons
		kItem.SendModEvent("vMYC_EquipmentSaved","",iHand)
	EndIf
	;Debug.Trace("MYC: Finished serializing " + kItem.GetName() + ", JMap count is " + JMap.Count(jEquipmentInfo))
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
			;Debug.Trace("MYC: " + sPlayerName + " is wearing " + WornForm + ", " + WornForm.GetName() + " on slot " + h)
			If JArray.FindForm(jPlayerArmorList,WornForm) < 0
				JArray.AddForm(jPlayerArmorList,WornForm)
				Int iArmorIndex = JArray.FindForm(jPlayerArmorList,WornForm)
				If WornForm as Armor && iArmorIndex > -1
					;Debug.Trace("MYC: Added " + WornForm.GetName())
					
					Int jPlayerArmorInfo = JMap.Object()
					
					JArray.AddObj(jPlayerArmorInfoList,jPlayerArmorInfo)

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

	Int iSpellCount = PlayerREF.GetSpellCount()
	Int iAddedCount = 0
	Int i = 0
	Bool bAddItem = False
	;Debug.Trace("MYC: " + sPlayerName + " knows " + iSpellCount + " spells.")
	While i < iSpellCount
		bAddItem = False
		Spell kSpell = PlayerREF.GetNthSpell(i)
		If kSpell
			bAddItem = True
			Int iSpellID = kSpell.GetFormID()
			;;Debug.Trace("MYC: " + sPlayerName + " knows the spell " + kSpell + ", " + kSpell.GetName())
			If iSpellID > 0x05000000 || iSpellID < 0 ; Spell is NOT part of Skyrim, Dawnguard, Hearthfires, or Dragonborn
				bAddItem = False
				;Debug.Trace("MYC: " + kSpell + " is a mod-added item!")
			EndIf
			If bAddItem
				;vMYC_PlayerFormlist.AddForm(kSpell)
				JArray.AddForm(jPlayerSpells,kSpell)
				iAddedCount += 1
				If iAddedCount % 2 == 0
					kSpell.SendModEvent("vMYC_SpellSaved")
				EndIf
			EndIf
		EndIf
		i += 1
	EndWhile
	SendModEvent("vMYC_SpellsSaveEnd",iAddedCount)
	;Debug.Trace("MYC: Saved " + iAddedCount + " spells for " + sPlayerName + ".")
	
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
	JValue.Retain(jInvForms)
	JValue.Retain(jInvCounts)
	Int jPlayerInventory = JFormMap.Object()
	JMap.SetObj(jPlayerData,"Inventory",jPlayerInventory)
	Bool bAddItem = False
	
	Int iItemCount = JArray.Count(jInvForms)
	Int i = 0
	Debug.Trace("MYC: " + sPlayerName + " has " + iItemCount + " items.")
	Int iAddedCount = 0
	While i < iItemCount
		bAddItem = True
		Form kItem = JArray.getForm(jInvForms,i)

		Int iType = kItem.GetType()
		Debug.Trace("MYC: " + sPlayerName + " has " + kItem)
		
		Int iItemID = kItem.GetFormID()
		If iItemID > 0x05000000 || iItemID < 0 && !(iItemID > 0xFF000000 && iItemID < 0xFFFFFFFF) 
			; Item is NOT part of Skyrim, Dawnguard, Hearthfires, or Dragonborn and is not a custom item
			Debug.Trace("MYC: " + kItem + " is a mod-added item!")
			;bAddItem = False
		ElseIf (iItemID > 0xFF000000 && iItemID < 0xFFFFFFFF) 
			; This is a custom-made item
			Debug.Trace("MYC: " + kItem + " is a customized/forged/mixed item!")
			bAddItem = False
		EndIf
		If kItem as ObjectReference
			Debug.Trace("MYC: " + kItem + " is an ObjectReference!")
		EndIf
		If bAddItem
			JFormMap.SetInt(jPlayerInventory,kItem,JArray.getInt(jInvCounts,i))
			kItem.SendModEvent("vMYC_ItemSaved")
			iAddedCount += 1
		EndIf
		i += 1
	EndWhile
	Debug.Trace("MYC: Saved " + iAddedCount + " items for " + sPlayerName + ".")
	SendModEvent("vMYC_InventorySaveEnd",iAddedCount)
	JValue.WriteTofile(jPlayerInventory,"Data/vMYC/_jPlayerInventory.json")
	_bSavedInventory = True
	JValue.Release(jInvForms)
	JValue.Release(jInvCounts)
EndEvent

Event OnSaveCurrentPlayerPerks(string eventName, string strArg, float numArg, Form sender)
	If sender != Self
		Return
	EndIf
	_bSavedPerks = False

	Int jPlayerData = strArg as Int
	String sPlayerName = PlayerREF.GetActorBase().GetName()

	SendModEvent("vMYC_PerksSaveBegin")
	JMap.SetObj(jPlayerData,"Perks",JArray.Object())

	Int i = vMYC_PerkList.GetSize()
	Int iAddedCount = 0
	While i > 0
		i -= 1
		Perk kPerk = vMYC_PerkList.GetAt(i) as Perk
		If PlayerREF.HasPerk(kPerk)
			;Debug.Trace("MYC: Player has Perk " + kPerk.GetName())
			iAddedCount += 1
			If iAddedCount % 2 == 0
				kPerk.SendModEvent("vMYC_PerkSaved")
			EndIf
			JArray.AddForm(JValue.SolveObj(jPlayerData,".Perks"),kPerk)
		EndIf
	EndWhile
	SendModEvent("vMYC_PerksSaveEnd",iAddedCount)
	
	_bSavedPerks = True
EndEvent

Function SaveCurrentPlayer(Bool bSaveEquipment = True, Bool SaveCustomEquipment = True, Bool bSaveInventory = True, Bool bSaveFullInventory = True, Bool bSavePluginItems = False, Bool bForceSave = False)
	_bSavedPerks = False
	_bSavedSpells = False
	_bSavedEquipment = False
	_bSavedInventory = False

	Form[] PlayerEquipment = New Form[64]
	Enchantment[] PlayerEnchantments = New Enchantment[64]

	ActorBase PlayerBase = PlayerREF.GetActorBase()	
	ActorBase DummyActorBase = GetFreeActorBase(PlayerBase.GetSex())

	String sPlayerName = PlayerBase.GetName()
	If !sPlayerName
		sPlayerName = PlayerREF.GetActorBase().GetName()
		;Debug.Trace("MYC: Name from GetActorBase: " + sPlayerName)
	EndIf
	If !sPlayerName
		sPlayerName = PlayerREF.GetBaseObject().GetName()
		;Debug.Trace("MYC: Name from GetBaseObject: " + sPlayerName)		
	EndIf
	
	Int jCharacterNames = JMap.allKeys(JValue.solveObj(_jMYC,".CharacterList"))
	
	If JArray.findStr(jCharacterNames,sPlayerName) > -1
		Debug.Trace("MYC: Player " + sPlayerName + " is already saved!")
		If bForceSave
			Debug.Trace("MYC: bForceSave is True, so saving anyway...")
		Else
			Return
		EndIf
	EndIf
	
	;Debug.Trace("MYC: Getting basic data from " + sPlayerName + "...")
	
	;Debug.Trace("MYC:            Race: " + PlayerREF.GetRace() + ", " + PlayerREF.GetRace().GetName())
	;Debug.Trace("MYC:          Weight: " + PlayerREF.GetWeight() + ", " + PlayerREF.GetActorBase().GetWeight())
	;Debug.Trace("MYC:          Height: " + PlayerREF.GetHeight() + ", " + PlayerREF.GetActorBase().GetHeight())

	Int iFree = 0
	While iFree < _sCharacterNames.Length && _sCharacterNames[iFree] != ""
		iFree += 1
	EndWhile

	_sCharacterNames[iFree] = sPlayerName
	Debug.Notification("Saving " + sPlayerName + "'s data, this may take a minute...")

	Int jPlayerData = JMap.Object()
	JValue.Retain(jPlayerData)
	
	JMap.SetStr(jPlayerData,"Name",sPlayerName)
	JMap.SetInt(jPlayerData,"Sex",PlayerREF.GetActorBase().GetSex())
	JMap.SetForm(jPlayerData,"Race",PlayerREF.GetActorBase().GetRace())
	JMap.SetForm(jPlayerData,"Location",kLastPlayerLocation.GetLocation())
	If kLastPlayerLocation.GetLocation()
		JMap.setStr(jPlayerData,"LocationName",kLastPlayerLocation.GetLocation().GetName())
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
	JMap.setStr(jMetaInfo,"RaceText",PlayerREF.GetActorBase().GetRace())
	JMap.setFlt(jMetaInfo,"Playtime",GetRealHoursPassed())
	JMap.setInt(jMetaInfo,"SerializationVersion",2)

	JMap.setObj(jPlayerData,"!MYC",jMetaInfo)
	
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
			;Debug.Trace("MYC: " + StringUtil.SubString(sBlank,0,StringUtil.GetLength(sBlank) - StringUtil.GetLength(_sAVNames[i])) + _sAVNames[i] + ":, " + fPlayerBaseAVs[i])
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
	
	JMap.SetForm(jPlayerData,"VoiceType",None)

	;-----==== None of this is needed anymore thanks to the new chargen 
	;  function, but it doesn't take long to collect so why not ====-----
	
	Int jPlayerAppearance = JMap.Object()
	JMap.SetObj(jPlayerData,"Appearance",jPlayerAppearance)

	ColorForm kHairColor = PlayerBase.GetHairColor()
	JMap.SetForm(jPlayerAppearance,"Haircolor",kHairColor)
	int jHairColor = JValue.objectFromPrototype("{ \"r\": " + kHairColor.GetRed() + ", \"g\": " + kHairColor.GetGreen() + ", \"b\": " + kHairColor.GetBlue() + ", \"h\": " + kHairColor.GetHue() + ", \"s\": " + kHairColor.GetSaturation() + ", \"v\": " + kHairColor.GetValue() + " }")
	;Debug.Trace("(" + CharacterName + "/Actor) kHairColor (Post-LoadCharacter) is R:" + kHairColor.GetRed() + " G:" + kHairColor.GetGreen() + " B:" + kHairColor.GetBlue() + " H:" + kHairColor.GetHue() + " S:" + kHairColor.GetSaturation() + " V:" + kHairColor.GetValue())
	JMap.SetObj(jPlayerAppearance,"HaircolorDetails",jHairColor)
	JMap.SetForm(jPlayerAppearance,"Skin",PlayerBase.GetSkin())
	JMap.SetForm(jPlayerAppearance,"SkinFar",PlayerBase.GetSkinFar())
	
	Int jPlayerHeadparts = JArray.Object()
	JMap.SetObj(jPlayerAppearance,"Headparts",jPlayerHeadparts)
	
	i = 0
	While i < PlayerBase.GetNumHeadParts()
		HeadPart kHeadPart = PlayerBase.GetNthHeadPart(i)
		JArray.AddForm(jPlayerHeadparts,kHeadPart)
		Int j = 0
		While j < kHeadPart.GetNumExtraParts()
			HeadPart kExtraHeadPart = kHeadPart.GetNthExtraPart(j)
			JArray.Addform(jPlayerHeadparts,kExtraHeadPart)
			j += 1
		EndWhile
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
			;;Debug.Trace("MYC: PlayerFaceTexture path " + i + " is " + vMYC_PlayerFaceTexture.GetNthTexturePath(i))
			JArray.AddStr(jPlayerFaceTexturePaths,vMYC_PlayerFaceTexture.GetNthTexturePath(i))
			i += 1
		EndWhile
	EndIf
	
	Int jPlayerFacePresets = JArray.Object()
	JMap.SetObj(jPlayerFace,"Presets",jPlayerFacePresets)

	i = 0
	While i < PlayerBase.GetNumHeadParts()
		;;Debug.Trace("MYC: Copying face preset " + i)
		JArray.AddInt(jPlayerFacePresets,PlayerBase.GetFacePreset(i))
		i += 1
	EndWhile
	
	Int jPlayerFaceMorphs = JArray.Object()
	JMap.SetObj(jPlayerFace,"Morphs",jPlayerFaceMorphs)
	i = 0
	While i < PlayerBase.GetNumHeadParts() * 4
		Float fFaceMorph = PlayerBase.GetFaceMorph(i)
		JArray.AddFlt(jPlayerFaceMorphs,fFaceMorph)
		i += 1
	EndWhile
	
	If SKSE.GetPluginVersion("CharGen") > 0
		CharGen.SaveCharacter(sPlayerName)
	EndIf
	
	;Old head export function
	;Debug.MessageBox("Chargen Version is " + SKSE.GetPluginVersion("CharGen"))
	;If SKSE.GetPluginVersion("CharGen") > 0
		;;Debug.Trace("MYC: Exporting head with CharGen...")
		;UI.InvokeString("HUD Menu", "_global.skse.plugins.CharGen.ExportHead", "Data\\Textures\\actors\\character\\FaceGenData\\FaceTint\\vMYC_MeetYourCharacters.esp\\" + sPlayerName)
		;;Debug.Trace("MYC: Done!")
	;Else
	;	Debug.MessageBox("No CharGen, MAN!")
	;EndIf

	
	While !_bSavedEquipment || !_bSavedPerks || !_bSavedInventory || !_bSavedSpells
		Wait(0.25)
	EndWhile
	
	JValue.WriteToFile(jPlayerData,"Data/vMYC/" + sPlayerName + ".char.json")
	Debug.Notification("Exported character data!")
	JValue.Release(jPlayerData)

	LoadCharacterFiles()

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
	
	
	;Debug.Trace("MYC: PlayerREF.GetActorBase().GetRace().GetName() = " + PlayerREF.GetActorBase().GetRace().GetName())
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