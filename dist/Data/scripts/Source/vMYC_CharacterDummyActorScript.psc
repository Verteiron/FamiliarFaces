ScriptName vMYC_CharacterDummyActorScript Extends Actor
{Store data about character and Apply transformation in OnLoad.}

;=== Imports ===--

Import Utility
Import Game
Import vMYC_Config

;=== Properties ===--

Bool Property NeedRefresh Hidden
	{Force a refresh next time this character is loaded.}
	Bool Function get()
		Return _bNeedRefresh
	EndFunction
	Function set(Bool bNeedRefresh)
		_bNeedRefresh = bNeedRefresh
	EndFunction
EndProperty

Actor Property PlayerREF Auto

Bool Property IsBusy Auto

vMYC_CharacterManagerScript Property CharacterManager Auto
vMYC_ShrineOfHeroesQuestScript Property ShrineOfHeroes Auto
vMYC_HangoutManager Property HangoutManager Auto

Faction Property CurrentFollowerFaction Auto
Faction Property PotentialFollowerFaction Auto
Faction Property PotentialMarriageFaction Auto
Faction Property vMYC_CharacterPlayerEnemyFaction Auto

GlobalVariable Property	vMYC_CharGenLoading Auto

GlobalVariable Property DecapitationChance Auto

Float Property PlayTime Auto Hidden

String Property CharacterName Auto Hidden

Race Property CharacterRace Auto Hidden
Race Property DummyRace		Auto

EffectShader 	Property 	vMYC_BlindingLightGold				Auto
Explosion 		Property	vMYC_CharacterDeathExplosion		Auto
VisualEffect	Property	vMYC_ValorFX						Auto
VisualEffect	Property 	DA02SummonValorTargetFX				Auto
ImageSpaceModifier	Property	ISMDwhiteoutFULLthenFade		Auto

Sound			Property	NPCDragonDeathFX2D					Auto
Sound			Property	NPCDragonDeathSequenceExplosion		Auto

FormList Property vMYC_CombatStyles Auto

FormList Property vMYC_ModCompatibility_SpellList_Safe Auto
FormList Property vMYC_ModCompatibility_SpellList_Unsafe Auto
FormList Property vMYC_ModCompatibility_SpellList_Healing Auto
FormList Property vMYC_ModCompatibility_SpellList_Armor Auto

Message Property vMYC_VoiceTypeNoFollower 	Auto
Message Property vMYC_VoiceTypeNoSpouse		Auto

Armor Property	vMYC_DummyArmor	Auto

Bool Property InCity Auto

;=== Config variables ===--

;=== Variables ===--

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

Bool _bInvalidRace = False

Bool _bNeedPerks

Bool _bNeedShouts

Bool _bNeedSpells

Bool _bNeedInventory

String[] _sSkillNames

Float _fDecapitationChance

Int _iMagicUpdateCounter

Float 	_fOrphanedTime
Bool 	_bOrphaned

;Int _jCharacterData

CombatStyle _kCombatStyle
CombatStyle _kLastCombatStyle

Int _iCharGenVersion

;=== Events ===--

Event OnInit()
	_kActorBase = GetActorBase()
EndEvent

Event OnLoad()
	;Debug.Trace("MYC/Actor/" + CharacterName + ": OnLoad!")
	IsBusy = True
	CheckVars()
	SetNameIfNeeded()
	SetNINodes()
	CheckArmor()
	;DumpNIOData(CharacterName + "_OnLoad_" + GetCurrentRealTime())
	If _bFirstLoad
		If _iCharGenVersion >= 3
			;RefreshMeshNewCG()
		EndIf
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
	Bool bWasInCity = InCity
	Location kLocation = GetCurrentLocation()
	If kLocation
		InCity = kLocation.HasKeywordString("LocTypeHabitation")
	Else
		InCity = False
	EndIf
	If InCity != bWasInCity && GetConfigBool("SHOUTS_DISABLE_CITIES")
		UpdateShoutList()
	EndIf
	;_bNeedRefresh = True
EndEvent

Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	Bool bWasInCity = InCity
	If akNewLoc
		InCity = akNewLoc.HasKeywordString("LocTypeHabitation")
	Else
		InCity = False
	EndIf
	If InCity != bWasInCity ;&& GetConfigBool("SHOUTS_DISABLE_CITIES")
		UpdateShoutList()
	EndIf
EndEvent

Event OnEnterBleedout()
	If CharacterManager.GetLocalInt(CharacterName,"IsFoe")
		BlockActivation(True)
		vMYC_ValorFX.Play(Self,8)
		Wait(2)
		DA02SummonValorTargetFX.Play(Self,8)
		ISMDwhiteoutFULLthenFade.Apply()
		Wait(1)
		SetAlpha(0.01,True)
		Wait(1.3)
		NPCDragonDeathSequenceExplosion.Play(Self)
		PlaceAtMe(vMYC_CharacterDeathExplosion)
		NPCDragonDeathFX2D.Play(Self)
		CharacterManager.SetCharacterTracking(CharacterName,False)
		SetAlpha(0,True)
		SetScale(0.01)
		Wait(8)
		BlockActivation(False)
		ShrineOfHeroes.AlcoveControllers[ShrineOfHeroes.GetAlcoveIndex(CharacterName)].BanishCharacter()
	EndIf
EndEvent

