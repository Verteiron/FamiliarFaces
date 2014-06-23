Scriptname vMYC_CharacterDummyActorScript extends Actor
{Store data about character and apply transformation in OnLoad}

;--=== Imports ===--

Import Utility
Import Game

;--=== Properties ===--

Bool Property NeedRefresh Hidden
{Force a refresh next time this character is loaded}
	Bool Function Get()
		Return _bNeedRefresh
	EndFunction
	Function Set(Bool bNeedRefresh)
		_bNeedRefresh = bNeedRefresh
	EndFunction
EndProperty

Actor Property PlayerREF Auto

vMYC_CharacterManagerScript Property CharacterManager Auto
vMYC_ShrineOfHeroesQuestScript Property ShrineOfHeroes Auto

Faction Property CurrentFollowerFaction Auto
Faction Property PotentialFollowerFaction Auto
Faction Property PotentialMarriageFaction Auto
Faction Property vMYC_CharacterPlayerEnemyFaction Auto

GlobalVariable Property	vMYC_CharGenLoading Auto

Float Property PlayTime Auto Hidden

String Property CharacterName Auto Hidden

Race Property CharacterRace Auto Hidden
Race Property DummyRace		Auto


Formlist Property vMYC_CombatStyles Auto

Message Property vMYC_VoiceTypeNoFollower 	Auto
Message Property vMYC_VoiceTypeNoSpouse		Auto

;--=== Config variables ===--

;--=== Variables ===--

ActorBase _kActorBase

Bool _bFirstLoad = True

Bool _bRefreshing = False

Bool _bHeadCovered = False

Bool _bNeedRefresh = True

Bool _bNeedCSUpdate = False

Bool _bDoUpkeep = False

Bool _bSwitchedRace = False

Bool _bWarnedVoiceTypeNoFollower = False 

Bool _bWarnedVoiceTypeNoSpouse = False 

String[] _sSkillNames 

;Int _jCharacterData 

CombatStyle _kCombatStyle
CombatStyle _kLastCombatStyle

;--=== Events ===--

Event OnInit()
	_kActorBase = GetActorBase()
EndEvent

Event OnLoad()
	;Debug.Trace("MYC: (" + CharacterName + "/Actor) OnLoad!")
	SetNameIfNeeded()
	CheckVars()
	;DumpNIOData(CharacterName + "_OnLoad_" + GetCurrentRealTime())
	If _bFirstLoad
;		_bNeedRefresh = True
		;DoUpkeep()
		_bFirstLoad = False
	EndIf
	If _bNeedCSUpdate
		UpdateCombatStyle()
	EndIf
	RegisterForSingleUpdate(0.5)
EndEvent

Event OnCellAttach()
	_bNeedRefresh = True
EndEvent

Event OnAttachedToCell()
	;_bNeedRefresh = True
EndEvent

Event OnUpdate()
	If _bDoUpkeep
		_bDoUpkeep = False
		DoUpkeep(False)
	EndIf
	If _bNeedRefresh
		If !Is3DLoaded()
			RegisterForSingleUpdate(1.0)
			Return
		EndIf
		_bNeedRefresh = False
		RefreshMesh()
	ElseIf Is3DLoaded()
		SendModEvent("vMYC_CharacterReady",CharacterName)
	EndIf
	RegisterForSingleUpdate(5.0)
EndEvent

Event OnActivate(ObjectReference akActionRef)
	VoiceType kVoiceType = GetVoiceType()
	If !kVoiceType
		kVoiceType = _kActorBase.GetVoiceType()
		If !kVoiceType
			Return
		EndIf
	EndIf
	If !_bWarnedVoiceTypeNoFollower
		If GetFactionRank(CurrentFollowerFaction) == -1 && CharacterManager.vMYC_VoiceTypesFollowerList.Find(kVoiceType) == -1
			Debug.Trace("MYC: (" + CharacterName + "/Actor) Warning player about missing Follower VoiceType!")
			Message.ResetHelpMessage("VoiceTypeNoFollower")
			vMYC_VoiceTypeNoFollower.ShowAsHelpMessage("VoiceTypeNoFollower",8,240,1)
			_bWarnedVoiceTypeNoFollower = True
		EndIf
	EndIf
	If !_bWarnedVoiceTypeNoSpouse
		If GetFactionRank(PotentialMarriageFaction) > -2 && CharacterManager.vMYC_VoiceTypesSpouseList.Find(kVoiceType) == -1
			Armor kAmuletOfMara = GetFormFromFile(0x000C891B,"Skyrim.esm") as Armor
			If PlayerREF.IsEquipped(kAmuletOfMara)
				Debug.Trace("MYC: (" + CharacterName + "/Actor) Warning player about missing Spouse VoiceType!")
				Message.ResetHelpMessage("VoiceTypeNoSpouse")
				vMYC_VoiceTypeNoSpouse.ShowAsHelpMessage("VoiceTypeNoSpouse",8,240,1)
				_bWarnedVoiceTypeNoSpouse = True
			EndIf
		EndIf
	EndIf
