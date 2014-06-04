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


vMYC_CharacterManagerScript Property CharacterManager Auto

Faction Property CurrentFollowerFaction Auto
Faction Property PotentialFollowerFaction Auto

GlobalVariable Property	vMYC_CharGenLoading Auto

Float Property PlayTime Auto Hidden

String Property CharacterName Auto Hidden

Race Property CharacterRace Auto Hidden
Race Property DummyRace		Auto


Formlist Property vMYC_CombatStyles Auto


;--=== Config variables ===--

;--=== Variables ===--

ActorBase _kActorBase

ColorForm	_kHairColor

Bool _bFirstLoad = True

Bool _bRefreshing = False

Bool _bHeadCovered = False

Bool _bNeedRefresh = True

Bool _bNeedCSUpdate = False

Bool _bDoUpkeep = False

Bool _bSwitchedRace = False

;Int _jCharacterData 

CombatStyle _kCombatStyle
CombatStyle _kLastCombatStyle

;--=== Events ===--

Event OnInit()
	_kActorBase = GetActorBase()	
EndEvent

Event OnLoad()
	Debug.Trace("MYC: (" + CharacterName + "/Actor) OnLoad!")
	CheckVars()
	If _bFirstLoad
		_bNeedRefresh = True
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
	_bNeedRefresh = True
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
	EndIf
	RegisterForSingleUpdate(5.0)
EndEvent

Event OnPackageChange(Package akOldPackage)
	Debug.Trace("MYC: Old package is " + akOldPackage + ", new package is " + GetCurrentPackage() + "!")
EndEvent

Event OnUnload()
	;_bNeedRefresh = True
;	UnregisterForUpdate()
EndEvent

Event OnRaceSwitchComplete()
	Debug.Trace("MYC: (" + CharacterName + "/Actor) OnRaceSwitchComplete!")
	_bSwitchedRace = True
EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
EndEvent

Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
EndEvent

Function CheckVars()
	If !_kActorBase
		Debug.Trace("MYC: (" + CharacterName + "/Actor/CheckVars) _kActorBase is empty, filling it...")
		_kActorBase = GetActorBase()
	EndIf
	If _kActorBase != GetActorBase()
		Debug.Trace("MYC: (" + CharacterName + "/Actor/CheckVars) ActorBase has CHANGED, this should NEVER happen! _kActorBase: " + _kActorBase + ", current is: " + GetActorBase())
		_kActorBase = GetActorBase()
	EndIf
	If !CharacterName
		Debug.Trace("MYC: (" + CharacterName + "/Actor/CheckVars) CharacterName is missing, getting it from CharacterManager...")
		CharacterName = CharacterManager.GetCharacterNameFromActorBase(_kActorBase)
		If !CharacterName
			Debug.Trace("MYC: (" + CharacterName + "/Actor) CharacterName was not set and could not be loaded from CharacterManager, this will cause problems!")
		EndIf
	EndIf
	If !CharacterRace
		Debug.Trace("MYC: (" + CharacterName + "/Actor/CheckVars) CharacterRace is missing, getting it from CharacterManager...")
		CharacterRace = CharacterManager.GetCharacterForm(CharacterName,"Race") as Race
		If !CharacterRace
			Debug.Trace("MYC: (" + CharacterName + "/Actor) CharacterRace was not set and could not be loaded from CharacterManager, this will cause problems!")
		EndIf
	EndIf
EndFunction

Function DoInit(Bool bInBackground = True)
{Run first time this character is loaded}
	DoUpkeep(bInBackground)
EndFunction

Function DoUpkeep(Bool bInBackground = True)
{Run whenever the player loads up the game. Sets the name and such.}
	If bInBackground
		_bDoUpkeep = True
		RegisterForSingleUpdate(0.1)
		Return
	EndIf
	GotoState("Busy")
	Debug.Trace("MYC: (" + CharacterName + "/Actor) Starting upkeep...")
	SendModEvent("vMYC_UpkeepBegin")
	CheckVars()
	SetNonpersistent()
	_bNeedRefresh = True
	RegisterForSingleUpdate(0.1)
	SendModEvent("vMYC_UpkeepEnd")
	Debug.Trace("MYC: (" + CharacterName + "/Actor) finished upkeep!")
	GotoState("")
EndFunction