Event OnUpdate()
	If !Self as Actor
		Return
	EndIf
	If _bDoUpkeep
		_bDoUpkeep = False
		DoUpkeep(False)
	EndIf
	If _bNeedRefresh && _iCharGenVersion >= 3
		RefreshMeshNewCG()
		;CheckArmor()
		_bNeedRefresh = False
	ElseIf Is3DLoaded()
		SendModEvent("vMYC_CharacterReady",CharacterName)
	EndIf
	If !CharacterManager.GetLocalInt(CharacterName,"InAlcove") && !IsAIEnabled()
		;Debug.Trace("MYC/Actor/" + CharacterName + ": AI disabled while InAlcove is false, enabling AI!")
		EnableAI(True)
	EndIf
	IsBusy = False
	Bool bIsSummoned = CharacterManager.GetLocalInt(CharacterName,"IsSummoned")
	If _bNeedPerks && bIsSummoned
		If CharacterManager.ApplyCharacterPerks(CharacterName) >= 0
			_bNeedPerks = False
		EndIf
	EndIf
	If _bNeedShouts && bIsSummoned
		UpdateShoutList() ; will take care of setting _bNeedShouts
	EndIf
	If _bNeedSpells && bIsSummoned
		OnUpdateCharacterSpellList("",CharacterName,0.0,Self)
		_bNeedSpells = False
	EndIf
	If _bNeedInventory && bIsSummoned
		CharacterManager.PopulateInventory(CharacterName)
		_bNeedInventory = False
	EndIf
	If bIsSummoned
		If CharacterManager.GetLocalInt(CharacterName,"ArmorCheck") == 1
			;ArmorCheck is set to "Always", check more frequently!
			CheckArmor()
		EndIf
		If GetRelationshipRank(PlayerREF) == 0
			;Debug.Trace("MYC/Actor/" + CharacterName + ": Setting factions!")
			SetFactions()
		EndIf
	Else
		;Set relationshiprank to 0 while in the Shrine, so giant disabled NPCs don't show at your wedding
		If GetRelationshipRank(PlayerREF) > 0
			;Debug.Trace("MYC/Actor/" + CharacterName + ": Setting relationshiprank to 0")
			SetRelationshipRank(PlayerREF,0)
		EndIf
	EndIf

	If _bNeedPerks || _bNeedShouts || _bNeedSpells || _bNeedInventory
		If bIsSummoned
			RegisterForSingleUpdate(1.0)
		Else
			RegisterForSingleUpdate(15.0)
		EndIf
	Else 
		RegisterForSingleUpdate(5.0)
	EndIf
	DeleteIfOrphaned()
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
			;Debug.Trace("MYC/Actor/" + CharacterName + ": Warning player about missing Follower VoiceType!")
			Message.ResetHelpMessage("VoiceTypeNoFollower")
			vMYC_VoiceTypeNoFollower.ShowAsHelpMessage("VoiceTypeNoFollower",8,240,1)
			_bWarnedVoiceTypeNoFollower = True
		EndIf
	EndIf
	If !_bWarnedVoiceTypeNoSpouse
		If GetFactionRank(PotentialMarriageFaction) > -2 && CharacterManager.vMYC_VoiceTypesSpouseList.Find(kVoiceType) == -1
			Armor kAmuletOfMara = GetFormFromFile(0x000C891B,"Skyrim.esm") As Armor
			If PlayerREF.IsEquipped(kAmuletOfMara)
				;Debug.Trace("MYC/Actor/" + CharacterName + ": Warning player about missing Spouse VoiceType!")
				Message.ResetHelpMessage("VoiceTypeNoSpouse")
				vMYC_VoiceTypeNoSpouse.ShowAsHelpMessage("VoiceTypeNoSpouse",8,240,1)
				_bWarnedVoiceTypeNoSpouse = True
			EndIf
		EndIf
	EndIf
EndEvent

Event OnPackageChange(Package akOldPackage)
	;Debug.Trace("MYC/Actor/" + CharacterName + ": Old package is " + akOldPackage + ", new package is " + GetCurrentPackage() + "!")
	If IsInCombat() && GetCombatTarget() == PlayerREF && DecapitationChance.GetValue()
		_fDecapitationChance = DecapitationChance.GetValue()
		DecapitationChance.SetValue(0)
	ElseIf _fDecapitationChance && !DecapitationChance.GetValue()
		DecapitationChance.SetValue(_fDecapitationChance)
	EndIf
	If GetConfigBool("TRACK_STOPONRECRUIT") && (IsPlayerTeammate() || GetFactionRank(CurrentFollowerFaction) >= 0)
		HangoutManager.EnableTracking(Self,False)
	ElseIf GetConfigBool("TRACK_STOPONRECRUIT") && (!IsPlayerTeammate() || GetFactionRank(CurrentFollowerFaction) < 0)
		HangoutManager.EnableTracking(Self,True)
	EndIf
EndEvent

Event OnUnload()
	_bNeedRefresh = True
	;	UnregisterForUpdate()
EndEvent

Event OnRaceSwitchComplete()
	;Debug.Trace("MYC/Actor/" + CharacterName + ": OnRaceSwitchComplete!")
	_bSwitchedRace = True
EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
EndEvent

Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
EndEvent

Event OnConfigUpdate(String asConfigPath)
	;Debug.Trace("MYC/Actor/" + CharacterName + ": OnConfigUpdate(" + asConfigPath + ")")
	If asConfigPath == "MAGIC_OVERRIDES" || asConfigPath == "MAGIC_ALLOWFROMMODS"
		_bNeedSpells = True
	ElseIf asConfigPath == "AUTOLEVEL_CHARACTERS"
		SetNonpersistent()
	ElseIf asConfigPath == "SHOUTS_DISABLE_CITIES" || asConfigPath == "SHOUTS_HANDLING" || asConfigPath == "SHOUTS_BLOCK_UNLEARNED"
		_bNeedShouts = True
		RegisterForSingleUpdate(0.5)
	ElseIf asConfigPath == "DEBUG_CHARACTER_FORCEREFRESH"
		NeedRefresh = GetConfigBool("DEBUG_CHARACTER_FORCEREFRESH")
		RegisterForSingleUpdate(0.5)
	EndIf
EndEvent