EndEvent

Event OnPackageChange(Package akOldPackage)
	;Debug.Trace("MYC: Old package is " + akOldPackage + ", new package is " + GetCurrentPackage() + "!")
EndEvent

Event OnUnload()
	_bNeedRefresh = True
;	UnregisterForUpdate()
EndEvent

Event OnRaceSwitchComplete()
	;Debug.Trace("MYC: (" + CharacterName + "/Actor) OnRaceSwitchComplete!")
	_bSwitchedRace = True
EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
EndEvent

Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
EndEvent

Event OnUpdateCharacterSpellList(string eventName, string strArg, float numArg, Form sender)
	If strArg != CharacterName
		Return
	EndIf
	;Debug.Trace("MYC: (" + CharacterName + "/Actor): Updating character spell list!")
	Int jSpells = CharacterManager.GetCharacterObj(CharacterName,"Spells") ;JValue.solveObj(_jMYC,"." + CharacterName + ".Data.Spells")
	
	Int iAdded
	Int iRemoved
	
	Int i = JArray.Count(jSpells)
	While i > 0
		i -= 1
		Spell kSpell = JArray.getForm(jSpells,i) As Spell
		String sMagicSchool = kSpell.GetNthEffectMagicEffect(0).GetAssociatedSkill()
		Bool bSpellIsAllowed = False
		If sMagicSchool
			bSpellIsAllowed = CharacterManager.GetLocalInt(CharacterName,"MagicAllow" + sMagicSchool)
		Else
			bSpellIsAllowed = CharacterManager.GetLocalInt(CharacterName,"MagicAllowOther")
		EndIf
		If bSpellIsAllowed
			If AddSpell(kSpell,False)
				;;Debug.Trace("MYC: (" + CharacterName + "/Actor): Added spell - " + kSpell)
				iAdded += 1
			EndIf
		Else
			If RemoveSpell(kSpell)
				;;Debug.Trace("MYC: (" + CharacterName + "/Actor): Removed spell - " + kSpell)
				iRemoved += 1
			EndIf
		EndIf
	EndWhile
	Debug.Trace("MYC: (" + CharacterName + "/Actor): Added " + iAdded + " spells, removed " + iRemoved)
EndEvent

Function CheckVars()
	If !_kActorBase
		;Debug.Trace("MYC: (" + CharacterName + "/Actor/CheckVars) _kActorBase is empty, filling it...")
		_kActorBase = GetActorBase()
	EndIf
	If _kActorBase != GetActorBase()
		;Debug.Trace("MYC: (" + CharacterName + "/Actor/CheckVars) ActorBase has CHANGED, this should NEVER happen! _kActorBase: " + _kActorBase + ", current is: " + GetActorBase())
		_kActorBase = GetActorBase()
	EndIf
	If !CharacterName
		;Debug.Trace("MYC: (" + CharacterName + "/Actor/CheckVars) CharacterName is missing, getting it from CharacterManager...")
		CharacterName = CharacterManager.GetCharacterNameFromActorBase(_kActorBase)
		If !CharacterName
			;Debug.Trace("MYC: (" + CharacterName + "/Actor) CharacterName was not set and could not be loaded from CharacterManager, this will cause problems!")
		EndIf
	EndIf
	If !CharacterRace
		;Debug.Trace("MYC: (" + CharacterName + "/Actor/CheckVars) CharacterRace is missing, getting it from CharacterManager...")
		CharacterRace = CharacterManager.GetCharacterForm(CharacterName,"Race") as Race
		If !CharacterRace
			;Debug.Trace("MYC: (" + CharacterName + "/Actor) CharacterRace was not set and could not be loaded from CharacterManager, this will cause problems!")
		EndIf
	EndIf
	
	_sSkillNames = New String[24]
	
	_sSkillNames[6] = "OneHanded"
	_sSkillNames[7] = "TwoHanded"
	_sSkillNames[8] = "Marksman"
	_sSkillNames[9] = "Block"
	_sSkillNames[10] = "Smithing"
	_sSkillNames[11] = "HeavyArmor"
	_sSkillNames[12] = "LightArmor"
	_sSkillNames[13] = "Pickpocket"
	_sSkillNames[14] = "LockPicking"
	_sSkillNames[15] = "Sneak"
	_sSkillNames[16] = "Alchemy"
	_sSkillNames[17] = "SpeechCraft"
	_sSkillNames[18] = "Alteration"
	_sSkillNames[19] = "Conjuration"
	_sSkillNames[20] = "Destruction"
	_sSkillNames[21] = "Illusion"
	_sSkillNames[22] = "Restoration"
	_sSkillNames[23] = "Enchanting"
