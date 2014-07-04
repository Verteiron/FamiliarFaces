Scriptname vMYC_ShrineAlcoveController extends ObjectReference
{Handle alcove activation/deactivation effects}

;--=== Imports ===--

Import Utility
Import Game

;--=== Properties ===--

Int	Property AlcoveIndex Hidden
{Which alcove am I?}
	Int Function Get()
		Return _iAlcoveIndex
	EndFunction
	Function Set(Int iAlcoveIndex)
		_iAlcoveIndex = iAlcoveIndex
		;Debug.Trace("MYC/Shrine/Alcove" + Self + ": I am Alcove #" + _iAlcoveIndex + "!")
		SendModEvent("vMYC_AlcoveStatusUpdate",0)
		RegisterForSingleUpdate(1)
	EndFunction
EndProperty

String	Property CharacterName Hidden
{Which Character lives here?}
	String Function Get()
		Return _sCharacterName
	EndFunction
	Function Set(String sCharacterName)
		_sCharacterName = sCharacterName
		RegisterForModEvent("vMYC_SetAlcoveCharacterName","OnSetAlcoveCharacterName")
		SendModEvent("vMYC_SetAlcoveCharacterName",sCharacterName)
	EndFunction
EndProperty

Int Property AlcoveState Hidden
{0 = Empty, 1 = Loading, 2 = Ready, 3 = Summoned, 4 = Error}
	Int Function Get()
		Return _iAlcoveState
	EndFunction
	Function Set(Int iAlcoveState)
		_iAlcoveState = iAlcoveState
		SendModEvent("vMYC_AlcoveStatusUpdate",_iAlcoveState)
	EndFunction
EndProperty

Int Property AlcoveStatueState Hidden
{0 = None, 1 = Loading, 2 = Loaded and placed}
	Int Function Get()
		Return _iAlcoveStatueState
	EndFunction
	Function Set(Int iAlcoveStatueState)
		RegisterForModEvent("vMYC_ShrineStatueStateChange","OnAlcoveStatueStateChange")
		SendModEvent("vMYC_ShrineStatueStateChange","",iAlcoveStatueState)
	EndFunction
EndProperty

Int Property AlcoveLightState Hidden
{0 = Dark, 1 = FullLight, 2 = TorchLight}
	Int Function Get()
		Return _iAlcoveLightState
	EndFunction
	Function Set(Int iAlcoveLightState)
		RegisterForModEvent("vMYC_ShrineLightStateChange","OnAlcoveLightStateChange")
		SendModEvent("vMYC_ShrineLightStateChange","",iAlcoveLightState)
	EndFunction
EndProperty


vMYC_CharacterManagerScript 	Property CharacterManager 	Auto
vMYC_ShrineOfHeroesQuestScript 	Property ShrineOfHeroes 	Auto

Actor 			Property 	PlayerREF					Auto

Activator		Property	vMYC_PerkGlow				Auto

ActorBase		Property	vMYC_InvisibleMActor		Auto
ActorBase		Property	vMYC_InvisibleFActor		Auto

Bool			Property	CharacterSummoned			Auto Hidden

EffectShader 	Property 	vMYC_BlindingLight					Auto
EffectShader 	Property 	vMYC_BlindingLightGold				Auto
EffectShader 	Property 	vMYC_BlindingLightSkinOnly			Auto
EffectShader	Property	vMYC_BlindingLightInwardParticles	Auto

Explosion		Property	vMYC_BookDustExplosion				Auto

Formlist		Property	vMYC_TrophyKeywords					Auto

VisualEffect	Property	MAGDragonPowerAbsorbEffect 			Auto
VisualEffect	Property	MAGDragonPowerAbsorbManEffect 		Auto
VisualEffect	Property	FXGreybeardAbsorbEffect 			Auto
VisualEffect	Property 	AbsorbCastVFX01						Auto
VisualEffect	Property 	AbsorbTargetVFX01					Auto
VisualEffect	Property 	AbsorbBlueCastVFX01					Auto
VisualEffect	Property 	AbsorbBlueTargetVFX01				Auto
VisualEffect	Property 	AbsorbGreenCastVFX01				Auto
VisualEffect	Property 	AbsorbGreenTargetVFX01				Auto
VisualEffect	Property 	vMYC_SpellAbsorbTargetVFX			Auto
VisualEffect	Property 	DA02SummonValorTargetFX				Auto
VisualEffect	Property	vMYC_ValorFX						Auto

Keyword 		Property 	vMYC_ShrineBook				Auto
Keyword 		Property 	vMYC_ShrineFog 				Auto
Keyword 		Property 	vMYC_ShrineFurnishing 		Auto
Keyword 		Property 	vMYC_ShrineLight 			Auto
Keyword 		Property 	vMYC_ShrineLightingMaster	Auto
Keyword 		Property 	vMYC_ShrineTorches 			Auto
Keyword			Property	vMYC_ShrineCurtain			Auto

Keyword 		Property 	vMYC_ShrineTrophyHero			Auto
Keyword 		Property 	vMYC_ShrineTrophyBard			Auto
Keyword 		Property 	vMYC_ShrineTrophyBlade			Auto
Keyword 		Property 	vMYC_ShrineTrophyCompanion		Auto
Keyword 		Property 	vMYC_ShrineTrophyGreybeard		Auto
Keyword 		Property 	vMYC_ShrineTrophyImperial		Auto
Keyword 		Property 	vMYC_ShrineTrophyMage			Auto
Keyword 		Property 	vMYC_ShrineTrophyStormcloak		Auto
Keyword 		Property 	vMYC_ShrineTrophyThief			Auto
Keyword 		Property 	vMYC_ShrineTrophyDBRestored		Auto
Keyword 		Property 	vMYC_ShrineTrophyDBDestroyed	Auto

Keyword 		Property 	vMYC_ShrineTrophyThaneDawnstar	Auto
Keyword 		Property 	vMYC_ShrineTrophyThaneFalkreath	Auto
Keyword 		Property 	vMYC_ShrineTrophyThaneMarkarth	Auto
Keyword 		Property 	vMYC_ShrineTrophyThaneMorthal	Auto
Keyword 		Property 	vMYC_ShrineTrophyThaneWhiterun	Auto