Event OnUpdateCharacterSpellList(String eventName, String strArg, Float numArg, Form sender)
	If strArg != CharacterName
		Return
	EndIf
	_iMagicUpdateCounter += 1
	Int iMyCounter = _iMagicUpdateCounter
	Wait(1)
	If iMyCounter != _iMagicUpdateCounter
		Return
	EndIf

	If CharacterManager.GetLocalInt(CharacterName,"Compat_AFT_MagicDisabled")
		;Do not alter spell list if Magic is disabled by AFT
		Return
	EndIf

	;Debug.Trace("MYC: (" + CharacterName + "/Actor): Updating character spell list!")
	Int jSpells = CharacterManager.GetCharacterObj(CharacterName,"Spells") ;JValue.solveObj(_jMYC,"." + CharacterName + ".Data.Spells")
	
	Int iAdded
	Int iRemoved
	
	If CharacterManager.GetLocalInt(CharacterName,"MagicAutoSelect")
		Int i = 6
		While i < _sSkillNames.Length
			Int iPerkCount = CharacterManager.GetCharacterInt(CharacterName,"PerkCounts." + _sSkillNames[i])
			If iPerkCount
				;Debug.Trace("MYC/Actor/" + CharacterName + ": PerkCount for " + _sSkillNames[i] + " is " + iPerkCount)
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
	EndIf
	
	Int iDefaultMagicHandling = GetConfigInt("MAGIC_OVERRIDES")
	Int iAllowFromMods = GetConfigInt("MAGIC_ALLOWFROMMODS")
	
	Bool bMagicAllowHealing = False
	Bool bMagicAllowDefensive = False
	
	If iDefaultMagicHandling == 1 
		bMagicAllowHealing = True
	ElseIf iDefaultMagicHandling == 2
		bMagicAllowHealing = True
		bMagicAllowDefensive = True
	EndIf
	
	Int i = JArray.Count(jSpells)
	While i > 0
		i -= 1
		Spell kSpell = JArray.GetForm(jSpells,i) As Spell
		String sMagicSchool = kSpell.GetNthEffectMagicEffect(0).GetAssociatedSkill()
		Bool bSpellIsAllowed = False
		
		If sMagicSchool
			bSpellIsAllowed = CharacterManager.GetLocalInt(CharacterName,"MagicAllow" + sMagicSchool)
		Else
			bSpellIsAllowed = CharacterManager.GetLocalInt(CharacterName,"MagicAllowOther")
		EndIf
		
		MagicEffect kMagicEffect = kSpell.GetNthEffectMagicEffect(0)
		
		If bMagicAllowHealing ;sMagicSchool == "Restoration" && 
			If kMagicEffect.HasKeywordString("MagicRestoreHealth") && kMagicEffect.GetDeliveryType() == 0 && !kSpell.IsHostile() ;&& !kMagicEffect.IsEffectFlagSet(0x00000004) 
				bSpellIsAllowed = True
			ElseIf vMYC_ModCompatibility_SpellList_Healing.HasForm(kSpell)
				bSpellIsAllowed = True
			EndIf
		EndIf
		
		If bMagicAllowDefensive
			If kMagicEffect.HasKeywordString("MagicArmorSpell") && kMagicEffect.GetDeliveryType() == 0 && !kSpell.IsHostile() ;&& !kMagicEffect.IsEffectFlagSet(0x00000004) 
				bSpellIsAllowed = True
			ElseIf vMYC_ModCompatibility_SpellList_Armor.HasForm(kSpell)
				bSpellIsAllowed = True
			EndIf
		EndIf

		If bSpellIsAllowed
			Int[] iAllowedSources = New Int[128]
			
			If iAllowFromMods < 2 ; No mods or select mods
				iAllowedSources[0] = GetModByName("Skyrim.esm")
				iAllowedSources[1] = GetModByName("Update.esm")
				iAllowedSources[2] = GetModByName("Dawnguard.esm")
				iAllowedSources[3] = GetModByName("Dragonborn.esm")
				iAllowedSources[4] = GetModByName("Hearthfires.esm")
			EndIf
			
			If iAllowFromMods == 1 ; Select mods
				iAllowedSources[5] = GetModByName("ColorfulMagic.esp")
				iAllowedSources[6] = GetModByName("Magic of the Magna-Ge.esp")
				iAllowedSources[7] = GetModByName("Animated Dragon Wings.esp")
				iAllowedSources[8] = GetModByName("Dwemerverse.esp")
			EndIf
			
			bSpellIsAllowed = False
			
			If iAllowFromMods == 2  ; ALL mods
				bSpellIsAllowed = True
			Else
				;See if this spell is from an approved source
				Int iSpellSourceID = Math.RightShift(kSpell.GetFormID(),24)
				If iAllowedSources.Find(iSpellSourceID) > -1
					bSpellIsAllowed = True
				ElseIf vMYC_ModCompatibility_SpellList_Safe.HasForm(kSpell)
				;A mod author has gone to the trouble of assuring us the spell is compatible.
					bSpellIsAllowed = True
				EndIf
			EndIf
		EndIf

		If vMYC_ModCompatibility_SpellList_Unsafe.HasForm(kSpell)
		;A mod author has added the spell to the unsafe list.
			bSpellIsAllowed = False
		EndIf
			
		
		If bSpellIsAllowed && !HasSpell(kSpell)
			If AddSpell(kSpell,False)
				;Debug.Trace("MYC: (" + CharacterName + "/Actor): Added " + sMagicSchool + " spell - " + kSpell.GetName() + " (" + kSpell + ") from " + GetModName(Math.RightShift(kSpell.GetFormID(),24)))
				iAdded += 1
			EndIf
		ElseIf !bSpellIsAllowed && HasSpell(kSpell)
			;Remove only if it is hostile, or has a duration, or has an associated cost discount perk. This way we avoid stripping perk, race, and doom stone abilities
			If kMagicEffect.IsEffectFlagSet(0x00000001) || kSpell.GetPerk() || kSpell.GetNthEffectDuration(0) > 0
				If RemoveSpell(kSpell)
					;Debug.Trace("MYC: (" + CharacterName + "/Actor): Removed " + sMagicSchool + " spell - " + kSpell.GetName() + " (" + kSpell + ")")
					iRemoved += 1
				EndIf
			EndIf
		EndIf
	EndWhile
	If iAdded || iRemoved
		;Debug.Trace("MYC: (" + CharacterName + "/Actor): Added " + iAdded + " spells, removed " + iRemoved)
	EndIf

	_bNeedShouts = True
	
EndEvent

Function UpdateShoutList()
	If (CharacterManager.HasLocalKey(CharacterName,"ShoutsAllowMaster") && !CharacterManager.GetLocalInt(CharacterName,"ShoutsAllowMaster")) \
	|| (InCity && GetConfigBool("SHOUTS_DISABLE_CITIES")) \
	|| (GetConfigInt("SHOUTS_HANDLING") == 4)
		CharacterManager.RemoveCharacterShouts(CharacterName)
		_bNeedShouts = False
	Else ;If HasSpell(GetFormFromFile(0x0201f055,"vMYC_MeetYourCharacters.esp") As Shout) || abForceUpdate
		If CharacterManager.ApplyCharacterShouts(CharacterName) >= 0
			_bNeedShouts = False
		EndIf
	EndIf
EndFunction