EndFunction

Function DoInit(Bool bInBackground = True)
{Run first time this character is loaded}
	DoUpkeep(bInBackground)
EndFunction

Function DoUpkeep(Bool bInBackground = True)
{Run whenever the player loads up the game. Sets the name and such.}
	SetNameIfNeeded()
	If bInBackground
		_bDoUpkeep = True
		RegisterForSingleUpdate(0.1)
		Return
	EndIf
	GotoState("Busy")
	;Debug.Trace("MYC: (" + CharacterName + "/Actor) Starting upkeep...")
	SendModEvent("vMYC_UpkeepBegin")
	CheckVars()
	RegisterForModEvent("vMYC_UpdateCharacterSpellList", "OnUpdateCharacterSpellList")
	SetNonpersistent()
	_bNeedRefresh = True
	_bWarnedVoiceTypeNoFollower = False
	_bWarnedVoiceTypeNoSpouse = False
	RegisterForSingleUpdate(0.1)
	SendModEvent("vMYC_UpkeepEnd")
	Debug.Trace("MYC: (" + CharacterName + "/Actor) finished upkeep!")
	GotoState("")
EndFunction

Function SetNonpersistent()
	;Debug.Trace("MYC: (" + CharacterName + "/Actor) Setting name...")
	SetNameIfNeeded()
	;Debug.Trace("MYC: (" + CharacterName + "/Actor) Applying perks...")
	Int iSafetyTimer = 10
	While CharacterManager.ApplyCharacterPerks(CharacterName) < 0 && iSafetyTimer
		iSafetyTimer -= 1
		Wait(0.5)
	EndWhile
	;Debug.Trace("MYC: (" + CharacterName + "/Actor) Applying haircolor...")
	ColorForm kHairColor = CharacterManager.GetCharacterForm(CharacterName,"Appearance.Haircolor") as ColorForm
	_kActorBase.SetHairColor(kHairColor)
	If !NIOverride.HasOverlays(Self)
		;Debug.Trace("MYC: (" + CharacterName + "/Actor) Adding NIO overlays...")
		CharacterManager.NIO_ApplyCharacterOverlays(CharacterName)
	EndIf
	;Debug.Trace("MYC: (" + CharacterName + "/Actor) Getting VoiceType from CharacterManager...")
	VoiceType kVoiceType = CharacterManager.GetCharacterForm(CharacterName,"VoiceType") as VoiceType
	If !kVoiceType
		kVoiceType = CharacterManager.GetLocalForm(CharacterName,"VoiceType") as VoiceType
	EndIf
	If kVoiceType
		_kActorBase.SetVoiceType(kVoiceType)
	Else ; No voicetype is saved, so set the default voicetype as the local voicetype
		kVoiceType = GetVoiceType()
		If !kVoiceType
			kVoiceType = _kActorBase.GetVoiceType()
		EndIf
		If kVoiceType
			CharacterManager.SetLocalForm(CharacterName,"VoiceType",GetVoiceType())
		Else
			Debug.Trace("MYC: (" + CharacterName + "/Actor) Weird, no VoiceType could be found ANYWHERE. What's going on here?",1)
		EndIf
	EndIf
	SetFactions()
	If !CharacterManager.GetCharacterForm(CharacterName,"Class") ; If !GetFormValue(_kActorBase,sKey + "Class")
		SetCustomActorValues(True)
	Else
		;Debug.Trace("MYC: (" + CharacterName + "/Actor) has an assigned class, ignoring saved actor values!")
	EndIf
	UpdateCombatStyle()