Function SetNonpersistent()
	Debug.Trace("MYC: (" + CharacterName + "/Actor) Setting name...")
	_kActorBase.SetName(CharacterName)
	Debug.Trace("MYC: (" + CharacterName + "/Actor) Getting VoiceType from CharacterManager...")
	_kActorBase.SetVoiceType(CharacterManager.GetCharacterVoiceType(CharacterName))
	If GetFactionRank(PotentialFollowerFaction) <= -2
		Debug.Trace("MYC: (" + CharacterName + "/Actor) setting follower factions...")
		SetFactionRank(PotentialFollowerFaction,0)
		SetFactionRank(CurrentFollowerFaction,-1)
		SetRelationshipRank(Game.GetPlayer(),3)
	EndIf
	If !CharacterManager.GetCharacterForm(CharacterName,"Class") ; If !GetFormValue(_kActorBase,sKey + "Class")
		SetCustomActorValues(True)
	Else
		Debug.Trace("MYC: (" + CharacterName + "/Actor) has an assigned class, ignoring saved actor values!")
	EndIf
	UpdateCombatStyle()
EndFunction

Function UpdateCombatStyle()
	If IsDisabled()
		Debug.Trace("MYC: (" + CharacterName + "/Actor) UpdateCombatStyle was called but actor is disabled so we can't get weapon type. Try again later!")
		_bNeedCSUpdate = True
		Return
	EndIf
	_bNeedCSUpdate = False
	Int iEquippedItemType = GetEquippedItemType(1)
	_kLastCombatStyle = _kCombatStyle
	CharacterManager.SetLocalInt(CharacterName,"AllowMagic",0)
	If iEquippedItemType < 5 ; One-handed
		_kCombatStyle = vMYC_CombatStyles.GetAt(1) as CombatStyle ; Boss1H
	ElseIf iEquippedItemType == 5 || iEquippedItemType == 6
		_kCombatStyle = vMYC_CombatStyles.GetAt(2) as CombatStyle ; Boss2H
	ElseIf iEquippedItemType == 7 || iEquippedItemType == 12
		_kCombatStyle = vMYC_CombatStyles.GetAt(4) as CombatStyle ; Missile
	ElseIf iEquippedItemType == 8|| iEquippedItemType == 9
		_kCombatStyle = vMYC_CombatStyles.GetAt(3) as CombatStyle ; Magic
		CharacterManager.SetLocalInt(CharacterName,"AllowMagic",1)
	Else
		_kCombatStyle = vMYC_CombatStyles.GetAt(5) as CombatStyle ; Tank
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
EndFunction

Function RefreshMesh()
	GotoState("Busy")
	;Race kDummyRace = GetFormFromFile(0x00071E6A,"Skyrim.esm") as Race ; InvisibleRace
	Race kDummyRace = GetFormFromFile(0x00067CD8,"Skyrim.esm") as Race ; ElderRace
	Int iSafetyTimer = 5
	_kActorBase.SetInvulnerable(True)
;	SetAlpha(0.01,False)
;	Wait(2.0)
	;SetScale(0.01)
	Debug.Trace("MYC: (" + CharacterName + "/Actor) is loading CharGen data for " + CharacterName + ". Race is " + CharacterRace)
	;Wait(RandomFloat(0.0,2.0))
	;vMYC_CharGenLoading.Mod(1)
	;While vMYC_CharGenLoading.GetValue() > 1 && iSafetyTimer > 0
		;Debug.Trace("MYC: (" + CharacterName + "/Actor) Waiting for CharGen to become available...")
		;iSafetyTimer -= 1
		;Wait(RandomFloat(0.8,1.2))
	;EndWhile
	Debug.Trace("MYC: (" + CharacterName + "/Actor) SetRace!")
	_bSwitchedRace = False
	
	SetRace(DummyRace)
	iSafetyTimer = 20
	While !_bSwitchedRace && iSafetyTimer > 0
		iSafetyTimer -= 1
		Wait(0.25)
	EndWhile
	If !iSafetyTimer
		Debug.Trace("MYC: (" + CharacterName + "/Actor) SetRace timed out, that's usually not good.")
	EndIf
	Debug.Trace("MYC: (" + CharacterName + "/Actor) Finished SetRace!")
	;vMYC_CharGenLoading.Mod(-1)
	
	;SetRace(CharacterRace)
	;Wait(0.1)