Function CheckVars()
	If !_kActorBase
		;Debug.Trace("MYC: (" + CharacterName + "/Actor/CheckVars) _kActorBase is empty, filling it...")
		_kActorBase = GetActorBase()
	EndIf
	If _kActorBase != GetActorBase()
		Debug.Trace("MYC: (" + CharacterName + "/Actor/CheckVars) ActorBase has CHANGED, this should NEVER happen! _kActorBase: " + _kActorBase + ", current is: " + GetActorBase(),1)
		_kActorBase = GetActorBase()
	EndIf
	If !CharacterName
		;Debug.Trace("MYC: (" + CharacterName + "/Actor/CheckVars) CharacterName is missing, getting it from CharacterManager...")
		CharacterName = CharacterManager.GetCharacterNameFromActorBase(_kActorBase)
		If !CharacterName
			Debug.Trace("MYC/Actor/" + CharacterName + ": CharacterName was not set and could not be loaded from CharacterManager, this will cause problems!",1)
		EndIf
	EndIf
	If !CharacterRace || _bInvalidRace
		;Debug.Trace("MYC: (" + CharacterName + "/Actor/CheckVars) CharacterRace is missing, getting it from CharacterManager...")
		CharacterRace = CharacterManager.GetCharacterForm(CharacterName,"Race") As Race
		If !CharacterRace
			_bInvalidRace = True
			Race kNordRace = GetFormFromFile(0x00013746,"Skyrim.esm") As Race ; InvisibleRace
			Debug.Trace("MYC/Actor/" + CharacterName + ": CharacterRace was not set and could not be loaded from CharacterManager, this will cause problems! Setting to NordRace until this is fixed...",1)
		Else
			_bInvalidRace = False
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
	
	_iCharGenVersion = SKSE.GetPluginVersion("chargen")
	;Debug.Trace("MYC/Actor/" + CharacterName + ": CharGen version is " + _iCharGenVersion)
	Bool bWasInCity = InCity
	Location kLocation = GetCurrentLocation()
	If kLocation
		InCity = kLocation.HasKeywordString("LocTypeHabitation")
	Else
		InCity = False
	EndIf
EndFunction

Function DoInit(Bool bInBackground = True)
	{Run first time this character is loaded.}
	DoUpkeep(bInBackground)
EndFunction

Function DoUpkeep(Bool bInBackground = True)
	{Run whenever the player loads up the Game. Sets the name and such.}
	SetNameIfNeeded()
	RegisterForModEvent("vMYC_UpdateCharacterSpellList", "OnUpdateCharacterSpellList")
	RegisterForModEvent("vMYC_ConfigUpdate","OnConfigUpdate")
	If bInBackground
		;Debug.Trace("MYC/Actor/" + CharacterName + ": Backgrounding upkeep!")
		_bDoUpkeep = True
		RegisterForSingleUpdate(0.25)
		Return
	EndIf
	GotoState("Busy")
	IsBusy = True
	;Debug.Trace("MYC/Actor/" + CharacterName + ": Starting upkeep...")
	SendModEvent("vMYC_UpkeepBegin")
	If _bInvalidRace 
		; Reset the race during upkeep in case the needed mod has been installed
		CharacterRace = None
		_bInvalidRace = False
	EndIf
	CheckVars()
	SyncCharacterData()
	If !CharacterManager.HasLocalKey(CharacterName,"ShoutsAllowMaster")
		CharacterManager.SetLocalInt(CharacterName,"ShoutsAllowMaster",1) ; allow shouts by default
	EndIf
	SetNonpersistent()
	If _iCharGenVersion >= 3
		RefreshMeshNewCG()
	EndIf
	_bWarnedVoiceTypeNoFollower = False
	_bWarnedVoiceTypeNoSpouse = False
;	If !CharacterManager.HasLocalKey(CharacterName,"TrackingEnabled")
;		If CharacterManager.GetLocalInt(CharacterName,"InAlcove")
;			CharacterManager.SetCharacterTracking(CharacterName,False)
;		Else
;			CharacterManager.SetCharacterTracking(CharacterName,True)
;		EndIf
;	EndIf
	RegisterForSingleUpdate(0.1)
	SendModEvent("vMYC_UpkeepEnd")
	;Debug.Trace("MYC/Actor/" + CharacterName + ": finished upkeep!")
	If !PlayerREF.HasLos(Self)
		RegisterForSingleLOSGain(PlayerREF,Self)
	EndIf
	GotoState("")
EndFunction

Event OnGainLOS(Actor akViewer, ObjectReference akTarget)
	;Extra one because sometimes external heads don't apply correctly the first run
	If _iCharGenVersion >= 3
		RefreshMeshNewCG()
	EndIf
EndEvent

Function DeleteIfOrphaned()
	String sCellName = ""
	If GetParentCell()
		sCellName = GetParentCell().GetName()
	EndIf
	If sCellName == "vMYC_Staging"
		If _bOrphaned && !CharacterManager.GetLocalInt(CharacterName,"IsSummoned") ; Prevent deletion if we got marooned here due to a bad Hangout.
			If GetCurrentRealTime() - _fOrphanedTime > 15
				;Debug.Trace("MYC/Actor/" + CharacterName + ": Orphaned in staging cell for over " + (GetCurrentRealTime() - _fOrphanedTime) as Int + " seconds, nobody loves me! :(")
				UnregisterForUpdate()
				If CharacterManager.GetCharacterActorByName(CharacterName) == Self
					;Debug.Trace("MYC/Actor/" + CharacterName + ": I'm the right actor, so what's up?")
					If (GetCurrentRealTime() - _fOrphanedTime) > 60
						;Debug.Trace("MYC/Actor/" + CharacterName + ": 60 seconds is long enough, I'm outta here!")
						CharacterManager.DeleteCharacterActor(CharacterName)
					EndIf
					Return
				Else
					;Debug.Trace("MYC/Actor/" + CharacterName + ": I'm not even the right actor! I'm " + Self + " but CharacterManager says I should be " + CharacterManager.GetCharacterActorByName(CharacterName) + "! This is terrible! Deleting myself :(")
					Delete()
					Return
				EndIf
			EndIf
		Else
			_bOrphaned = True
			;Debug.Trace("MYC/Actor/" + CharacterName + ": I am apparently orphaned in the staging cell.")
			_fOrphanedTime = GetCurrentRealTime()
		EndIf
		SendModEvent("vMYC_OrphanedActor",CharacterName,_fOrphanedTime)
	Else
		_bOrphaned = False
	EndIf
EndFunction

Function SetNINodes()
	Int jNINodeData = CharacterManager.GetCharacterObj(CharacterName,"NINodeData")
	Int jNiNodeNames = JMap.allKeys(jNINodeData)
	Int jNiNodeScales = JMap.allValues(jNINodeData)
	
	Int i = 0
	Int iNodeCount = JArray.Count(jNiNodeNames)
	While i < iNodeCount
		String sNodeName = JArray.getStr(jNINodeNames,i)
		If sNodeName
			If NetImmerse.HasNode(Self,sNodeName,False)
				;Float NINodeScale = CharacterManager.GetCharacterFlt(CharacterName,"NINodeData." + sNINodes[i] + ".Scale")
				Float NINodeScale = JMap.GetFlt(JArray.getObj(jNiNodeScales,i),"Scale")
				NetImmerse.SetNodeScale(Self,sNodeName,NINodeScale,False)
				NetImmerse.SetNodeScale(Self,sNodeName,NINodeScale,True)
			EndIf
		EndIf
		i += 1
	EndWhile