EndFunction

Function SetFactions()
	If CharacterManager.GetLocalInt(CharacterName,"IsFoe")
		Debug.Trace("MYC: (" + CharacterName + "/Actor) Hates the player!")
		RemoveFromFaction(CurrentFollowerFaction)
		RemoveFromFaction(PotentialFollowerFaction)
		RemoveFromFaction(PotentialMarriageFaction)
		SetFactionRank(vMYC_CharacterPlayerEnemyFaction,0)
		SetActorValue("Aggression",1)
		SetRelationshipRank(PlayerREF,-4)
	Else
		Debug.Trace("MYC: (" + CharacterName + "/Actor) Likes the player!")
		If GetFactionRank(PotentialFollowerFaction) <= -2
			RemoveFromFaction(vMYC_CharacterPlayerEnemyFaction)
			SetFactionRank(PotentialFollowerFaction,0)
			SetFactionRank(CurrentFollowerFaction,-1)
			SetRelationshipRank(PlayerREF,3)
			SetActorValue("Aggression",0)
		EndIf
		If IsInCombat() && GetCombatTarget() == PlayerREF
			StopCombat()
		EndIf
		If CharacterManager.GetLocalInt(CharacterName,"CanMarry") && GetFactionRank(PotentialMarriageFaction) <= -2
			Debug.Trace("MYC: (" + CharacterName + "/Actor) LOVES the player!")
			SetFactionRank(PotentialMarriageFaction,0)
		EndIf
	EndIf
EndFunction

Function UpdateCombatStyle()
	If IsDisabled()
		;Debug.Trace("MYC: (" + CharacterName + "/Actor) UpdateCombatStyle was called but actor is disabled so we can't get weapon type. Try again later!")
		_bNeedCSUpdate = True
		Return
	EndIf
	
	Int i = 6
	While i < _sSkillNames.Length
		Int iPerkCount = CharacterManager.GetCharacterInt(CharacterName,"PerkCounts." + _sSkillNames[i])
		If iPerkCount
			Debug.Trace("MYC: (" + CharacterName + "/Actor) PerkCount for " + _sSkillNames[i] + " is " + iPerkCount)
		EndIf

		If _sSkillNames[i] == "Blocking" && iPerkCount < 2
			CharacterManager.SetLocalInt(CharacterName,"AllowDualWield",1)
		EndIf
		
		 ; Magic skills
		If i >= 18 && i <= 22
			If iPerkCount > 1
				CharacterManager.SetLocalInt(CharacterName,"MagicAllow" + _sSkillNames[i],1)
			Else 
				CharacterManager.SetLocalInt(CharacterName,"MagicAllow" + _sSkillNames[i],0)
			EndIf
		EndIf
		i += 1
	EndWhile
	_bNeedCSUpdate = False
	Int iEquippedItemType = GetEquippedItemType(1)
	
	_kLastCombatStyle = _kCombatStyle
	CharacterManager.SetLocalInt(CharacterName,"AllowMagic",0)
	If iEquippedItemType < 5 ; One-handed
		If CharacterManager.GetLocalInt(CharacterName,"AllowDualWield")
			_kCombatStyle = vMYC_CombatStyles.GetAt(16) as CombatStyle ; vMYC_csHumanBoss1HDual
		Else
			_kCombatStyle = vMYC_CombatStyles.GetAt(3) as CombatStyle ; Boss1H
		EndIf
	ElseIf iEquippedItemType == 5 || iEquippedItemType == 6
		_kCombatStyle = vMYC_CombatStyles.GetAt(4) as CombatStyle ; Boss2H
	ElseIf iEquippedItemType == 7 || iEquippedItemType == 12
		_kCombatStyle = vMYC_CombatStyles.GetAt(14) as CombatStyle ; Missile
	ElseIf iEquippedItemType == 8|| iEquippedItemType == 9
		_kCombatStyle = vMYC_CombatStyles.GetAt(5) as CombatStyle ; Magic
		CharacterManager.SetLocalInt(CharacterName,"AllowMagic",1)
	Else
		_kCombatStyle = vMYC_CombatStyles.GetAt(1) as CombatStyle ; Tank
	EndIf
	If _kCombatStyle != _kLastCombatStyle
		_kActorBase.SetCombatStyle(_kCombatStyle)
		If CharacterManager.GetLocalInt(CharacterName,"AllowMagic")
			SetAV("Magicka",CharacterManager.GetLocalFlt(CharacterName,"Magicka"))
		Else
			SetAV("Magicka",0)
		EndIf
		Debug.Trace("MYC: Set " + CharacterName + "'s combatstyle to " + _kCombatStyle)
	EndIf
	CharacterManager.SetLocalForm(CharacterName,"CombatStyle",_kCombatStyle)
	SendModEvent("vMYC_UpdateCharacterSpellList",CharacterName)