Keyword 		Property 	vMYC_ShrineTrophyVampireSymbol	Auto
Keyword 		Property 	vMYC_ShrineTrophyWerewolfSymbol	Auto
Keyword 		Property 	vMYC_ShrineTrophyDLC1Dawnguard	Auto
Keyword 		Property 	vMYC_ShrineTrophyDLC1Vampire	Auto
Keyword 		Property 	vMYC_ShrineTrophyDLC1Complete	Auto
Keyword 		Property 	vMYC_ShrineTrophyDLC2Miraak		Auto

Idle			Property	IdleStaticPoseA				Auto
Idle			Property	AscendMale					Auto
Idle			Property	AscendFemale				Auto
Idle			Property	IdleStop_loose				Auto
Idle			Property	IdleSnapToAttention			Auto
Idle			Property	IdleSilentBow				Auto
Idle			Property	IdleSalute					Auto
Idle			Property	CombatIdleStretching		Auto

ImageSpaceModifier	Property	vMYC_ShrineLightISMD			Auto
ImageSpaceModifier	Property	vMYC_ShrineLightWhiteoutISMD	Auto


SoundCategory	Property	AudioCategorySFX			Auto

Sound			Property	QSTMG07MagnusStormCollegeMediumLPM		Auto
Sound			Property	QSTMG07MagnusStormCollegeMediumRelease	Auto
Sound			Property	QSTBeamMeridiaStatueLP					Auto
Sound			Property	QSTDA09LightBeamOn						Auto
Sound			Property	QSTDA09LightBeamOff						Auto
Sound			Property	vMYC_QSTTG09BeamAbilitiesColumnLPSM		Auto
Sound			Property	vMYC_QSTTG09BeamAbilitiesColumnStartSM	Auto
Sound			Property	QSTMQ206TimeTravel2DSound				Auto

;--=== Variables ===--

Actor 			_kCharacter
Actor			_kInvisibleActor
Actor[]			_kInvisibleActors

Bool 			_bLoaded
Bool			_bActivateOnLoad
Bool			_bPlayerIsSaving
Bool			_bPoseCharacter
Bool			_bFreezeCharacter
Bool			_bCharacterReady
Bool			_bForceSave
Bool			_bSavedEquipment
Bool			_bSavedPerks
Bool			_bSavedInventory
Bool			_bSavedSpells
Bool			_bCharacterSummoned

ObjectReference	_FogBlowing
ObjectReference	_FogEmpty

ObjectReference	_StatueMarker

vMYC_CharacterBookActiScript	_Book

ObjectReference	_Light

ObjectReference _Torches

ObjectReference	_Curtain

Int				_jMYC

Int				_iAlcoveIndex = -1
Int				_iInvisibleActorIndex

Int				_iAlcoveState = 0 	; 0 = Empty, 1 = Loading, 2 = Ready, 3 = Summoned, 4 = Error
Int				_iAlcoveLightState = 0 	; 0 = empty, 1 = lights on, 2 = torches
Int				_iAlcoveStatueState = 0	; 0 = None, 1 = loading, 2 = ready


Float 			_LightX
Float 			_LightY
Float 			_LightZ

ObjectReference	_LightAmbientTarget

String			_sCharacterName

Int				_iQSTMG07MagnusStormCollegeMediumLPM
Int				_iQSTBeamMeridiaStatueLP

Int 			_iAlcoveToSwap = -1

;--=== Events and Functions ===--


Function CheckVars()
	_FogEmpty = GetLinkedRef(vMYC_ShrineFog)
	_FogBlowing = _FogEmpty.GetLinkedRef(vMYC_ShrineFog)
	_Torches = GetLinkedRef(vMYC_ShrineTorches)
	_StatueMarker = GetLinkedRef(vMYC_ShrineFurnishing)
	_Curtain = GetLinkedRef(vMYC_ShrineCurtain)
	If !_kInvisibleActors
		_kInvisibleActors = New Actor[32]
		_iInvisibleActorIndex = _kInvisibleActors.Length
	EndIf
	If !_Book
		_Book = GetLinkedRef(vMYC_ShrineBook) as vMYC_CharacterBookActiScript
	EndIf
	If _Book.AlcoveIndex != AlcoveIndex
		_Book.AlcoveIndex = AlcoveIndex
	EndIf
	If !_Light
		_Light = GetLinkedRef(vMYC_ShrineLight)
		_LightX = _Light.GetPositionX()
		_LightY = _Light.GetPositionY()
		_LightZ = _Light.GetPositionZ()
		_LightAmbientTarget	= _Light.GetLinkedRef()
		_Light.MoveTo(_LightAmbientTarget)
	EndIf
EndFunction

Event OnInit()
	CheckVars()
EndEvent

Event OnLoad()
	CheckVars()
	If !CharacterName
		AlcoveState = 0
	ElseIf AlcoveStatueState == 0
		ActivateAlcove()
	EndIf
	If AlcoveState == 3
		_Book.IsOpen = True
	Else
		_Book.IsOpen = False
	EndIf
	RegisterForModEvents()
EndEvent

Function RegisterForModEvents()
	RegisterForModEvent("vMYC_AlcoveLightingPriority","OnAlcoveLightingPriority")
	RegisterForModEvent("vMYC_AlcoveValidateState","OnAlcoveValidateState")
EndFunction

Function DoUpkeep()
	RegisterForModEvents()
	If AlcoveState == 3
		CharacterManager.SetLocalInt(_sCharacterName,"IsSummoned",1)
		_bCharacterSummoned = True
	EndIf
EndFunction

Event OnAlcoveLightingPriority(string eventName, string strArg, float numArg, Form sender)
{Disable the lights of all Alcoves except the event sender to try to give its lighting effects top priority}
	;strArg = numArg = AlcoveIndex of sender
	Int iRequestingIndex = numArg as Int
	If iRequestingIndex != AlcoveIndex && strArg == "Request"
		If AlcoveLightState == 2
			_Torches.DisableNoWait(True)
			GetLinkedRef(vMYC_ShrineLightingMaster).DisableNoWait(True)
		EndIf
		If AlcoveLightState > 0
			_Light.DisableNoWait(True)
		EndIf
	ElseIf iRequestingIndex != AlcoveIndex && strArg == "Release"
		If AlcoveLightState == 2
			_Torches.EnableNoWait(True)
			GetLinkedRef(vMYC_ShrineLightingMaster).EnableNoWait(True)
		EndIf
		If AlcoveLightState > 0
			_Light.EnableNoWait(True)
		EndIf
	EndIf