EndFunction

Function SyncCharacterData()
	If CharacterManager.GetLocalFlt(CharacterName,"PlayTime") != CharacterManager.GetCharacterFlt(CharacterName,"_MYC.PlayTime")
		IsBusy = True
		;Debug.Trace("MYC/Actor/" + CharacterName + ": Our source data has changed!")
		;RemoveAllItems(PlayerREF)
		Int iResult
		CharacterManager.SetLocalFlt(CharacterName,"PlayTime",CharacterManager.GetCharacterFlt(CharacterName,"_MYC.PlayTime"))
		iResult = CharacterManager.ApplyCharacterArmor(CharacterName)
		iResult = CharacterManager.ApplyCharacterWeapons(CharacterName)
		_bNeedInventory = True
		_bNeedSpells = True
		_bNeedShouts = True
		_bNeedPerks = True
	EndIf
EndFunction

Function SetNonpersistent()
	If !Self
		Debug.Trace("MYC/Actor/" + CharacterName + ": Something SERIOUSLY wrong here, our self is missing!",1)
		Return
	EndIf
	;Debug.Trace("MYC/Actor/" + CharacterName + ": Setting name...")
	;SetNameIfNeeded(True)
	;Debug.Trace("MYC/Actor/" + CharacterName + ": Applying perks...")
	Int iSafetyTimer = 10
	_bNeedPerks = True
	_bNeedShouts = True
;	While CharacterManager.ApplyCharacterPerks(CharacterName) < 0 && iSafetyTimer
;		iSafetyTimer -= 1
;		Wait(0.5)
;	EndWhile
;	;Debug.Trace("MYC/Actor/" + CharacterName + ": Applying Shouts...")
;	If CharacterManager.GetLocalInt(CharacterName,"ShoutsAllowMaster")
;		iSafetyTimer = 10
;		While CharacterManager.ApplyCharacterShouts(CharacterName) < 0 && iSafetyTimer
;			iSafetyTimer -= 1
;			Wait(0.5)
;		EndWhile
;	EndIf
	;Debug.Trace("MYC/Actor/" + CharacterName + ": Applying haircolor...")
	ColorForm kHairColor = CharacterManager.GetCharacterForm(CharacterName,"Appearance.Haircolor") As ColorForm
	_kActorBase.SetHairColor(kHairColor)
	If !NIOverride.HasOverlays(Self)
		;Debug.Trace("MYC/Actor/" + CharacterName + ": Adding NIO overlays...")
		CharacterManager.NIO_ApplyCharacterOverlays(CharacterName)
		ApplyNIODye()
	EndIf
	;Debug.Trace("MYC/Actor/" + CharacterName + ": Getting VoiceType from CharacterManager...")
	VoiceType kVoiceType = CharacterManager.GetLocalForm(CharacterName,"VoiceType") As VoiceType
	If !kVoiceType
		kVoiceType = CharacterManager.GetCharacterForm(CharacterName,"VoiceType") As VoiceType
	EndIf
	SetNINodes()
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
			Debug.Trace("MYC/Actor/" + CharacterName + ": Weird, no VoiceType could be found ANYWHERE. What's going on here?",1)
		EndIf
	EndIf
	SetFactions()
	If !CharacterManager.GetCharacterForm(CharacterName,"Class") 
		If CharacterManager.GetLocalInt(CharacterName,"DisableAutoLevel") == 1
			SetCustomActorValues(False)
		ElseIf GetConfigBool("AUTOLEVEL_CHARACTERS")
			SetCustomActorValues(True)
		EndIf
	Else
		;Debug.Trace("MYC/Actor/" + CharacterName + ": has an assigned class, ignoring saved actor values!")
		AddItem(vMYC_DummyArmor, 1, true)
		RemoveItem(vMYC_DummyArmor, 1)
	EndIf
	SetAV("Confidence",3)
	SetAV("Assistance",2)
	;Force stat recalc 
EndFunction

Function CheckArmor(Bool abForce = False)
	Int iArmorCheckLevel = CharacterManager.GetLocalInt(CharacterName,"ArmorCheck")
	If iArmorCheckLevel == 2 ; Disabled
		Return
	EndIf
	Bool bMissingArmor = False
	Int jCharacterArmor = CharacterManager.GetCharacterObj(CharacterName,"Equipment.Armor")
	Int i = JArray.Count(jCharacterArmor)
	;Debug.Trace("MYC/Actor/" + CharacterName + ": Checking " + i + " armor forms!")
	While i > 0
		i -= 1
		Armor kArmor = JArray.GetForm(jCharacterArmor,i) as Armor
		;Debug.Trace("MYC/Actor/" + CharacterName + ":    Checking " + kArmor + "...")
		If kArmor
			;If ArmorCheck == 0 (when missing) then requip it if no armor in slow, if ArmorCheck == 1 requip it any time it's not equipped
			If abForce || (!IsEquipped(kArmor) && ((!GetWornForm(kArmor.GetSlotMask()) && iArmorCheckLevel == 0) || iArmorCheckLevel == 1))
				If GetItemCount(kArmor)
					;Debug.Trace("MYC/Actor/" + CharacterName + ":    Equipping " + kArmor + "!")
					EquipItemEx(kArmor,equipSound = False)
				Else
					;Debug.Trace("MYC/Actor/" + CharacterName + ":    Missing   " + kArmor + "!")
					bMissingArmor = True
				EndIf
			EndIf
		EndIf
	EndWhile
	If bMissingArmor
		CharacterManager.ApplyCharacterArmor(CharacterName)
	EndIf
EndFunction

Function ApplyNIODye()
	Int jArmorInfo = CharacterManager.GetCharacterObj(CharacterName,"Equipment.ArmorInfo")
	Int iArmorIndex = 0
	While iArmorIndex < JArray.Count(jArmorInfo)
		Int jArmor = JArray.GetObj(jArmorInfo,iArmorIndex)
		If JMap.Getform(jArmor,"Form")
			If IsEquipped(JMap.Getform(jArmor,"Form"))
				Int h = (JMap.Getform(jArmor,"Form") as Armor).GetSlotMask()
				Int jNIODyeColors = JValue.solveObj(jArmor,".NIODyeColors")
				If JValue.isArray(jNIODyeColors)
					Int iHandle = NIOverride.GetItemUniqueID(Self, 0, h, True)
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
		iArmorIndex += 1
	EndWhile