EndFunction

Function RefreshMesh()
	GotoState("Busy")
	;Race kDummyRace = GetFormFromFile(0x00071E6A,"Skyrim.esm") as Race ; InvisibleRace
	Race kDummyRace = GetFormFromFile(0x00067CD8,"Skyrim.esm") as Race ; ElderRace
	Int iSafetyTimer = 15
	_kActorBase.SetInvulnerable(True)
;	SetAlpha(0.01,False)
;	Wait(2.0)
	;SetScale(0.01)
	;Debug.Trace("MYC: (" + CharacterName + "/Actor) is loading CharGen data for " + CharacterName + ". Race is " + CharacterRace)
	;Wait(RandomFloat(0.0,2.0))
	Int iMyTurn = vMYC_CharGenLoading.GetValue() as Int	
	vMYC_CharGenLoading.Mod(1)
;	Wait(1.0)
	;While vMYC_CharGenLoading.GetValue() - 1 != iMyTurn && iSafetyTimer > 0
		;;Debug.Trace("MYC: (" + CharacterName + "/Actor) Waiting for SetRace to become available. ...")
		;iSafetyTimer -= 1
		;Wait(1.0)
	;EndWhile
	;Debug.Trace("MYC: (" + CharacterName + "/Actor) SetRace!")
	_bSwitchedRace = False
	;Bool bAIEnabled = IsAIEnabled()
	;EnableAI(False)
	;If
	ObjectReference kNowhere = GetFormFromFile(0x02004e4d,"vMYC_MeetYourCharacters.esp") as ObjectReference ; NordRace 0x13746
	Activator FXEmptyActivator = GetFormFromFile(0x000b79ff,"Skyrim.esm") as Activator
	ObjectReference kHere = PlaceAtMe(FXEmptyActivator)
	Moveto(kNowhere)
	Wait(0.1)
	SetRace(kDummyRace)
	Wait(0.1)
;	Race kNordRace = GetFormFromFile(0x00013746,"Skyrim.esm") as Race ; NordRace 0x13746
;	Race kArgonianRace = GetFormFromFile(0x00013740,"Skyrim.esm") as Race ; LeeezardRace 0x13746
;
;	If CharacterRace == kNordRace
;		CharGen.LoadCharacter(Self, kArgonianRace, "vMYC_DefaultNonNord")
;	Else
;		CharGen.LoadCharacter(Self, kNordRace, "vMYC_DefaultNord")
;	EndIf
	;iSafetyTimer = 20
	;While !_bSwitchedRace && iSafetyTimer > 0
		;iSafetyTimer -= 1
		;Wait(0.25)
	;EndWhile
	;If !iSafetyTimer
		;;Debug.Trace("MYC: (" + CharacterName + "/Actor) SetRace timed out, that's usually not good.")
	;EndIf
	MoveTo(kHere)
	WaitFor3DLoad(Self)
	kHere.Delete()
	;Wait(0.5)
	;Debug.Trace("MYC: (" + CharacterName + "/Actor) Finished SetRace!")
	;vMYC_CharGenLoading.Mod(-1)
	
	;SetRace(CharacterRace)
	;Wait(0.1)