EndEvent

Event OnSetAlcoveCharacterName(string eventName, string strArg, float numArg, Form sender)
{Event to allow setting the CharacterName property to be deferred.}
	If sender == Self
		SetAlcoveCharacterName(strArg)
	EndIf
EndEvent

Function SetAlcoveCharacterName(string sCharacterName)
{This (un)sets the Alcove's character name}
	_sCharacterName = sCharacterName
EndFunction

Event OnCellAttach()
	If AlcoveLightState == 1
		If AlcoveState == 2 || AlcoveState == 3
			AlcoveLightState = 2
		ElseIf AlcoveState == 0
			AlcoveLightState = 0
		EndIf
	EndIf
		
EndEvent

Event OnAttachedToCell()
EndEvent

Event OnUpdate()
	If ShrineOfHeroes.Ready
		CharacterName = ShrineOfHeroes.GetAlcoveStr(AlcoveIndex,"CharacterName")
		CheckVars()
		_Book.AlcoveIndex = AlcoveIndex
		InitTrophies()
		If CharacterName
			ActivateAlcove()
		EndIf
	Else
		;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": ShrineOfHeroes is NOT ready, will try again in a second :(")
		RegisterForSingleUpdate(1.0)
	EndIf
EndEvent

Event OnAlcoveValidateState(string eventName, string strArg, float numArg, Form sender)
	;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": OnAlcoveValidateState!")
	If AlcoveLightState == 1 && !_bPlayerIsSaving
		If AlcoveState == 0
			Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": ValidateState: Lighting state was 1, should be 0!")
			AlcoveLightState = 0
			HideTrophies()
		ElseIf AlcoveState == 2 || AlcoveState == 3
			Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": ValidateState: Lighting state was 1, should be 2!")
			AlcoveLightState = 2
			ShowTrophies()
		EndIf
	EndIf
EndEvent

Event OnUnload()
EndEvent

Event OnAlcoveLightStateChange(string eventName, string strArg, float numArg, Form sender)
{numArg: 0 = Dark, 1 = Full light, 2 = Torch light}
	If sender != Self || numArg as Int == _iAlcoveLightState
		Return
	EndIf
	Bool bUseTranslation = True
	If !Is3DLoaded()
		bUseTranslation = False
	EndIf
	Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Setting light state to " + numArg as Int + ", current state is " + _iAlcoveLightState)
	Int iOldLightState = _iAlcoveLightState
	Int iLightState = numArg as Int
	_LightAmbientTarget	= _Light.GetLinkedRef()

	If _Light.IsDisabled() && iLightState > 0
		_Light.Enable()
		Int iSafety = 0
		While !_Light.Is3DLoaded() && iSafety < 4
			iSafety += 1
			Wait(0.1)
		EndWhile
	EndIf

	If iLightState != 1
		_Curtain.DisableNoWait(True)
	EndIf
	
	If iLightState != 2
		_Torches.DisableNoWait(True)
		GetLinkedRef(vMYC_ShrineLightingMaster).DisableNoWait(True)
	Else
		_Torches.EnableNoWait(True)
		GetLinkedRef(vMYC_ShrineLightingMaster).EnableNoWait(True)
	EndIf

	If iLightState == 1 && _Light.GetDistance(_LightAmbientTarget) < 10
		If bUseTranslation
			_Light.TranslateTo(_LightX,_LightY,_LightZ,0,0,0,150)
		Else
			_Light.SetPosition(_LightX,_LightY,_LightZ)
		EndIf
	ElseIf iLightState == 0 || iLightState == 2
		If _iQSTMG07MagnusStormCollegeMediumLPM
			Sound.StopInstance(_iQSTMG07MagnusStormCollegeMediumLPM)
			_iQSTMG07MagnusStormCollegeMediumLPM = 0
		EndIf
		If bUseTranslation
			QSTMG07MagnusStormCollegeMediumRelease.Play(_Light)
			_Light.TranslateToRef(_LightAmbientTarget,300)
		Else
			_Light.MoveTo(_LightAmbientTarget)
		EndIf
	EndIf

	If iLightState == 2
		_FogEmpty.Disable(True)
		_FogBlowing.DisableNoWait(True)
	Else
		_FogEmpty.Enable(True)
		_FogBlowing.EnableNoWait(True)
	EndIf

	If iLightState == 1
		Wait(1.5)
		If !_iQSTMG07MagnusStormCollegeMediumLPM && bUseTranslation
			_iQSTMG07MagnusStormCollegeMediumLPM = QSTMG07MagnusStormCollegeMediumLPM.Play(_Light)
		EndIf
		Wait(1.5)
		_Curtain.EnableNoWait(True)
	EndIf

	If iLightState == 0
		Wait(2)
		_Light.DisableNoWait()
	EndIf

	If !Is3DLoaded() && bUseTranslation ;We got unloaded mid-transition, probably because the player is naughty. Rerun with bUseTranslation off!
		OnAlcoveLightStateChange(eventName, strArg, numArg, sender)
	EndIf
	_iAlcoveLightState = iLightState ; Set internal property value
	Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Set light state to " + _iAlcoveLightState + "!")
	RegisterForModEvent("vMYC_AlcoveLightStateComplete","OnAlcoveLightStateComplete")
	SendModEvent("vMYC_AlcoveLightStateComplete","",_iAlcoveLightState)
EndEvent

Event OnAlcoveLightStateComplete(string eventName, string strArg, float numArg, Form sender)
	If sender != Self
		Return
	EndIf
	WaitMenuMode(2)
	;Extras for safety
	If _iAlcoveLightState != 1
		_Curtain.DisableNoWait(True)
	EndIf
	If (_iAlcoveLightState == 0 || _iAlcoveLightState == 2) && _iQSTMG07MagnusStormCollegeMediumLPM
		Sound.StopInstance(_iQSTMG07MagnusStormCollegeMediumLPM)
		_iQSTMG07MagnusStormCollegeMediumLPM = 0
	EndIf
EndEvent