EndFunction

Function SetFactions()
	If CharacterManager.GetLocalInt(CharacterName,"IsFoe")
		;Debug.Trace("MYC/Actor/" + CharacterName + ": Hates the player!")
		RemoveFromFaction(CurrentFollowerFaction)
		RemoveFromFaction(PotentialFollowerFaction)
		RemoveFromFaction(PotentialMarriageFaction)
		SetFactionRank(vMYC_CharacterPlayerEnemyFaction,0)
		SetActorValue("Aggression",1)
		SetRelationshipRank(PlayerREF,-4)
	Else
		;Debug.Trace("MYC/Actor/" + CharacterName + ": Likes the player!")
		If GetFactionRank(PotentialFollowerFaction) <= -2 || GetRelationshipRank(PlayerREF) == 0
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
			;Debug.Trace("MYC/Actor/" + CharacterName + ": LOVES the player!")
			SetFactionRank(PotentialMarriageFaction,0)
		EndIf
	EndIf
EndFunction

Function UpdateCombatStyle()
	If IsDisabled()
		;Debug.Trace("MYC/Actor/" + CharacterName + ": UpdateCombatStyle was called but actor is disabled so we can't get weapon type. Try again later!")
		_bNeedCSUpdate = True
		Return
	EndIf
	
	_bNeedCSUpdate = False
	Int iEquippedItemType = GetEquippedItemType(1)
	
	If CharacterManager.GetCharacterInt(CharacterName,"PerkCounts.Blocking") < 2
		;Few blocking perks means that block confers no big advantage or the character is a natural dual-wielder
		CharacterManager.SetLocalInt(CharacterName,"AllowDualWield",1)
	EndIf
	
	_kLastCombatStyle = _kCombatStyle
	CharacterManager.SetLocalInt(CharacterName,"AllowMagic",0)
	If iEquippedItemType < 5 ; One-handed
		If CharacterManager.GetLocalInt(CharacterName,"AllowDualWield")
			_kCombatStyle = vMYC_CombatStyles.GetAt(16) As CombatStyle ; vMYC_csHumanBoss1HDual
		Else
			_kCombatStyle = vMYC_CombatStyles.GetAt(3) As CombatStyle ; Boss1H
		EndIf
	ElseIf iEquippedItemType == 5 || iEquippedItemType == 6
		_kCombatStyle = vMYC_CombatStyles.GetAt(4) As CombatStyle ; Boss2H
	ElseIf iEquippedItemType == 7 || iEquippedItemType == 12
		_kCombatStyle = vMYC_CombatStyles.GetAt(14) As CombatStyle ; Missile
	ElseIf iEquippedItemType == 8|| iEquippedItemType == 9
		_kCombatStyle = vMYC_CombatStyles.GetAt(5) As CombatStyle ; Magic
		CharacterManager.SetLocalInt(CharacterName,"AllowMagic",1)
	Else
		_kCombatStyle = vMYC_CombatStyles.GetAt(1) As CombatStyle ; Tank
	EndIf
	If _kCombatStyle != _kLastCombatStyle
		_kActorBase.SetCombatStyle(_kCombatStyle)
		If CharacterManager.GetLocalInt(CharacterName,"AllowMagic")
			SetAV("Magicka",CharacterManager.GetLocalFlt(CharacterName,"Magicka"))
		Else
			SetAV("Magicka",0)
		EndIf
		;Debug.Trace("MYC: Set " + CharacterName + "'s combatstyle to " + _kCombatStyle)
	EndIf
	CharacterManager.SetLocalForm(CharacterName,"CombatStyle",_kCombatStyle)
	SendModEvent("vMYC_UpdateCharacterSpellList",CharacterName)
EndFunction

Function RefreshMeshNewCG()
	GotoState("Busy")
	;Debug.Trace("MYC/Actor/" + CharacterName + ": is loading CharGen(3) data for " + CharacterName + ". Race is " + CharacterRace)
	While vMYC_CharGenLoading.GetValue()
		;Debug.Trace("MYC/Actor/" + CharacterName + ": Waiting for LoadCharacter to become available...")
		Wait(0.5)
	EndWhile
	;vMYC_CharGenLoading.Mod(1)
	;	Race kDummyRace = GetFormFromFile(0x00067CD8,"Skyrim.esm") as Race ; ElderRace
	;	SetRace(kDummyRace)
	;	Wait(5)
	;	;Debug.Trace("MYC/Actor/" + CharacterName + ": regeneratehead")
	;	RegenerateHead()
	;	Wait(5)
	;CharGen.LoadCharacter(Self, kDummyRace, CharacterName)
	_kActorBase.SetInvulnerable(True)
	Bool _bHasFileSlot = JContainers.fileExistsAtPath("Data/SKSE/Plugins/CharGen/Exported/" + CharacterName + ".jslot")
	If !_bHasFileSlot
		;Check for older RaceMenu save slot
		_bHasFileSlot = JContainers.fileExistsAtPath("Data/SKSE/Plugins/CharGen/Exported/" + CharacterName + ".slot")
	EndIf
	If _bHasFileSlot
		Bool _bHasFileTexture = JContainers.fileExistsAtPath("Data/Textures/CharGen/Exported/" + CharacterName + ".dds")
		If !_bHasFileTexture
			Debug.Notification("Familiar Faces: Missing texture file for " + CharacterName + ".")
		EndIf
		Bool bLCSuccess = CharGenLoadCharacter(Self, CharacterRace, CharacterName)
		Int iSafetyTimer = 30
		If _bInvalidRace
			iSafetyTimer = 1 ; LoadCharacter will fail if the race is missing, so don't let it hang things up.
		EndIf
		While !bLCSuccess && iSafetyTimer > 0
			;Debug.Trace("MYC/Actor/" + CharacterName + ": LoadCharacter failed, retrying...")
			iSafetyTimer -= 1
			Wait(RandomFloat(0.5,2))
			bLCSuccess = CharGenLoadCharacter(Self, CharacterRace, CharacterName)
		EndWhile
		If bLCSuccess 
			;Debug.Trace("MYC/Actor/" + CharacterName + ": LoadCharacter succeeded with " + iSafetyTimer + "tries remaining!")
		EndIf
	Else
		Debug.Notification("Familiar Faces: Missing CharGen slot file for " + CharacterName + ".\nThis character will be disabled.")
		CharacterManager.EraseCharacter(CharacterName,True)
	EndIf
	SetNameIfNeeded()
	;	Wait(5)
	;	;Debug.Trace("MYC/Actor/" + CharacterName + ": regeneratehead")
	;	RegenerateHead()
	;	Wait(5)
	;	;Debug.Trace("MYC/Actor/" + CharacterName + ": queueninodeupdate")
	;	QueueNiNodeUpdate()
	_kActorBase.SetInvulnerable(False)
	;vMYC_CharGenLoading.Mod(-1)
	SendModEvent("vMYC_CharacterReady",CharacterName)
	GotoState("")