;	EndIf
	;vMYC_CharGenLoading.Mod(1)
	;While vMYC_CharGenLoading.GetValue() > 1
		;;Debug.Trace("MYC: (" + CharacterName + "/Actor) Waiting for CharGen to become available...")
		;Wait(RandomFloat(0.8,1.2))
	;EndWhile
	;Debug.Trace("MYC: (" + CharacterName + "/Actor) Running LoadCharacter...")
	_bSwitchedRace = False
	iSafetyTimer = 10
	Bool bSuccess = CharGen.LoadCharacter(Self, CharacterRace, CharacterName)
	While !bSuccess && iSafetyTimer > 0
		iSafetyTimer -= 1
		Wait(0.5)
		bSuccess = CharGen.LoadCharacter(Self, CharacterRace, CharacterName)
	EndWhile
	;Debug.Trace("MYC: (" + CharacterName + "/Actor) Got " + bSuccess + " from LoadCharacter!")
	iSafetyTimer = 20
	While !_bSwitchedRace && iSafetyTimer > 0
		iSafetyTimer -= 1
		Wait(0.25)
	EndWhile
	If !iSafetyTimer
		Debug.Trace("MYC: (" + CharacterName + "/Actor) SetRace timed out, that's usually not good.")
	EndIf
	;vMYC_CharGenLoading.Mod(-1)
	Form kHairEquipment = GetWornForm(0x00000002)
	Form kLongHairEquipment = GetWornForm(0x00000800)
	If kHairEquipment == kLongHairEquipment
		kLongHairEquipment = None
	EndIf
	If kHairEquipment
		UnequipItem(kHairEquipment)
	EndIf
	If kLongHairEquipment
		UnequipItem(kLongHairEquipment)
	EndIf
	If kHairEquipment || kLongHairEquipment
		;Debug.Trace("MYC: (" + CharacterName + "/Actor) Fixing hair...")
		; LoadCharacter doesn't know about head armor, so sometimes can make a ponytail stick through a hood and such.
		;  This fixes that by un/requipping anything that uses the Hair or Longhair slots 
;		Wait(0.5)
		If kHairEquipment
			EquipItemEx(kHairEquipment,0,True)
		EndIf
		If kLongHairEquipment
			EquipItemEx(kLongHairEquipment,0,True)
		EndIf
	EndIf

	If bSuccess
		Debug.Trace("MYC: (" + CharacterName + "/Actor) loaded successfully!")
	Else
		Debug.Trace("MYC: (" + CharacterName + "/Actor) FAILED! :(")
	EndIf
	vMYC_CharGenLoading.SetValue(0)
	;If CharacterManager.GetLocalInt(CharacterName,"InShrine")
		;SetScale(1.2)
	;Else
		;SetScale(1.0)
	;EndIf
;	SetAlpha(1.0,False)
;	Wait(1.0)
	SetNameIfNeeded()
	;EnableAI(bAIEnabled)
	_kActorBase.SetInvulnerable(False)
	;CharacterManager.NIO_ApplyCharacterOverlays(CharacterName)
	;DumpNIOData(CharacterName + "_RefreshMesh_" + GetCurrentRealTime())
	SendModEvent("vMYC_CharacterReady",CharacterName)
	GotoState("")
EndFunction

Bool Function WaitFor3DLoad(ObjectReference kObjectRef, Int iSafety = 20)
	While !kObjectRef.Is3DLoaded() && iSafety > 0
		iSafety -= 1
		Wait(0.1)
	EndWhile
	Return iSafety as Bool
EndFunction