Event OnAlcoveStatueStateChange(string eventName, string strArg, float numArg, Form sender)
{numArg: 0 = Dark, 1 = Full light, 2 = Torch light}
	If sender != Self || numArg as Int == _iAlcoveStatueState
		Return
	EndIf
	Int iStatueState = numArg as Int
	_iAlcoveStatueState = iStatueState ; Set internal property value
	SendModEvent("vMYC_AlcoveStatueStateComplete","",_iAlcoveStatueState)
EndEvent

Event OnAlcoveBackground(string eventName, string strArg, float numArg, Form sender)
	If sender != Self
		Return
	EndIf
	If strArg == "Activate"
		ActivateAlcove(numArg as Int,False)
	ElseIf strArg == "Deactivate"
		DeactivateAlcove(numArg as Int,False)
	EndIf
EndEvent

;==== Functions/Events for loading the character statue ====----

Function ActivateAlcove(Bool abAutoLights = True, Bool abBackground = True)
	If abBackground
		;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Activating in background...")
		RegisterForModEvent("vMYC_AlcoveBackground","OnAlcoveBackground")
		SendModEvent("vMYC_AlcoveBackground","Activate",abAutoLights as Int)
		Return
	EndIf
	If !_sCharacterName
		;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Activated but has no character living in it. Aborting!")
		AlcoveState = 0
		HideTrophies()
		Return
	EndIf
	Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Activating. Auto lights:" + abAutoLights)
	If abAutoLights
		AlcoveLightState = 1
	EndIf
	AlcoveState = 1
	AlcoveStatueState = 1
	_kCharacter = CharacterManager.GetCharacterActorByName(_sCharacterName)
	If !_kCharacter
		If !CharacterManager.LoadCharacter(_sCharacterName)
			AlcoveState = 4
			If abAutoLights
				While AlcoveLightState != 1
					Wait(1.0)
				EndWhile
				AlcoveLightState = 0
			EndIf
			Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": " + _sCharacterName + " could not be loaded from CharacterManager.",1)
			CharacterName = ""
			Return
		EndIf
	EndIf
	_kCharacter = CharacterManager.GetCharacterActorByName(_sCharacterName)
	If CharacterManager.GetLocalInt(_sCharacterName,"IsSummoned")
		_bCharacterSummoned = True
	EndIf
	If !_bCharacterSummoned ; make sure we don't yank the character back if they're summoned already
		CharacterManager.SetLocalInt(_sCharacterName,"InAlcove",1)
		_kCharacter.SetGhost(True)
		_kCharacter.SetScale(1.2)
		_kCharacter.EnableAI(True)
		_kCharacter.Moveto(_StatueMarker)
		_kCharacter.EnableNoWait()
		_bPoseCharacter = True
		AlcoveState = 2
	EndIf
	RegisterForModEvent("vMYC_CharacterReady","OnCharacterReady")
	ShowTrophies()
	If _bCharacterSummoned
		_Book.IsOpen = True
		AlcoveState = 3
		If abAutoLights
			While AlcoveLightState != 1
				Wait(1.0)
			EndWhile
			AlcoveLightState = 2
		EndIf
	EndIf
EndFunction

Function DeactivateAlcove(Bool abAutoLights = True, Bool abBackground = True)
	If abBackground
		;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Deactivating in background...")
		RegisterForModEvent("vMYC_AlcoveBackground","OnAlcoveBackground")
		SendModEvent("vMYC_AlcoveBackground","Deactivate",abAutoLights as Int)
		Return
	EndIf
	Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Deactivating. Auto lights:" + abAutoLights)
	If _kCharacter && !_bCharacterSummoned ; make sure we don't yank the character back if they're summoned
		ObjectReference kNowhere = GetFormFromFile(0x02004e4d,"vMYC_MeetYourCharacters.esp") as ObjectReference ; Marker in vMYC_StagingCell
		_kCharacter.MoveTo(kNowhere)
	EndIf
	AlcoveState = 1
	If abAutoLights
		AlcoveLightState = 0
	EndIf
	If _bCharacterSummoned
		_Book.IsOpen = False
	EndIf
	_bCharacterSummoned = False
	CharacterManager.SetLocalInt(_sCharacterName,"InAlcove",0)
	SendModEvent("vMYC_ForceBookUpdate","",AlcoveIndex)
;	_Curtain.Enable(True)
	HideTrophies()
	AlcoveState = 0
	AlcoveStatueState = 0
	_Curtain.DisableNoWait()
EndFunction

Event OnCharacterReady(string eventName, string strArg, float numArg, Form sender)
	If strArg == _sCharacterName
		_bCharacterReady = True
	EndIf
	If strArg == _sCharacterName && _bPoseCharacter && !_bCharacterSummoned
		_bPoseCharacter = False
		;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Character reports they are ready!")
		vMYC_BlindingLightInwardParticles.Play(_kCharacter,0.5)

		Debug.SendAnimationEvent(_kCharacter,"IdleStaticPoseAStart") ;_kCharacter.PlayIdle(IdleStaticPoseA)
		Wait(0.25)
		_kCharacter.SetGhost(True)
		_kCharacter.EnableAI(False)

		AlcoveStatueState = 2
		AlcoveLightState = 2
	EndIf
EndEvent

Bool Function WaitFor3DLoad(ObjectReference kObjectRef, Int iSafety = 20)
	While !kObjectRef.Is3DLoaded() && iSafety > 0
		iSafety -= 1
		Wait(0.1)
	EndWhile
	Return iSafety as Bool
EndFunction



Function WaitForCharacterReady(Int iSafety = 30)
	_bCharacterReady = False
	RegisterForModEvent("vMYC_CharacterReady","OnCharacterReady")
	While !_bCharacterReady && iSafety > 0
		iSafety -= 1
		Wait(0.1)
	EndWhile
EndFunction

;==== Functions/Events for the character save process ====----