EndFunction

Bool Function CharGenLoadCharacter(Actor akActor, Race akRace, String asCharacterName)
	GotoState("CharGenBusy")
	Bool bResult
	Int iDismountSafetyTimer = 10
	While akActor.IsOnMount() && iDismountSafetyTimer
		iDismountSafetyTimer -= 1
		Bool bDismountSent = akActor.Dismount()
		Wait(1)
	EndWhile
	If !iDismountSafetyTimer
		Debug.Trace("MYC: (" + CharacterName + "/Actor) Dismount timer expired!",1)
	EndIf
	If akActor.IsOnMount()
		;Debug.Trace("MYC: (" + CharacterName + "/Actor) Actor is still mounted, will not apply CharGen data!",2)
		GotoState("")
		Return False
	EndIf
	FFUtils.DeleteFaceGenData(Self.GetActorBase())
	;Debug.Trace("MYC: (" + CharacterName + "/Actor) Checking for Data/Meshes/CharGen/Exported/" + asCharacterName + ".nif")
	Bool _bExternalHeadExists = JContainers.fileExistsAtPath("Data/Meshes/CharGen/Exported/" + asCharacterName + ".nif")
	If CharGen.IsExternalEnabled()
		If !_bExternalHeadExists
			Debug.Trace("MYC/Actor/" + CharacterName + ": Warning, IsExternalEnabled is true but no head NIF exists, will use LoadCharacter instead!",1)
			bResult = CharGen.LoadCharacter(akActor,akRace,asCharacterName)
			GotoState("")
			Return bResult
		EndIf
		;Debug.Trace("MYC/Actor/" + CharacterName + ": IsExternalEnabled is true, using LoadExternalCharacter...")
		bResult = CharGen.LoadExternalCharacter(akActor,akRace,asCharacterName)
		GotoState("")
		Return bResult
	Else
		If _bExternalHeadExists
			Debug.Trace("MYC/Actor/" + CharacterName + ": Warning, external head NIF exists but IsExternalEnabled is false, using LoadExternalCharacter instead...",1)
			bResult = CharGen.LoadExternalCharacter(akActor,akRace,asCharacterName)
			GotoState("")
			Return bResult
		EndIf
		;Debug.Trace("MYC/Actor/" + CharacterName + ": IsExternalEnabled is false, using LoadCharacter...")
		bResult = CharGen.LoadCharacter(akActor,akRace,asCharacterName)
		WaitMenuMode(1)
		RegenerateHead()
		GotoState("")
		Return bResult
	EndIf
	GotoState("")
EndFunction

State CharGenBusy

	Bool Function CharGenLoadCharacter(Actor akActor, Race akRace, String asCharacterName)
		Debug.Trace("MYC/Actor/" + CharacterName + ": CharGenLoadCharacter was called more than once!",1)
		Return False
	EndFunction

EndState

Function RefreshMesh()
	GotoState("Busy")
	IsBusy = True
	;Race kDummyRace = GetFormFromFile(0x00071E6A,"Skyrim.esm") as Race ; InvisibleRace
	Race kDummyRace = GetFormFromFile(0x00067CD8,"Skyrim.esm") As Race ; ElderRace
	
	_kActorBase.SetInvulnerable(True)
	
	;Debug.Trace("MYC/Actor/" + CharacterName + ": is loading CharGen(2) data for " + CharacterName + ". Race is " + CharacterRace)
	
	Int iMyTurn = vMYC_CharGenLoading.GetValue() As Int
	vMYC_CharGenLoading.Mod(1)
	_bSwitchedRace = False
	ObjectReference kNowhere = GetFormFromFile(0x02004e4d,"vMYC_MeetYourCharacters.esp") As ObjectReference ; Marker in vMYC_StagingCell
	Activator FXEmptyActivator = GetFormFromFile(0x000b79ff,"Skyrim.esm") As Activator
	
	ObjectReference kHere = PlaceAtMe(FXEmptyActivator)
	
	MoveTo(kNowhere)
	Wait(0.1)
	;Debug.Trace("MYC/Actor/" + CharacterName + ": In staging cell, setting to dummy race...")
	Int iSafetyTimer = 15
	SetRace(kDummyRace)
	;Debug.Trace("MYC/Actor/" + CharacterName + ": Making sure dummy race switch happened...")
	While iSafetyTimer && GetRace().IsRaceFlagSet(0x00000001) ; IsPlayable
		iSafetyTimer -= 1
		Wait(0.25)
	EndWhile
	If iSafetyTimer
		;Debug.Trace("MYC/Actor/" + CharacterName + ": Dummy race switch succeeded!")
	Else
		Debug.Trace("MYC/Actor/" + CharacterName + ": Dummy race switch timed out! Something's not right.",1)
	EndIf
	
	MoveTo(kHere)
	WaitFor3DLoad(Self)
	kHere.Delete()
	;Debug.Trace("MYC/Actor/" + CharacterName + ": We're back, safe and sound!")
	;Debug.Trace("MYC/Actor/" + CharacterName + ": Running LoadCharacter...")
	
	Bool bSuccess = False
	Int iNumTriesRemaining = 5
	While !bSuccess && iNumTriesRemaining
		iNumTriesRemaining -= 1
		_bSwitchedRace = False
		iSafetyTimer = 10
		Bool bLCSuccess = CharGen.LoadCharacter(Self, CharacterRace, CharacterName)
		While !bLCSuccess && iSafetyTimer > 0
			iSafetyTimer -= 1
			Wait(0.5)
			bLCSuccess = CharGen.LoadCharacter(Self, CharacterRace, CharacterName)
		EndWhile
		;Debug.Trace("MYC/Actor/" + CharacterName + ": Got " + bLCSuccess + " from LoadCharacter!")
		iSafetyTimer = 30
		While !_bSwitchedRace && iSafetyTimer > 0
			iSafetyTimer -= 1
			Wait(0.5)
		EndWhile
		If !GetRace().IsRaceFlagSet(0x00000001) ; Playable
			Debug.Trace("MYC/Actor/" + CharacterName + ": Is not a playable race!",1)
		EndIf
		If !iSafetyTimer
			Debug.Trace("MYC/Actor/" + CharacterName + ": LoadCharacter timed out, that's usually not good.",1)
		Else
			;Debug.Trace("MYC/Actor/" + CharacterName + ": LoadCharacter succeeded!")
			bSuccess = True
		EndIf
		If !bSuccess
			Debug.Trace("MYC/Actor/" + CharacterName + ": " + iNumTriesRemaining + " tries remaining...",1)
		EndIf
	EndWhile
	
	If bSuccess
		;Debug.Trace("MYC/Actor/" + CharacterName + ": loaded successfully!")
	Else
		Debug.Trace("MYC/Actor/" + CharacterName + ": FAILED! :(",1)
	EndIf
	vMYC_CharGenLoading.SetValue(0)
	
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
		; LoadCharacter doesn't know about head armor, so sometimes can make a ponytail stick through a hood and such.
		;  This fixes that by un/requipping anything that uses the Hair or Longhair slots
		If kHairEquipment
			EquipItemEx(kHairEquipment,0,True)
		EndIf
		If kLongHairEquipment
			EquipItemEx(kLongHairEquipment,0,True)
		EndIf
	EndIf
	
	SetNameIfNeeded()
	
	_kActorBase.SetInvulnerable(False)
	SendModEvent("vMYC_CharacterReady",CharacterName)
	GotoState("")