;	EndIf
	If !_kHairColor
		_kHairColor = CharacterManager.getCharacterForm(CharacterName,"Appearance.HairColor") as ColorForm
	EndIf
	ColorForm MyHairColor = _kActorBase.GetHairColor()
	Debug.Trace("(" + CharacterName + "/Actor) MyHairColor (Pre-LoadCharacter) is R:" + MyHairColor.GetRed() + " G:" + MyHairColor.GetGreen() + " B:" + MyHairColor.GetBlue() + " H:" + MyHairColor.GetHue() + " S:" + MyHairColor.GetSaturation() + " V:" + MyHairColor.GetValue())
	If _kHairColor
		Debug.Trace("(" + CharacterName + "/Actor) _kHairColor is R:" + _kHairColor.GetRed() + " G:" + _kHairColor.GetGreen() + " B:" + _kHairColor.GetBlue() + " H:" + _kHairColor.GetHue() + " S:" + _kHairColor.GetSaturation() + " V:" + _kHairColor.GetValue())
		_kActorBase.SetHairColor(_kHairColor)
		;QueueNINodeUpdate()
		;Wait(0.5)
	EndIf
	;vMYC_CharGenLoading.Mod(1)
	;While vMYC_CharGenLoading.GetValue() > 1
		;Debug.Trace("MYC: (" + CharacterName + "/Actor) Waiting for CharGen to become available...")
		;Wait(RandomFloat(0.8,1.2))
	;EndWhile
	Debug.Trace("MYC: (" + CharacterName + "/Actor) Running LoadCharacter...")
	_bSwitchedRace = False
	Bool bSuccess =	CharGen.LoadCharacter(Self, CharacterRace, CharacterName)
	Debug.Trace("MYC: (" + CharacterName + "/Actor) Got " + bsuccess + " from LoadCharacter!")
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
		Debug.Trace("MYC: (" + CharacterName + "/Actor) Fixing hair...")
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
	Debug.Trace("(" + CharacterName + "/Actor) MyHairColor (Post-LoadCharacter) is R:" + MyHairColor.GetRed() + " G:" + MyHairColor.GetGreen() + " B:" + MyHairColor.GetBlue() + " H:" + MyHairColor.GetHue() + " S:" + MyHairColor.GetSaturation() + " V:" + MyHairColor.GetValue())
	vMYC_CharGenLoading.SetValue(0)
	;If CharacterManager.GetLocalInt(CharacterName,"InShrine")
		;SetScale(1.2)
	;Else
		;SetScale(1.0)
	;EndIf
;	SetAlpha(1.0,False)
;	Wait(1.0)
	_kActorBase.SetName(CharacterName)
	_kActorBase.SetInvulnerable(False)
	SendModEvent("vMYC_CharacterReady",CharacterName)
	GotoState("")
EndFunction

Function SetCustomActorValues(Bool bScaleToLevel = False)
	;Debug.Trace("MYC: (" + CharacterName + "/Actor) setting custom actor values...")
	String[] sAVNames = CharacterManager.AVNames
	Int iBaseLevel = CharacterManager.GetCharacterStat(CharacterName,"Level") as Int
	Int iMyLevel = GetLevel()
	Float fScaleMult = 1.0
	;Debug.Trace("MYC: (" + CharacterName + "/Actor) original actor level is " + iBaseLevel + ", current level is " + iMyLevel)
	Float fCharacterXP = (12.5 * iMyLevel * iMyLevel) + 62.5 * iMyLevel - 75
	;Debug.Trace("MYC: (" + CharacterName + "/Actor) needs " + fCharacterXP + " to reach this level!")
	If bScaleToLevel
		If iBaseLevel > 0
			fScaleMult = (iMyLevel as Float) / (iBaseLevel as Float)
		EndIf
		;Debug.Trace("MYC: (" + CharacterName + "/Actor) original actor values will be scaled to " + fScaleMult * 100 + "% of their value")
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
			;Debug.Trace("MYC: (" + CharacterName + ") Set dummy's " + sAVName + " to " + fAV)
		EndIf
	EndWhile
	SetAV("Confidence",3)
	SetAV("Assistance",2)
EndFunction

State Busy

	Event OnLoad()
		Debug.Trace("MYC: (" + CharacterName + "/Actor) OnLoad called in Busy state!")
	EndEvent

	;Function DoUpkeep(Bool bInBackground = True)
	;	Debug.Trace("MYC: (" + CharacterName + "/Actor) DoUpkeep called in Busy state!")
	;EndFunction

EndState