Function SavePlayer(Bool abForceSave = False)
	_bForceSave = abForceSave
	_bPlayerIsSaving = True
	RegisterForModEvent("vMYC_PerksSaveBegin","OnPerksSaveBegin")
	RegisterForModEvent("vMYC_PerkSaved","OnPerkSaved")
	RegisterForModEvent("vMYC_PerksSaveEnd","OnPerksSaveEnd")
	RegisterForModEvent("vMYC_SpellsSaveBegin","OnSpellsSaveBegin")
	RegisterForModEvent("vMYC_SpellSaved","OnSpellSaved")
	RegisterForModEvent("vMYC_SpellsSaveEnd","OnSpellsSaveEnd")
	RegisterForModEvent("vMYC_EquipmentSaveBegin","OnEquipmentSaveBegin")
	RegisterForModEvent("vMYC_EquipmentSaved","OnEquipmentSaved")
	RegisterForModEvent("vMYC_EquipmentSaveEnd","OnEquipmentSaveEnd")
	RegisterForModEvent("vMYC_InventorySaveBegin","OnInventorySaveBegin")
	RegisterForModEvent("vMYC_ItemSaved","OnItemSaved")
	RegisterForModEvent("vMYC_InventorySaveEnd","OnInventorySaveEnd")
	_Book = GetLinkedRef(vMYC_ShrineBook) as vMYC_CharacterBookActiScript
	_Book.IsOpen = True
	;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": SavePlayer!")
	Wait(0.25)
	DisablePlayerControls(abCamSwitch = True)
	ForceThirdPerson()
	AlcoveLightState = 1
	SendModEvent("vMYC_AlcoveLightingPriority","Request",AlcoveIndex)
	Wait(0.5)
	DisablePlayerControls(abCamSwitch = True)
	;vMYC_BlindingLightGold.Play(PlayerREF,-1)
	RegisterForAnimationEvent(PlayerREF,"T02Ascend")
	Idle kAscendIdle
	If !PlayerREF.GetActorBase().GetSex()
		kAscendIdle = AscendMale
	Else
		kAscendIdle = AscendFemale
	EndIf
	PlayerREF.PlayIdle(kAscendIdle)
	Int i = _kInvisibleActors.Length
	While i > 0
		i -= 1
		If !PlayerREF.GetActorBase().GetSex()
			;vMYC_InvisibleMActor.SetHeight(PlayerREF.GetActorBase().GetHeight())
			_kInvisibleActors[i] = _StatueMarker.PlaceActorAtMe(vMYC_InvisibleMActor)
		Else
			;vMYC_InvisibleFActor.SetHeight(PlayerREF.GetActorBase().GetHeight())
			_kInvisibleActors[i] = _StatueMarker.PlaceActorAtMe(vMYC_InvisibleFActor)
		EndIf
		_kInvisibleActors[i].BlockActivation(True)
		;_kInvisibleActors[i].SetAlpha(0.01)
		;_kInvisibleActors[i].SetScale(1.05)
		;_kInvisibleActors[i].UnequipAll()
	EndWhile
	i = _kInvisibleActors.Length
	AudioCategorySFX.SetFrequency(0.1) ; This hides the "whoosh" sound from the Ascend animation on the invisible actors
	While i > 0
		i -= 1
		_kInvisibleActors[i].PlayIdle(kAscendIdle)
	EndWhile
	Wait(1.0)
	vMYC_ShrineLightISMD.ApplyCrossFade(8.0)
	AudioCategorySFX.SetFrequency(1.0) ; Restore sound to normal
	;Finish in OnAnimationEvent
EndFunction

;Save process continues in this event
Event OnAnimationEvent(ObjectReference akSource, string asEventName)
	If asEventName == "T02Ascend" ; Player is floating

		UnregisterForAnimationEvent(PlayerREF,"T02Ascend")
		;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Player is floating!")
		DoSaveAnimation()
	EndIf
EndEvent

;Last part of save process
Function DoSaveAnimation()
{Play VFX and actually save the player character}
	;We turn off collisions here.
	Debug.ToggleCollisions() ; Keep the invisible actors from bouncing around during the next bit

	;VFX
	vMYC_QSTTG09BeamAbilitiesColumnStartSM.Play(PlayerREF)
	vMYC_ValorFX.Play(PlayerREF,-1)
	vMYC_BlindingLightSkinOnly.Play(PlayerREF,-1)
	_Book.IsGlowing = True
	PlayerRef.TranslateToRef(_Book.GetLinkedRef(vMYC_ShrineBook),100) ; book is linked to player target through this keyword
	Wait(1)
	FXGreybeardAbsorbEffect.Play(PlayerREF,8,_StatueMarker)
	vMYC_SpellAbsorbTargetVFX.Play(PlayerREF,-1,_StatueMarker)

	;Turn on opaque white object to make the shrine look super-bright
	_Curtain.EnableNoWait(True)

	;Save the player
	_Book.FlipPages = True
	CharacterManager.SaveCurrentPlayer(bForceSave = True)
	While !_bSavedEquipment || !_bSavedPerks || !_bSavedInventory || !_bSavedSpells
		Wait(0.5)
	EndWhile
	_bForceSave = False
	vMYC_SpellAbsorbTargetVFX.Stop(PlayerREF)
	Wait(1.0)
	_Book.FlipPages = False
	ShrineOfHeroes.SetAlcoveStr(_iAlcoveIndex,"CharacterName",PlayerREF.GetActorBase().GetName())
	CharacterName = ShrineOfHeroes.GetAlcoveStr(AlcoveIndex,"CharacterName")
	ActivateAlcove()
	SendModEvent("vMYC_AlcoveLightingPriority","Release",AlcoveIndex)
	;Saving is done, return the character to the ground
	vMYC_ShrineLightISMD.PopTo(vMYC_ShrineLightWhiteoutISMD) ; white out in 2.5 seconds

	;Force the book to update with the player's name
	SendModEvent("vMYC_ForceBookUpdate","",AlcoveIndex)

	;Break the character out of the floating pose. There's no smooth way to do it, which is why we hide it behind a fade-to-white and some sound effects
	QSTMQ206TimeTravel2DSound.Play(_Book)
	Wait(2.0)
	_Book.IsGlowing = False
	vMYC_BlindingLightSkinOnly.Stop(PlayerREF)
	FXGreybeardAbsorbEffect.Play(PlayerREF,8,_StatueMarker)
	PlayerRef.TranslateToRef(_Book.GetLinkedRef(vMYC_ShrineBook).GetLinkedRef(),999999)
	Wait(0.1)
	PlayerREF.PlayIdle(IdleStop_loose)
	Wait(0.1)
	vMYC_ValorFX.Stop(PlayerREF)
	PlayerREF.StopTranslation()
	Wait(0.1)

	;We turn collisions back on here.
	Debug.ToggleCollisions()

	;Actually make the player stop playing the float animation
	Debug.SendAnimationEvent(PlayerREF,"IdleStaticPoseAStart")

	;Leave them on the floor
	Debug.SendAnimationEvent(PlayerREF,"BleedOutStart")

	Wait(3.0)
	EnablePlayerControls()
	Debug.SendAnimationEvent(PlayerREF,"BleedOutStop")
	;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Player should be released, Alcove should be loaded/loading!")
	Wait(3.0)
	_Book.IsOpen = False