EndFunction

Bool Function WaitFor3DLoad(ObjectReference kObjectRef, Int iSafety = 20)
	While !kObjectRef.Is3DLoaded() && iSafety > 0
		iSafety -= 1
		Wait(0.1)
	EndWhile
	Return iSafety As Bool
EndFunction

Function SetCustomActorValues(Bool bScaleToLevel = False)
	;Debug.Trace("MYC/Actor/" + CharacterName + ": setting custom actor values...")
	If CharacterManager.GetLocalInt(CharacterName,"Compat_AFT_Tweaked")
		;Do not attempt to set stats if AFT is installed, as it will just clobber any changes we make
		Return
	EndIf
	String[] sAVNames = CharacterManager.AVNames
	Int iBaseLevel = CharacterManager.GetCharacterStat(CharacterName,"Level") As Int
	If !iBaseLevel
		Debug.Trace("MYC/Actor/" + CharacterName + ": Saved level is 0, not applying custom AVs!",1)
		Return
	EndIf
	Int iMyLevel = GetLevel()
	Float fScaleMult = 1.0
	;Debug.Trace("MYC/Actor/" + CharacterName + ": original actor level is " + iBaseLevel + ", current level is " + iMyLevel)
	Float fCharacterXP = (12.5 * iMyLevel * iMyLevel) + 62.5 * iMyLevel - 75
	;Debug.Trace("MYC/Actor/" + CharacterName + ": needs " + fCharacterXP + " to reach this level!")
	If bScaleToLevel
		;Debug.Trace("MYC/Actor/" + CharacterName + ": Scaling actorValues from level " + iBaseLevel + " to level is " + iMyLevel)
		If iBaseLevel > 0
			fScaleMult = (iMyLevel As Float) / (iBaseLevel As Float)
		EndIf
		Int i
		i = sAVNames.Length ;jArray.Count(jActorValueStrings)
		While i > 0
			i -= 1
			String sAVName = sAVNames[i]
			If sAVNames[i]
				Float fAV = CharacterManager.GetCharacterAV(CharacterName,sAVNames[i])
				If sAVName == "Health" || sAVName == "Magicka" || sAVName == "Stamina"
					fAV = 100 + (((fAV - 100) / (iBaseLevel As Float)) * iMyLevel)
					If fAV < 100
						fAV = 100
					EndIf
					CharacterManager.SetLocalFlt(CharacterName,sAVName,fAV)
					SetActorValue(sAVName,fAV as Int)
				Else
					fAV = 15 + (((fAV - 15) / (iBaseLevel As Float)) * iMyLevel)
					If fAV > 100
						fAV = 100
					ElseIf fAV < 15
						fAV = 15
					EndIf
				EndIf
				SetActorValue(sAVName,fAV As Int)
				;Debug.Trace("MYC: (" + CharacterName + ") Set dummy's " + sAVName + " to " + fAV)
			EndIf
		EndWhile
	Else
		;Don't rescale it, just blindly apply all saved values to the character
		;Debug.Trace("MYC/Actor/" + CharacterName + ": Setting original actorValues from level " + iBaseLevel + " character")
		Int i
		i = sAVNames.Length ;jArray.Count(jActorValueStrings)
		While i > 0
			i -= 1
			String sAVName = sAVNames[i]
			If sAVNames[i]
				Float fAV = CharacterManager.GetCharacterAV(CharacterName,sAVNames[i])
				SetActorValue(sAVName,fAV As Int)
			EndIf
		EndWhile
	EndIf
EndFunction

Function SetNameIfNeeded(Bool abForce = False)
	If (CharacterName && _kActorBase.GetName() != CharacterName) || abForce
		;Debug.Trace("MYC/Actor/" + CharacterName + ": Setting actorbase name!")
		_kActorBase.SetName(CharacterName)
		SetName(CharacterName)
		Int i = GetNumReferenceAliases()
		While i > 0
			i -= 1
			ReferenceAlias kThisRefAlias = GetNthReferenceAlias(i)
			If kThisRefAlias.GetOwningQuest() != CharacterManager && kThisRefAlias.GetOwningQuest() != ShrineOfHeroes
				;Debug.Trace("MYC/Actor/" + CharacterName + ": Resetting RefAlias " + kThisRefAlias + "!")
				kThisRefAlias.TryToClear()
				kThisRefAlias.ForceRefIfEmpty(Self)
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
		;Debug.Trace("MYC/Actor/" + CharacterName + ": OnLoad called in Busy state!")
	EndEvent
	
	Event OnUnload()
		;Debug.Trace("MYC/Actor/" + CharacterName + ": OnUnload called in Busy state!")
	EndEvent
	
	;Function DoUpkeep(Bool bInBackground = True)
	;	;Debug.Trace("MYC/Actor/" + CharacterName + ": DoUpkeep called in Busy state!")
	;EndFunction
	
EndState