Function SetCustomActorValues(Bool bScaleToLevel = False)
	;;Debug.Trace("MYC: (" + CharacterName + "/Actor) setting custom actor values...")
	String[] sAVNames = CharacterManager.AVNames
	Int iBaseLevel = CharacterManager.GetCharacterStat(CharacterName,"Level") as Int
	Int iMyLevel = GetLevel()
	Float fScaleMult = 1.0
	;;Debug.Trace("MYC: (" + CharacterName + "/Actor) original actor level is " + iBaseLevel + ", current level is " + iMyLevel)
	Float fCharacterXP = (12.5 * iMyLevel * iMyLevel) + 62.5 * iMyLevel - 75
	;;Debug.Trace("MYC: (" + CharacterName + "/Actor) needs " + fCharacterXP + " to reach this level!")
	If bScaleToLevel
		If iBaseLevel > 0
			fScaleMult = (iMyLevel as Float) / (iBaseLevel as Float)
		EndIf
		;;Debug.Trace("MYC: (" + CharacterName + "/Actor) original actor values will be scaled to " + fScaleMult * 100 + "% of their value")
	EndIf
	Int i
	i = sAVNames.Length ;jArray.Count(jActorValueStrings)
	While i > 0
		i -= 1
		String sAVName = sAVNames[i]
		If sAVNames[i]
			Float fAV = CharacterManager.GetCharacterAV(CharacterName,sAVNames[i])
			If sAVName == "Health" || sAVName == "Magicka" || sAVName == "Stamina" 
				fAV = 100 + (((fAV - 100) / (iBaseLevel as Float)) * iMyLevel)
				If fAV < 100
					fAV = 100
				EndIf
				CharacterManager.SetLocalFlt(CharacterName,sAVName,fAV)
			ElseIf fAV < 20 
				; Player hasn't really worked on this one at all, don't change it
			Else
				fAV = 15 + (((fAV - 15) / (iBaseLevel as Float)) * iMyLevel)
				If fAV > 100
					fAV = 100
				ElseIf fAV < 15
					fAV = 15
				EndIf
			EndIf
			SetActorValue(sAVName,fAV as Int)
			;;Debug.Trace("MYC: (" + CharacterName + ") Set dummy's " + sAVName + " to " + fAV)
		EndIf
	EndWhile
	SetAV("Confidence",3)
	SetAV("Assistance",2)
EndFunction

Function SetNameIfNeeded(Bool abForce = False)
	If (CharacterName && _kActorBase.GetName() != CharacterName) || abForce
		;Debug.Trace("MYC: (" + CharacterName + "/Actor) Setting actorbase name!")
		_kActorBase.SetName(CharacterName)

		Int i = GetNumReferenceAliases()
		While i > 0
			i -= 1
			ReferenceAlias kThisRefAlias = GetNthReferenceAlias(i)
			If kThisRefAlias.GetOwningQuest() != CharacterManager && kThisRefAlias.GetOwningQuest() != ShrineOfHeroes
				;Debug.Trace("MYC: (" + CharacterName + "/Actor) Resetting RefAlias " + kThisRefAlias + "!")
				kThisRefAlias.Clear()
				kThisRefAlias.ForceRefTo(Self)
			EndIf
		EndWhile
		SendModEvent("vMYC_UpdateXFLPanel")
	EndIf
EndFunction

Function DumpNIOData(String sFilename)
	Int jNIOData = JMap.Object()
	JMap.setObj(jNIOData,"BodyOverlays",CharacterManager.NIO_GetOverlayData("Body [Ovl",NIOverride.GetNumBodyOverlays(),Self))
	JMap.setObj(jNIOData,"HandOverlays",CharacterManager.NIO_GetOverlayData("Hand [Ovl",NIOverride.GetNumHandOverlays(),Self))
	JMap.setObj(jNIOData,"FeetOverlays",CharacterManager.NIO_GetOverlayData("Feet [Ovl",NIOverride.GetNumFeetOverlays(),Self))
	JMap.setObj(jNIOData,"FaceOverlays",CharacterManager.NIO_GetOverlayData("Face [Ovl",NIOverride.GetNumFaceOverlays(),Self))
	JValue.WriteToFile(jNIOData,"Data/vMYC/" + sFilename + ".json")
EndFunction

State Busy

	Event OnLoad()
		;Debug.Trace("MYC: (" + CharacterName + "/Actor) OnLoad called in Busy state!")
	EndEvent

	Event OnAttachedToCell()
		;Debug.Trace("MYC: (" + CharacterName + "/Actor) OnAttachedToCell called in Busy state!")
	EndEvent
	
	Event OnUnload()
		;Debug.Trace("MYC: (" + CharacterName + "/Actor) OnUnload called in Busy state!")
	EndEvent
	
	;Function DoUpkeep(Bool bInBackground = True)
	;	;Debug.Trace("MYC: (" + CharacterName + "/Actor) DoUpkeep called in Busy state!")
	;EndFunction

EndState