EndFunction

Event OnInventorySaveEnd(string eventName, string strArg, float numArg, Form sender)
{Cleanup invisible actors after all inventory is saved.}
	Wait(5.0) ; give 'em time to float into the shrine
	;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Killing the invisible swordsmen...")
	Int i = _kInvisibleActors.Length
	While i > 0
		i -= 1
		_kInvisibleActors[i].StopTranslation()
		Wait(0.01)
		_kInvisibleActors[i].Delete()
	EndWhile
	_bSavedInventory = True
EndEvent

Event OnEquipmentSaveEnd(string eventName, string strArg, float numArg, Form sender)
	_bSavedEquipment = True
EndEvent

Event OnSpellsSaveEnd(string eventName, string strArg, float numArg, Form sender)
	_bSavedSpells = True
EndEvent

Event OnPerksSaveEnd(string eventName, string strArg, float numArg, Form sender)
	_bSavedPerks = True
EndEvent

Event OnEquipmentSaved(string eventName, string strArg, float numArg, Form sender)
	;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": OnEquipmentSaved(" + eventName + "," + sender + "," + strArg + "," + numArg + ")")
	If _bPlayerIsSaving && ((sender as Armor) || (sender as Weapon))
		If _iInvisibleActorIndex == 0
			_iInvisibleActorIndex = _kInvisibleActors.Length
		EndIf
		_iInvisibleActorIndex -= 1
		Int iThisIndex = _iInvisibleActorIndex
		;_kInvisibleActors[iThisIndex].TranslateToRef(PlayerREF,999999)
		_kInvisibleActors[iThisIndex].RemoveAllItems()
		_kInvisibleActors[iThisIndex].SetAlpha(0.01,False)
		_kInvisibleActors[iThisIndex].MoveTo(PlayerREF)
		If WaitFor3DLoad(_kInvisibleActors[iThisIndex])
			;Proceed
		Else
			_kInvisibleActors[iThisIndex].Delete()
			Return
		EndIf
		;FXGreybeardAbsorbEffect.Play(PlayerREF,8,_kInvisibleActors[iThisIndex])
		If sender as Weapon && numArg == 2
			_kInvisibleActors[iThisIndex].EquipItem(sender)
			_kInvisibleActors[iThisIndex].EquipItem(sender)
			_kInvisibleActors[iThisIndex].UnequipItemEx(sender,1,True)
			Wait(0.1)
		ElseIf sender as Weapon && numArg == 1
			_kInvisibleActors[iThisIndex].EquipItem(sender)
		Else
			_kInvisibleActors[iThisIndex].EquipItem(sender)
			_kInvisibleActors[iThisIndex].EquipItem(sender)
			_kInvisibleActors[iThisIndex].UnequipItemEx(sender,RandomInt(1,2),True)
			_kInvisibleActors[iThisIndex].TranslateTo(PlayerREF.GetPositionX() + RandomFloat(-30,30),PlayerREF.GetPositionY() + RandomFloat(-30,30),PlayerREF.GetPositionZ() + RandomFloat(-30,30),PlayerREF.GetAngleX(),PlayerREF.GetAngleY(),PlayerREF.GetAngleZ(),15)
		EndIf
		;_kInvisibleActors[iThisIndex].TranslateTo(PlayerREF.GetPositionX() + RandomFloat(-100,100),PlayerREF.GetPositionY() + RandomFloat(-100,100),PlayerREF.GetPositionZ() + RandomFloat(0,100),PlayerREF.GetAngleX(),PlayerREF.GetAngleY(),PlayerREF.GetAngleZ(),100)
		If (sender as Armor)
			Armor kArmor = sender as Armor
			If kArmor.IsHelmet() || kArmor.IsClothingHead()
				_kInvisibleActors[iThisIndex].TranslateTo(PlayerREF.GetPositionX(),PlayerREF.GetPositionY(),PlayerREF.GetPositionZ() + 30,PlayerREF.GetAngleX(),PlayerREF.GetAngleY(),PlayerREF.GetAngleZ(),15)
			ElseIf kArmor.IsBoots() || kArmor.IsClothingFeet()
				_kInvisibleActors[iThisIndex].TranslateTo(PlayerREF.GetPositionX(),PlayerREF.GetPositionY(),PlayerREF.GetPositionZ() - 30,PlayerREF.GetAngleX(),PlayerREF.GetAngleY(),PlayerREF.GetAngleZ(),15)
			ElseIf kArmor.IsGauntlets() || kArmor.IsClothingHands()
				_kInvisibleActors[iThisIndex].TranslateTo(PlayerREF.GetPositionX(),PlayerREF.GetPositionY(),PlayerREF.GetPositionZ() - 20,PlayerREF.GetAngleX(),PlayerREF.GetAngleY(),PlayerREF.GetAngleZ(),15)
			EndIf
		Else
			_kInvisibleActors[iThisIndex].TranslateToRef(_StatueMarker,30,1)
		EndIf
		;Wait(0.1)
		vMYC_BlindingLightGold.Play(_kInvisibleActors[iThisIndex],0.1)
		_kInvisibleActors[iThisIndex].SetAlpha(1,True)

		Wait(RandomFloat(1.0,2.0))
		If !WaitFor3DLoad(_kInvisibleActors[iThisIndex])
			;For some reason actor was unloaded, might be possible near the end of the save or if there are tons of custom weapons
			_kInvisibleActors[iThisIndex].Delete()
		Else
			_kInvisibleActors[iThisIndex].SplineTranslateToRef(_StatueMarker,RandomFloat(350,800),250,10)
		EndIf
		;Wait(5)
		;_kInvisibleActors[iThisIndex].Disable(True)
	EndIf
