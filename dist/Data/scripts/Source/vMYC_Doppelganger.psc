Scriptname vMYC_Doppelganger extends Actor
{Apply character appearance, handle inventory import, etc.}

;=== Imports ===--

Import Utility
Import Game
Import vMYC_Registry

;=== Constants ===--

;=== Properties ===--

Bool Property IsAvailable Hidden
{Return whether this actor has been assigned a character.}
	Bool Function Get()
		If GetState() == "Available"
			Return True
		Else
			Return False
		EndIf
	EndFunction
EndProperty

String Property ScriptState Hidden
{Return this actor's script state.}
	String Function Get()
		Return GetState()
	EndFunction
EndProperty

Bool 				Property NeedAppearance	= False 				Auto Hidden
Bool 				Property NeedPerks		= False 				Auto Hidden
Bool 				Property NeedSpells		= False 				Auto Hidden
Bool 				Property NeedEquipment	= False 				Auto Hidden
Bool 				Property NeedInventory	= False 				Auto Hidden
Bool 				Property NeedRefresh 	= False 				Auto Hidden
Bool 				Property NeedReset 		= False 				Auto Hidden
Bool				Property NeedUpkeep		= False					Auto Hidden

Bool 				Property IsBusy 		= False 				Auto Hidden
Bool 				Property IsCharGenBusy	= False 				Auto Hidden
Bool 				Property IsInCity		= False 				Auto Hidden
Bool				Property IsRaceInvalid	= False					Auto Hidden

String 				Property CharacterName	= ""					Auto Hidden
String 				Property CharacterUUID	= ""					Auto Hidden
Race				Property CharacterRace	= None					Auto Hidden

Actor 				Property PlayerREF 									Auto
Armor 				Property vMYC_DummyArmor							Auto
EffectShader 		Property vMYC_BlindingLightGold						Auto
Explosion 			Property vMYC_CharacterDeathExplosion				Auto
VisualEffect		Property vMYC_ValorFX								Auto
VisualEffect		Property DA02SummonValorTargetFX					Auto
ImageSpaceModifier	Property ISMDwhiteoutFULLthenFade					Auto
Sound				Property NPCDragonDeathFX2D							Auto
Sound				Property NPCDragonDeathSequenceExplosion			Auto
FormList 			Property vMYC_CombatStyles 							Auto
FormList 			Property vMYC_ModCompatibility_SpellList_Safe 		Auto
FormList 			Property vMYC_ModCompatibility_SpellList_Unsafe 	Auto
FormList 			Property vMYC_ModCompatibility_SpellList_Healing 	Auto
FormList 			Property vMYC_ModCompatibility_SpellList_Armor 		Auto
Message 			Property vMYC_VoiceTypeNoFollower 					Auto
Message 			Property vMYC_VoiceTypeNoSpouse						Auto

;=== Variables ===--

ActorBase 	_kActorBase 				= None
		
Bool 		_bFirstLoad 				= True
				
String[] 	_sSkillNames

Float 		_fDecapitationChance

Int 		_iMagicUpdateCounter

Float 		_fOrphanedTime
Bool 		_bOrphaned

CombatStyle _kCombatStyle
CombatStyle _kLastCombatStyle

Int 		_iCharGenVersion

Int			_jCharacterData

String 		_sCharacterInfo

;=== Events ===--

Event OnInit()
	_kActorBase = GetActorBase()
EndEvent

Event OnUpdate()
	If NeedUpkeep
		DoUpkeep(False)
	EndIf
EndEvent

Auto State Available
	Event OnLoad()
		;Clear out because we shouldn't be loaded
	EndEvent
	
	Function AssignCharacter(String sUUID)
	{This is the biggie, calling this in Available state will transform the character into the target in sUUID.}
		GoToState("Busy")
		_jCharacterData = GetRegObj("Characters." + sUUID)
		_sCharacterInfo = "Characters." + sUUID + ".Info."
		SaveSession()
		If !_jCharacterData
			DebugTrace("AssignCharacter(" + sUUID + ") was called in Available state, but there's no data for that UUID!")
			GotoState("Available")
			Return
		EndIf
		DebugTrace("AssignCharacter(" + sUUID + ") was called in Available state, transforming into " + GetRegStr(_sCharacterInfo + "Name") + "!")
		SetRegForm("Doppelgangers.Preferred." + sUUID + ".ActorBase",_kActorBase)
		SetSessionForm("Doppelgangers." + sUUID + ".ActorBase",_kActorBase)
		SetSessionForm("Doppelgangers." + sUUID + ".Actor",Self as Actor)
		CharacterName = GetRegStr(_sCharacterInfo + "Name")
		CharacterRace = GetRegForm(_sCharacterInfo + "Race") as Race
		_kActorBase.SetName(CharacterName)
		NeedAppearance	= True
		NeedPerks		= True
		NeedSpells		= True
		NeedEquipment	= True
		NeedInventory	= True
		NeedRefresh 	= True
		NeedUpkeep		= True
		GotoState("Assigned")
	EndFunction
EndState

State Assigned
	Event OnBeginState()
		DebugTrace("Entered Assigned state! CharacterName is " + CharacterName + ". Will update appearance, etc in just a sec...")
		RegisterForSingleUpdate(1)
		SetNameIfNeeded()
	EndEvent

	Event OnUpdate()
		If NeedAppearance
			UpdateAppearance()
		EndIf
	EndEvent

	Event OnLoad()
		
	EndEvent
EndState

State Busy

EndState

Function AssignCharacter(String sUUID)
{This is the biggie, calling this in Available state will transform the character into the target in sUUID.}
	DebugTrace("AssignCharacter(" + sUUID + ") was called outside of Available state, doing nothing!",1)
EndFunction

Function DoUpkeep(Bool bInBackground = True)
{Run whenever the player loads up the Game. Sets the name and such.}
	RegisterForModEvent("vMYC_UpdateCharacterSpellList", "OnUpdateCharacterSpellList")
	RegisterForModEvent("vMYC_ConfigUpdate","OnConfigUpdate")
	If bInBackground
		
		NeedUpkeep = True
		RegisterForSingleUpdate(0)
		Return
	EndIf
	GotoState("Busy")
	IsBusy = True
	;DebugTrace("MYC/Actor/" + CharacterName + ": Starting upkeep...")
	SendModEvent("vMYC_UpkeepBegin")
	If IsRaceInvalid 
		; Reset the race during upkeep in case the needed mod has been installed
		CharacterRace = None
		IsRaceInvalid = False
	EndIf
	;CheckVars()
	;SyncCharacterData()
	If !HasSessionKey(CharacterName + ".Shouts.Allow")
		SetSessionBool(CharacterName + ".Shouts.Allow",True) ; allow shouts by default
	EndIf
;	SetNonpersistent()
	If _iCharGenVersion == 3
;		RefreshMeshNewCG()
	EndIf
;	_bWarnedVoiceTypeNoFollower = False
	;_bWarnedVoiceTypeNoSpouse = False
	RegisterForSingleUpdate(0.1)
	SendModEvent("vMYC_UpkeepEnd")
	;DebugTrace("MYC/Actor/" + CharacterName + ": finished upkeep!")
	If !PlayerREF.HasLos(Self)
		RegisterForSingleLOSGain(PlayerREF,Self)
	EndIf
	GotoState("")
EndFunction

Function SetNameIfNeeded(Bool abForce = False)
	If (CharacterName && _kActorBase.GetName() != CharacterName) || abForce
		DebugTrace("Setting actorbase name!")
		_kActorBase.SetName(CharacterName)
		SetName(CharacterName)
		;FIXME: This will need to be reenabled, just disabling now to simply things
		;Int i = GetNumReferenceAliases()
		;While i > 0
		;	i -= 1
		;	ReferenceAlias kThisRefAlias = GetNthReferenceAlias(i)
		;	;If kThisRefAlias.GetOwningQuest() != CharacterManager && kThisRefAlias.GetOwningQuest() != ShrineOfHeroes
		;		DebugTrace("Resetting RefAlias " + kThisRefAlias + "!")
		;		kThisRefAlias.TryToClear()
		;		kThisRefAlias.ForceRefIfEmpty(Self)
		;	;EndIf
		;EndWhile
		SendModEvent("vMYC_UpdateXFLPanel")
	EndIf
EndFunction

;=== Appearance functions ===--

Int Function UpdateAppearance()
	Bool _bInvulnerableState = _kActorBase.IsInvulnerable()
	Bool _bCharGenSuccess = False
	_kActorBase.SetInvulnerable(True)
	_bCharGenSuccess = CharGenLoadCharacter(Self,CharacterRace,CharacterName)
	_kActorBase.SetInvulnerable(_bInvulnerableState)
	If _bCharGenSuccess
		Return 0
	Else
		DebugTrace("Something went wrong during UpdateAppearance!",1)
		;FIXME: Add more error handling like checking for missing files, etc
		Return -1
	EndIf
EndFunction

Bool Function CharGenLoadCharacter(Actor akActor, Race akRace, String asCharacterName)
	;Debug.Trace("MYC/Actor/" + CharacterName + ": CharGenLoadCharacter was called more than once!",1)
	;	Return False
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

Bool Function WaitFor3DLoad(ObjectReference kObjectRef, Int iSafety = 20)
	While !kObjectRef.Is3DLoaded() && iSafety > 0
		iSafety -= 1
		Wait(0.1)
	EndWhile
	Return iSafety As Bool
EndFunction

;=== Utility functions ===--

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	If CharacterName
		Debug.Trace("MYC/Doppelganger/" + CharacterName + ": " + sDebugString,iSeverity)
	Else
		Debug.Trace("MYC/Doppelganger/" + Self.GetFormID() + ": " + sDebugString,iSeverity)
	EndIf
EndFunction