EndEvent

Event OnPerkSaved(string eventName, string strArg, float numArg, Form sender)
	If _bPlayerIsSaving ;&& (sender as Armor)
		;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": OnPerkSaved(" + eventName + "," + sender + ")")
		vMYC_PerkGlowScript PerkGlow = _StatueMarker.PlaceAtMe(vMYC_PerkGlow,abInitiallyDisabled = True) as vMYC_PerkGlowScript
		PerkGlow.StartNode = "NPC Head [Head]"
		PerkGlow.Target = _StatueMarker
	EndIf
EndEvent

Event OnSpellSaved(string eventName, string strArg, float numArg, Form sender)
	If _bPlayerIsSaving ;&& (sender as Armor)
		;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": OnSpellSaved(" + eventName + "," + sender + ")")
		vMYC_PerkGlowScript PerkGlow = _StatueMarker.PlaceAtMe(vMYC_PerkGlow,abInitiallyDisabled = True) as vMYC_PerkGlowScript
		If RandomInt(0,1)
			PerkGlow.StartNode = "NPC L Hand [LHnd]"
		Else
			PerkGlow.StartNode = "NPC R Hand [RHnd]"
		EndIf
		PerkGlow.Target = _StatueMarker
	EndIf
EndEvent

Event OnItemSaved(string eventName, string strArg, float numArg, Form sender)
{Could make an animation when an inventory item is saved but... sloooooooow.....}
;	If _bPlayerIsSaving ;&& (sender as Armor)
;		;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": OnItemSaved(" + eventName + "," + sender + ")")
;		ObjectReference PerkGlow = _StatueMarker.PlaceAtMe(sender,abInitiallyDisabled = True)
;		PerkGlow.EnableNoWait(True)
;		Wait(0.1)
;		PerkGlow.SetMotionType(PerkGlow.Motion_Keyframed)
;		PerkGlow.MoveTo(PlayerREF,0,0,50)
;		vMYC_BlindingLightGold.Play(PerkGlow,0.1)
;		PerkGlow.SplineTranslateToRef(_StatueMarker,RandomFloat(500,800),RandomFloat(350,450))
;		Wait(3.0)
;		PerkGlow.StopTranslation()
;		PerkGlow.Delete()
;	EndIf
EndEvent

;==== Functions/Events for character summoning/banishing ====----

Function SummonCharacter()
{Summon the character from Alcove into Tamriel}
	;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": SummonCharacter!")
	GoToState("Busy")
	_Book = GetLinkedRef(vMYC_ShrineBook) as vMYC_CharacterBookActiScript
	_Book.IsOpen = True
	_Book.IsGlowing = True
	;_kCharacter.SetActorValue("Variable10",0)
	Wait(0.5)
	_kCharacter.EnableAI(True)
	Wait(0.5)
	;If RandomInt(0,1)
		;_kCharacter.PlayIdle(IdleSnapToAttention)
	;Else
	;EndIf
	vMYC_ValorFX.Play(_kCharacter,5)
	Wait(0.5)
	_kCharacter.PlayIdle(IdleSilentBow)
	Wait(0.5)
	DA02SummonValorTargetFX.Play(_kCharacter,8)
	Wait(0.5)
	_kCharacter.SetAlpha(0.01,True)
	Wait(5.0)
	_kCharacter.Disable()
	_kCharacter.SetScale(1.0)
	_kCharacter.SetGhost(False)
	_kCharacter.MoveToMyEditorLocation()
	_kCharacter.EnableNoWait()
	CharacterManager.SetCharacterTracking(CharacterName,True)
	_kCharacter.EvaluatePackage()
	Wait(0.5)
	CharacterManager.SetLocalInt(_sCharacterName,"InAlcove",0)
	_kCharacter.MoveToPackageLocation()
	String sCellName
	If _kCharacter.GetParentCell()
		sCellName = _kCharacter.GetParentCell().GetName()
	EndIf
	If sCellName == "vMYC_Staging"
		Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Character got lost, sending them on...")
		ObjectReference kMarkerObject = CharacterManager.CustomMapMarkers[CharacterManager.GetLocalInt(CharacterName, "HangoutIndex")]
		_kCharacter.MoveTo(kMarkerObject)
	EndIf
	_Book.IsGlowing = False
	Wait(1.0)
	_kCharacter.SetAlpha(1.0)
	_bCharacterSummoned = True
	CharacterManager.SetLocalInt(_sCharacterName,"IsSummoned",1)
	AlcoveState = 3
	GoToState("Active")
EndFunction

Function BanishCharacter()
{Banish the character from Tamriel back to the Alcove}
	;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": BanishCharacter!")
	GoToState("Busy")
	_Book.IsOpen = False
	If Is3DLoaded()
		_Book.IsGlowing = True
	EndIf
	;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Disabling character tracking...")
	CharacterManager.SetCharacterTracking(CharacterName,False)
	;_kCharacter.DisableNoWait(False)
	Wait(0.25)
	_kCharacter.SetScale(0.01)
	;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Moving character to staging area...")
	CharacterManager.SetLocalInt(_sCharacterName,"InAlcove",1)
	_kCharacter.MoveTo(_StatueMarker)
	WaitForCharacterReady()
	If WaitFor3DLoad(_kCharacter)
		_kCharacter.SetAlpha(0.01,False)
	EndIf
	;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Moving character to Alcove...")
	_kCharacter.SetGhost(True)
	_kCharacter.SetScale(1.2)
	If WaitFor3DLoad(_kCharacter)
;		_kCharacter.SetAlpha(0.01,False)
		DA02SummonValorTargetFX.Play(_kCharacter,8)
		Wait(1.0)
	EndIf
	;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Fading in character...")
	_kCharacter.SetAlpha(1.0,True)
	If Is3DLoaded()
		_Book.IsGlowing = False
	EndIf
	Wait(3.0)
	_kCharacter.PlayIdle(IdleStaticPoseA)
	;_kCharacter.DrawWeapon()
	Wait(0.25)
	;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Freezing character!")
	_kCharacter.EnableAI(False)
	_bCharacterSummoned = False
	CharacterManager.SetLocalInt(_sCharacterName,"IsSummoned",0)
	AlcoveState = 2
	GoToState("Active")
EndFunction

;==== Utility functions ====----

Function ResetAlcove()
	If _kCharacter && !_kCharacter.IsAIEnabled()
		ObjectReference kNowhere = GetFormFromFile(0x02004e4d,"vMYC_MeetYourCharacters.esp") as ObjectReference ; Marker in vMYC_StagingCell
		_kCharacter.MoveTo(kNowhere)
	EndIf

	_bCharacterSummoned = False
	_kCharacter = None
	CharacterName = ""

	HideTrophies()
	_Book.IsOpen = False
	_Book.IsGlowing = False
	_Book.FlipPages = False

	AlcoveLightState = 0
	AlcoveStatueState = 0
	AlcoveState = 0	
EndFunction

Function UpdateAlcove()
	;GotoState("Inactive")
	AlcoveLightState = 1
	String sCharacterName = CharacterName
	EraseAlcove(abAutoLights = False)
	Wait(0.1)
	CharacterManager.EraseCharacter(sCharacterName,True)
	;Wait(0.1)
	;CharacterName = ""
;	Wait(0.1)
	SavePlayer(True)
	;GoToState("Active")
EndFunction

Function EraseAlcove(Bool abAutoLights = True)
	If abAutoLights
		AlcoveLightState = 0
	EndIf
	HideTrophies()
	If _kCharacter
		ObjectReference kNowhere = GetFormFromFile(0x02004e4d,"vMYC_MeetYourCharacters.esp") as ObjectReference ; Marker in vMYC_StagingCell
		_kCharacter.MoveTo(kNowhere)
	EndIf
	ShrineOfHeroes.SetAlcoveStr(AlcoveIndex,"CharacterName","")
	ShrineOfHeroes.SetAlcoveInt(AlcoveIndex,"State",0)
	CharacterName = ""
	_kCharacter = None
	;Wait(0.1)
	SendModEvent("vMYC_ForceBookUpdate","",AlcoveIndex)
	AlcoveState = 0
EndFunction

Function PlayerActivate()
	;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Got PlayerActivate in null state!")
EndFunction

;==== Functions/Events for trophies ====----

Function InitTrophies()
	Int i = vMYC_TrophyKeywords.GetSize()
	While i > 0
		i -= 1
		vMYC_ShrineTrophyFXScript kTrophy = GetLinkedRef(vMYC_TrophyKeywords.GetAt(i) as Keyword) as vMYC_ShrineTrophyFXScript
		If kTrophy
			kTrophy.AlcoveIndex = AlcoveIndex
		EndIf
	EndWhile
EndFunction

Function HideTrophies()
	Int i = vMYC_TrophyKeywords.GetSize()
	While i > 0
		i -= 1
		ObjectReference kTrophy = GetLinkedRef(vMYC_TrophyKeywords.GetAt(i) as Keyword) as ObjectReference
		If kTrophy
			kTrophy.DisableNoWait()
		EndIf
	EndWhile
EndFunction

Function ShowTrophies()
	String[] sSpawnPoints = CharacterManager.GetCharacterSpawnPoints(_sCharacterName)
	;Int i = 0
	;While i < sSpawnPoints.Length
		;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Spawnpoint[" + i + "] is " + sSpawnPoints[i])
		;sSpawnPoints[i]
		;i += 1
	;EndWhile
	If sSpawnPoints.Find("Hero") > -1
		GetLinkedRef(vMYC_ShrineTrophyHero).EnableNoWait()
	EndIf
	If sSpawnPoints.Find("Companion") > -1
		GetLinkedRef(vMYC_ShrineTrophyCompanion).EnableNoWait()
	EndIf
	If sSpawnPoints.Find("Mage") > -1
		GetLinkedRef(vMYC_ShrineTrophyMage).EnableNoWait()
	EndIf
	If sSpawnPoints.Find("Thief") > -1
		GetLinkedRef(vMYC_ShrineTrophyThief).EnableNoWait()
	EndIf
	If sSpawnPoints.Find("DarkBrotherhoodRestored") > -1
		GetLinkedRef(vMYC_ShrineTrophyDBRestored).EnableNoWait()
	ElseIf sSpawnPoints.Find("DarkBrotherhoodDestroyed") > -1
		GetLinkedRef(vMYC_ShrineTrophyDBDestroyed).EnableNoWait()
	EndIf
	If sSpawnPoints.Find("Imperial") > -1
		GetLinkedRef(vMYC_ShrineTrophyImperial).EnableNoWait()
	ElseIf sSpawnPoints.Find("Stormcloak") > -1
		GetLinkedRef(vMYC_ShrineTrophyStormcloak).EnableNoWait()
	EndIf
	If sSpawnPoints.Find("Bard") > -1
		GetLinkedRef(vMYC_ShrineTrophyBard).EnableNoWait()
	EndIf
	If sSpawnPoints.Find("Greybeard") > -1
		GetLinkedRef(vMYC_ShrineTrophyGreybeard).EnableNoWait()
	ElseIf sSpawnPoints.Find("Blade") > -1
		GetLinkedRef(vMYC_ShrineTrophyBlade).EnableNoWait()
	EndIf
	If sSpawnPoints.Find("Werewolf") > -1
		GetLinkedRef(vMYC_ShrineTrophyWerewolfSymbol).EnableNoWait()
	ElseIf sSpawnPoints.Find("VampireLord") > -1
		GetLinkedRef(vMYC_ShrineTrophyVampireSymbol).EnableNoWait()
	EndIf
	If sSpawnPoints.Find("VampireFaction") > -1
		GetLinkedRef(vMYC_ShrineTrophyDLC1Vampire).EnableNoWait()
	ElseIf sSpawnPoints.Find("DawnguardFaction") > -1
		GetLinkedRef(vMYC_ShrineTrophyDLC1Dawnguard).EnableNoWait()
	EndIf
	If sSpawnPoints.Find("DLC1Completed") > -1
		GetLinkedRef(vMYC_ShrineTrophyDLC1Complete).EnableNoWait()
	EndIf
	If sSpawnPoints.Find("DLC2KilledMiraak") > -1
		GetLinkedRef(vMYC_ShrineTrophyDLC2Miraak).EnableNoWait()
	EndIf
EndFunction
