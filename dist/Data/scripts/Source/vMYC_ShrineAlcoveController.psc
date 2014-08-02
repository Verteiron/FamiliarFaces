Scriptname vMYC_ShrineAlcoveController extends ObjectReference
{Handle alcove activation/deactivation effects}

;--=== Imports ===--

Import Utility
Import Game

;--=== Constants ===--
Int Property ALCOVE_STATE_EMPTY 	= 0 AutoReadOnly Hidden
Int Property ALCOVE_STATE_BUSY 		= 1 AutoReadOnly Hidden
Int Property ALCOVE_STATE_READY 	= 2 AutoReadOnly Hidden
Int Property ALCOVE_STATE_SUMMONED 	= 3 AutoReadOnly Hidden
Int Property ALCOVE_STATE_ERROR 	= 4 AutoReadOnly Hidden

Int Property ALCOVE_LIGHTS_OFF	 	= 0 AutoReadOnly Hidden
Int Property ALCOVE_LIGHTS_LOADING	= 1 AutoReadOnly Hidden
Int Property ALCOVE_LIGHTS_ON	 	= 2 AutoReadOnly Hidden

Int Property ALCOVE_STATUE_NONE	 	= 0 AutoReadOnly Hidden
Int Property ALCOVE_STATUE_PRESENT	= 1 AutoReadOnly Hidden
Int Property ALCOVE_STATUE_SUMMONED	= 2 AutoReadOnly Hidden


Int Property VALIDATION_FAILURE_NONE 			=     0 AutoReadOnly Hidden

Int Property VALIDATION_FAILURE_STATE_BUSY	 	=     1 AutoReadOnly Hidden

Int Property VALIDATION_FAILURE_ACTOR_MISSING 	=     2 AutoReadOnly Hidden
Int Property VALIDATION_FAILURE_ACTOR_UNWANTED	=     4 AutoReadOnly Hidden
Int Property VALIDATION_FAILURE_ACTOR_LOADING	=     8 AutoReadOnly Hidden
Int Property VALIDATION_FAILURE_ACTOR_LOST		=    16 AutoReadOnly Hidden

Int Property VALIDATION_FAILURE_NAME_MISSING	=    32 AutoReadOnly Hidden
Int Property VALIDATION_FAILURE_NAME_UNWANTED	=    64 AutoReadOnly Hidden

Int Property VALIDATION_FAILURE_LIGHTSTATE_BAD	=   128 AutoReadOnly Hidden

Int Property VALIDATION_FAILURE_INDEX_BAD		=  1024 AutoReadOnly Hidden

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
		_Book.AlcoveIndex = AlcoveIndex
		RegisterForSingleUpdate(1)
	EndFunction
EndProperty

Actor Property AlcoveActor Auto Hidden
{The actor that 'lives' in this alcove}

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

String Property WantCharacterName Hidden
{Which Character we want to live here.}
	String Function Get()
		If AlcoveIndex > -1
			Return ShrineOfHeroes.GetAlcoveStr(AlcoveIndex,"CharacterName")
		EndIf
		Return ""
	EndFunction
;	Function Set(String sCharacterName)
;		If AlcoveIndex > -1
;			ShrineOfHeroes.SetAlcoveStr(AlcoveIndex,"CharacterName",sCharacterName)
;		EndIf
;	EndFunction
EndProperty

Int Property AlcoveState Hidden
{0 = Empty, 1 = Busy, 2 = Ready, 3 = Summoned, 4 = Error}
	Int Function Get()
		Return _iAlcoveState
	EndFunction
	Function Set(Int iAlcoveState)
		_iAlcoveState = iAlcoveState
		If iAlcoveState == ALCOVE_STATE_EMPTY
			AlcoveLightState = ALCOVE_LIGHTS_OFF
		ElseIf iAlcoveState == ALCOVE_STATE_READY || iAlcoveState == ALCOVE_STATE_SUMMONED
			AlcoveLightState = ALCOVE_LIGHTS_ON
		Else
			AlcoveLightState = ALCOVE_LIGHTS_LOADING
		EndIF
		SendModEvent("vMYC_AlcoveStatusUpdate",_iAlcoveState)
	EndFunction
EndProperty

Int Property WantAlcoveState Auto Hidden
{0 = Empty, 1 = Busy, 2 = Ready, 3 = Summoned, 4 = Error}

Int Property AlcoveStatueState Hidden
{0 = None, 1 = Present, 2 = Summoned}
	Int Function Get()
		Return _iAlcoveStatueState
	EndFunction
	Function Set(Int iAlcoveStatueState)
		_iAlcoveStatueState = iAlcoveStatueState
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

Bool Property DisableLights	= False Auto Hidden

vMYC_CharacterManagerScript 	Property CharacterManager 	Auto
vMYC_ShrineOfHeroesQuestScript 	Property ShrineOfHeroes 	Auto

Int 			Property 	ValidationState 			Auto Hidden
Int 			Property 	LastValidationState 		Auto Hidden

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

Int				_iValidateStateCount = 0

Float			_fValidationTime = 0.0
Bool			_bLastValidation = False
String			_sLastFailureReason = ""
Int				_iRepeatFailureCount = 0


;Legacy variables, do not use

Actor 			_kCharacter

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
	InitTrophies()
EndEvent

Event OnLoad()
	CheckVars()
	RegisterForModEvents()
	RegisterForSingleUpdate(1)
EndEvent

Function RegisterForModEvents()
	RegisterForModEvent("vMYC_OrphanedActor","OnOrphanedActor")
	RegisterForModEvent("vMYC_AlcoveLightingPriority","OnAlcoveLightingPriority")
	RegisterForModEvent("vMYC_AlcoveValidateState","OnAlcoveValidateState")
EndFunction

Function DoUpkeep()
	RegisterForModEvents()
	If AlcoveState == 3
		CharacterManager.SetLocalInt(_sCharacterName,"IsSummoned",1)
		_bCharacterSummoned = True
	EndIf
	InitTrophies()
	_bLastValidation = False
	RegisterForSingleUpdate(1)
EndFunction

Event OnUpdate()
	If !ValidateAlcove()
		RegisterForSingleUpdate(5)
	Else
		If Is3DLoaded()
			RegisterForSingleUpdate(RandomFloat(9,12))
		EndIf
	EndIf
EndEvent

Event OnOrphanedActor(string eventName, string strArg, float numArg, Form sender)
	If !AlcoveActor && strArg == WantCharacterName && sender as vMYC_CharacterDummyActorScript
		AlcoveActor = sender as Actor
	EndIf
EndEvent

Function ClaimActor(String asCharacterName)
	AlcoveActor = CharacterManager.GetCharacterActorByName(asCharacterName)
	If !AlcoveActor
		;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Asking CharacterManager to load " + asCharacterName + "...")
		If CharacterManager.LoadCharacter(asCharacterName)
			;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": CharacterManager finished loading " + asCharacterName + "!")
			AlcoveActor = CharacterManager.GetCharacterActorByName(asCharacterName)
		Else
			;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": CharacterManager couldn't load " + asCharacterName + "!",1)
		EndIf
	EndIf
	If AlcoveActor
		AlcoveStatueState = CharacterManager.GetLocalInt(asCharacterName,"IsSummoned")
		If StringUtil.Find(AlcoveActor.GetActorBase().GetName(),"Dummy") > -1
			(AlcoveActor as vMYC_CharacterDummyActorScript).SetNameIfNeeded(True)
		EndIf
		CharacterName = AlcoveActor.GetActorBase().GetName()
		If AlcoveStatueState != ALCOVE_STATUE_SUMMONED
			AlcoveActor.MoveTo(_StatueMarker)
		EndIf
	EndIf
	
EndFunction

Function ReleaseActor()
	HideTrophies()
	If AlcoveActor && AlcoveState != ALCOVE_STATE_SUMMONED
		ObjectReference kNowhere = GetFormFromFile(0x02004e4d,"vMYC_MeetYourCharacters.esp") as ObjectReference ; Marker in vMYC_StagingCell
		AlcoveActor.MoveTo(kNowhere)
	ElseIf AlcoveState == ALCOVE_STATE_SUMMONED || AlcoveStatueState == ALCOVE_STATUE_SUMMONED
		Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": ReleaseActor called, but Alcove or Actor is in Summoned state. Releasing the Actor without moving them.",1)
	ElseIf !AlcoveActor
		Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": ReleaseActor called, but Alcove has no Actor set!",1)
		Return
	EndIf
	AlcoveActor.EnableAI(True)
	AlcoveActor = None
	AlcoveStatueState = ALCOVE_STATUE_NONE
	CharacterName = ""
EndFunction

Bool Function DeportUnknownActors()
{Check for an unknown actor in the Alcove and send them to limbo. Return true if one was found.}
	If _bPlayerisSaving || !_StatueMarker.GetParentCell() || !_StatueMarker.GetParentCell().IsAttached()
		Return False
	EndIf
	Actor kUnknownActor
	Int i = 5
	While i > 0 && !kUnknownActor
		i -= 1
		kUnknownActor = FindRandomActorFromRef(_StatueMarker,250)
		If kUnknownActor == AlcoveActor || kUnknownActor == PlayerREF 
			kUnknownActor = None
		EndIf
	EndWhile
	
	If kUnknownActor
		ObjectReference kNowhere = GetFormFromFile(0x02004e4d,"vMYC_MeetYourCharacters.esp") as ObjectReference ; Marker in vMYC_StagingCell
		If kUnknownActor as vMYC_CharacterDummyActorScript
			kUnknownActor.MoveTo(kNowhere)
			Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Found Actor " + kUnknownActor + " aka " + kUnknownActor.GetActorBase().GetName() + " in shrine and banished them into limbo.",1)
		Else
			kUnknownActor.MoveToMyEditorLocation()
			Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Found unknown Actor " + kUnknownActor + " aka " + kUnknownActor.GetActorBase().GetName() + " in shrine and reset them to their editor location. What just happened?",1)
		EndIf
		Return True
	EndIf
	Return False
EndFunction

State Validating

	Bool Function ValidateAlcove()
		;_iValidateStateCount += 1
		;If _iValidateStateCount > 4
			;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": ValidateAlcove called repeatedly while in Validating state, returning to normal state!")
			;GotoState("")
		;EndIf
		Return False
	EndFunction

EndState

Bool Function ValidateAlcove()
	If _bPlayerIsSaving ;Disable validation if player is saving here!
		AlcoveLightState = ALCOVE_LIGHTS_LOADING
		Return True
	EndIf
	GoToState("Validating")
	_iValidateStateCount = 0
	Bool bValidate = True

	;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": ValidateAlcove!")
	;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": CharacterName is " + CharacterName + ", WantCharacterName is " + WantCharacterName + ", AlcoveActor is " + AlcoveActor)

	If AlcoveStatueState == ALCOVE_STATUE_SUMMONED
		_Book.IsOpen = True
	Else
		_Book.IsOpen = False
	EndIf
	
	If ValidationState == VALIDATION_FAILURE_STATE_BUSY 
		; ==, not & ... This was the only error, so we need to exit the busy state
		If AlcoveActor
			AlcoveState = ALCOVE_STATE_READY
		Else
			AlcoveState = ALCOVE_STATE_EMPTY
		EndIf
	ElseIf ValidationState ; Other problems, so stay Busy
		AlcoveState = ALCOVE_STATE_BUSY
	EndIf
	
	String sWantCharacterName = WantCharacterName ; 'cache' it locally, sort of
	
	String sActorName
	
	Bool bActorInAlcove
	Float fTimeStart = GetCurrentRealTime()
	
	If AlcoveActor
		AlcoveActor.EnableNoWait(0)
		If AlcoveActor.GetDistance(_StatueMarker) > 15 || AlcoveActor.GetParentCell() != GetParentCell() || !AlcoveActor.IsEnabled()
			bActorInAlcove = False
		Else
			bActorInAlcove = True
		EndIf

		sActorName = AlcoveActor.GetActorBase().GetName()
		If !sActorName
			sActorName = AlcoveActor.GetName()
		EndIf
		If StringUtil.Find(AlcoveActor.GetActorBase().GetName(),"Dummy") > -1
			(AlcoveActor as vMYC_CharacterDummyActorScript).SetNameIfNeeded(True)
		EndIf
	EndIf
	
	Actor kCharacterToUse

	If sWantCharacterName
		kCharacterToUse = CharacterManager.GetCharacterActorByName(sWantCharacterName)
	EndIf	
	
	If AlcoveState == ALCOVE_STATE_READY && AlcoveActor.IsAIEnabled() && AlcoveStatueState != ALCOVE_STATUE_SUMMONED
		CharacterManager.SetLocalInt(CharacterName,"InAlcove",1)
		CharacterManager.SetLocalInt(CharacterName,"IsSummoned",0)
		AlcoveActor.SetGhost(True)
		AlcoveActor.EnableNoWait()
		If WaitFor3DLoad(AlcoveActor)
			vMYC_BlindingLightInwardParticles.Play(AlcoveActor,0.5)
			Debug.SendAnimationEvent(AlcoveActor,"IdleStaticPoseAStart")
			Wait(0.25)
		EndIf
		AlcoveActor.SetScale(1.2)
		AlcoveActor.EnableAI(False)
	EndIf
	
	;First things first. Make sure we're always in the right lighting state
	; SetAlcoveLightState is latent, so when it returns we definitely should be in the right state
	If AlcoveState == ALCOVE_STATE_BUSY && AlcoveLightState != ALCOVE_LIGHTS_LOADING
		SetAlcoveLightState(ALCOVE_LIGHTS_LOADING)
	ElseIf (AlcoveState == ALCOVE_STATE_READY || AlcoveState == ALCOVE_STATE_SUMMONED) && AlcoveLightState != ALCOVE_LIGHTS_ON
		SetAlcoveLightState(ALCOVE_LIGHTS_ON)
	ElseIf AlcoveState == ALCOVE_STATE_EMPTY && AlcoveLightState != ALCOVE_LIGHTS_OFF
		SetAlcoveLightState(ALCOVE_LIGHTS_OFF)
	EndIf

	If Math.LogicalAnd(ValidationState,VALIDATION_FAILURE_ACTOR_UNWANTED)
		ReleaseActor()
	EndIf
	
	If Math.LogicalAnd(ValidationState,VALIDATION_FAILURE_ACTOR_MISSING)
		If sWantCharacterName
			ClaimActor(sWantCharacterName)
		EndIf
	EndIf
	
	If Math.LogicalAnd(ValidationState,VALIDATION_FAILURE_NAME_UNWANTED)
		CharacterName = sActorName
	EndIf

	If Math.LogicalAnd(ValidationState,VALIDATION_FAILURE_NAME_MISSING)
		CharacterName = sActorName
	EndIf

	If Math.LogicalAnd(ValidationState,VALIDATION_FAILURE_ACTOR_LOST)
		If AlcoveActor
			AlcoveActor.Enable()
			AlcoveActor.EnableAI(True)
			AlcoveActor.MoveTo(_StatueMarker)
		EndIf
	EndIf
	
	If Math.LogicalAnd(ValidationState,VALIDATION_FAILURE_ACTOR_LOADING)
		WaitMenuMode(2)
	EndIf
	
	ValidationState = 0
	
	If AlcoveState == ALCOVE_STATE_ERROR
		Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": In Error state!")
		AlcoveState == ALCOVE_STATE_BUSY
	EndIf

	If AlcoveIndex < 0 
		ValidationState = Math.LogicalOr(ValidationState,VALIDATION_FAILURE_INDEX_BAD)
	EndIf
	
	If AlcoveActor && !sWantCharacterName
		ValidationState = Math.LogicalOr(ValidationState,VALIDATION_FAILURE_ACTOR_UNWANTED)
	ElseIf AlcoveActor && !bActorInAlcove && AlcoveStatueState != ALCOVE_STATUE_SUMMONED
		ValidationState = Math.LogicalOr(ValidationState,VALIDATION_FAILURE_ACTOR_LOST)
	ElseIf !AlcoveActor && sWantCharacterName
		ValidationState = Math.LogicalOr(ValidationState,VALIDATION_FAILURE_ACTOR_MISSING)
	EndIf

	If AlcoveActor && (AlcoveActor as vMYC_CharacterDummyActorScript).IsBusy
		ValidationState = Math.LogicalOr(ValidationState,VALIDATION_FAILURE_ACTOR_LOADING)
	EndIf
	
	If CharacterName && !sWantCharacterName || CharacterName != sWantCharacterName
		ValidationState = Math.LogicalOr(ValidationState,VALIDATION_FAILURE_NAME_UNWANTED)
	ElseIf !CharacterName && (sWantCharacterName != CharacterName)
		ValidationState = Math.LogicalOr(ValidationState,VALIDATION_FAILURE_NAME_MISSING)
	EndIf

	If AlcoveState == ALCOVE_STATE_BUSY
		ValidationState = Math.LogicalOr(ValidationState,VALIDATION_FAILURE_STATE_BUSY)
	ElseIf AlcoveState == ALCOVE_STATE_READY
		If AlcoveActor != kCharacterToUse
			ValidationState = Math.LogicalOr(ValidationState,VALIDATION_FAILURE_ACTOR_UNWANTED)
		EndIf
	EndIf
	
	While DeportUnknownActors()
		Wait(0.5)
	EndWhile

	Float fValidationTime = GetCurrentRealTime() - fTimeStart
	
	If ValidationState
		bValidate = False
	EndIf
	
	If bValidate 
		_fValidationTime += fValidationTime
		If !_bLastValidation
			_bLastValidation = True
			If AlcoveActor
				SendModEvent("vMYC_ForceBookUpdate","",AlcoveIndex)
			EndIf
			Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Passed validation in " + _fValidationTime + "s!" + " CharacterName is " + CharacterName + ", AlcoveActor is " + AlcoveActor)	
			RegisterForSingleUpdate(5)
			;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": *** sActorName:" + sActorName + ", bActorInAlcove:" + bActorInAlcove + ", AlcoveStatueState:" + AlcoveStatueState + ", kCharacterToUse:" + kCharacterToUse)
		EndIf
		_fValidationTime = 0.0
		LastValidationState = 0
		_iRepeatFailureCount = 0
	Else
		If _bLastValidation
			Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Failed validation! Initial reason: " + FailureText(ValidationState))
			_fValidationTime = 0.0
		EndIf
		If LastValidationState == ValidationState
			_iRepeatFailureCount += 1
		Else
			_iRepeatFailureCount == 0
		EndIf
		If _iRepeatFailureCount > 60
			Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": --- Validation failed repeatedly with: " + ValidationState + "! Notify the player.")
			Debug.Notification("Alcove " + _iAlcoveIndex + " appears to be stuck. You can reset it from the MCM panel.")
			_iRepeatFailureCount = 0
			;ResetAlcove()
		ElseIf _fValidationTime > 120
			Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": --- Validation has been stuck for over 2 minutes. Last ValidationState was " + ValidationState + " Notify the player.")
			Debug.Notification("Alcove " + _iAlcoveIndex + " has been busy for a long time. You can reset it from the MCM panel.")
			;ResetAlcove()
		EndIf
		LastValidationState = ValidationState
		_bLastValidation = False
		_fValidationTime += fValidationTime
		;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": --- Validation failed: " + FailureText(ValidationState) + " CharacterName is " + CharacterName + ", sWantCharacterName is " + sWantCharacterName + ", AlcoveActor is " + AlcoveActor)
		RegisterForModEvent("vMYC_AlcoveSelfValidate","OnAlcoveSelfValidate")
		SendModEvent("vMYC_AlcoveSelfValidate")
		;RegisterForSingleUpdate(1)
	EndIf
	;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ":     Validation pass took " + fValidationTime + " seconds.")
	GoToState("")
	Return bValidate
EndFunction

String Function FailureText(Int iValidationState)
	String sFailureText
	If Math.LogicalAnd(iValidationState,VALIDATION_FAILURE_STATE_BUSY)
		sFailureText += "STATE_BUSY "
	EndIf
	If Math.LogicalAnd(iValidationState,VALIDATION_FAILURE_ACTOR_MISSING)
		sFailureText += "ACTOR_MISSING "
	EndIf
	If Math.LogicalAnd(iValidationState,VALIDATION_FAILURE_ACTOR_UNWANTED)
		sFailureText += "ACTOR_UNWANTED "
	EndIf
	If Math.LogicalAnd(iValidationState,VALIDATION_FAILURE_ACTOR_LOADING)
		sFailureText += "ACTOR_LOADING "
	EndIf
	If Math.LogicalAnd(iValidationState,VALIDATION_FAILURE_ACTOR_LOST)
		sFailureText += "ACTOR_LOST "
	EndIf
	If Math.LogicalAnd(iValidationState,VALIDATION_FAILURE_NAME_MISSING)
		sFailureText += "NAME_MISSING "
	EndIf
	If Math.LogicalAnd(iValidationState,VALIDATION_FAILURE_NAME_UNWANTED)
		sFailureText += "NAME_UNWANTED "
	EndIf
	If Math.LogicalAnd(iValidationState,VALIDATION_FAILURE_LIGHTSTATE_BAD)
		sFailureText += "LIGHTSTATE_BAD "
	EndIf
	If Math.LogicalAnd(iValidationState,VALIDATION_FAILURE_INDEX_BAD)
		sFailureText += "INDEX_BAD "
	EndIf
	Return sFailureText
EndFunction


Event OnAlcoveLightingPriority(string eventName, string strArg, float numArg, Form sender)
{Disable the lights of all Alcoves except the event sender to try to give its lighting effects top priority}
	;strArg = numArg = AlcoveIndex of sender
	Int iRequestingIndex = numArg as Int
	If iRequestingIndex != AlcoveIndex && strArg == "Request"
		Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Disabling my lights by request of " + iRequestingIndex)
		DisableLights = True
		_Torches.DisableNoWait(True)
		GetLinkedRef(vMYC_ShrineLightingMaster).DisableNoWait(True)
		_Light.StopTranslation()
		_Light.DisableNoWait(True)
	ElseIf iRequestingIndex != AlcoveIndex && strArg == "Release"
		Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Restoring my lights by request of " + iRequestingIndex)
		DisableLights = False
		If AlcoveLightState == ALCOVE_LIGHTS_ON
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
		ValidateAlcove()
	EndIf
EndEvent

Function SetAlcoveCharacterName(string sCharacterName)
{This (un)sets the Alcove's character name}
	_sCharacterName = sCharacterName
EndFunction

Event OnCellAttach()
	RegisterForSingleUpdate(1)
EndEvent

Event OnAttachedToCell()
EndEvent

Event OnAlcoveValidateState(string eventName, string strArg, float numArg, Form sender)
	;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": OnAlcoveValidateState!")
	ValidateAlcove()
EndEvent

Event OnAlcoveSelfValidate(string eventName, string strArg, float numArg, Form sender)
	If sender == self
		ValidateAlcove()
	EndIf
EndEvent

Event OnUnload()
EndEvent

Function SetAlcoveLightState(Int iNewLightState)
{iNewLightState: 0 = Dark, 1 = Full light, 2 = Torch light}
	If iNewLightState == _iAlcoveLightState
		Return
	EndIf

	Bool bUseTranslation = True
	If !Is3DLoaded()
		bUseTranslation = False
	EndIf
	;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Setting light state to " + numArg as Int + ", current state is " + _iAlcoveLightState)
	Int iOldLightState = _iAlcoveLightState
	Int iLightState = iNewLightState
	_LightAmbientTarget	= _Light.GetLinkedRef()

	If iLightState == ALCOVE_LIGHTS_ON
		ShowTrophies()
	Else
		HideTrophies()
	EndIf

	If _Light.IsDisabled() && iLightState > 0
		_Light.EnableNoWait()
		Int iSafety = 0
		While !_Light.Is3DLoaded() && iSafety < 10
			iSafety += 1
			Wait(0.1)
		EndWhile
	EndIf

	If iLightState != 1
		_Curtain.DisableNoWait(True)
	EndIf
	
	If iLightState == 2
		_Torches.EnableNoWait(True)
		GetLinkedRef(vMYC_ShrineLightingMaster).EnableNoWait(True)
	EndIf
	
	If iLightState == 1 && _Light.GetDistance(_LightAmbientTarget) < 10
		If bUseTranslation
			_Light.TranslateTo(_LightX,_LightY,_LightZ,0,0,0,300)
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
		_Torches.DisableNoWait(True)
		GetLinkedRef(vMYC_ShrineLightingMaster).DisableNoWait(True)
	EndIf
	
	If iLightState == 1
		;Wait(1.5)
		If !_iQSTMG07MagnusStormCollegeMediumLPM && bUseTranslation
			_iQSTMG07MagnusStormCollegeMediumLPM = QSTMG07MagnusStormCollegeMediumLPM.Play(_Light)
		EndIf
		Wait(0.5)
		_Curtain.EnableNoWait(True)
	EndIf

	If iLightState == 0
		Wait(1)
		_Light.DisableNoWait()
	EndIf

	If !Is3DLoaded() && bUseTranslation ;We got unloaded mid-transition, probably because the player is naughty. Rerun with bUseTranslation off!
		SetAlcoveLightState(iNewLightState)
	EndIf
	_iAlcoveLightState = iLightState ; Set internal property value
	;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Set light state to " + _iAlcoveLightState + "!")
	RegisterForModEvent("vMYC_AlcoveLightStateComplete","OnAlcoveLightStateComplete")
	SendModEvent("vMYC_AlcoveLightStateComplete","",_iAlcoveLightState)
EndFunction

Event OnAlcoveLightStateChange(string eventName, string strArg, float numArg, Form sender)
{numArg: 0 = Dark, 1 = Full light, 2 = Torch light}
	If sender != Self 
		Return
	EndIf
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
	SendModEvent("vMYC_AlcoveStatueStateComplete","",_iAlcoveStatueState)
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
	AlcoveLightState = ALCOVE_LIGHTS_LOADING
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
	;ActivateAlcove()
	SendModEvent("vMYC_AlcoveLightingPriority","Release",AlcoveIndex)
	;Saving is done, return the character to the ground
	vMYC_ShrineLightISMD.PopTo(vMYC_ShrineLightWhiteoutISMD) ; white out in 2.5 seconds
	_bPlayerIsSaving = False
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
	Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": SummonCharacter!")
	AlcoveStatueState = ALCOVE_STATUE_SUMMONED
	CharacterManager.SetLocalInt(_sCharacterName,"InAlcove",0)
	_Book = GetLinkedRef(vMYC_ShrineBook) as vMYC_CharacterBookActiScript
	_Book.IsOpen = True
	_Book.IsGlowing = True
	;AlcoveActor.SetActorValue("Variable10",0)
	Wait(0.5)
	AlcoveActor.EnableAI(True)
	Wait(0.5)
	;If RandomInt(0,1)
		;AlcoveActor.PlayIdle(IdleSnapToAttention)
	;Else
	;EndIf
	vMYC_ValorFX.Play(AlcoveActor,5)
	Wait(0.5)
	AlcoveActor.PlayIdle(IdleSilentBow)
	Wait(0.5)
	DA02SummonValorTargetFX.Play(AlcoveActor,8)
	Wait(0.5)
	AlcoveActor.SetAlpha(0.01,True)
	Wait(5.0)
	AlcoveActor.Disable()
	AlcoveActor.SetScale(1.0)
	AlcoveActor.SetGhost(False)
	AlcoveActor.MoveToMyEditorLocation()
	AlcoveActor.EnableNoWait()
	AlcoveActor.EnableAI(True)
	AlcoveActor.EvaluatePackage()
	Wait(0.5)
	AlcoveActor.MoveToPackageLocation()
	String sCellName
	If AlcoveActor.GetParentCell()
		sCellName = AlcoveActor.GetParentCell().GetName()
	EndIf
	_Book.IsGlowing = False
	Wait(1.0)
	If sCellName == "vMYC_Staging" || sCellName == "vMYC_ShrineOfHeroes"  || sCellName == "Shrine of Heroes"
		Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Character got lost, sending them on...")
		CharacterManager.ResetCharacterPosition(CharacterName)
	EndIf
	AlcoveActor.SetAlpha(1.0)
	CharacterManager.SetLocalInt(_sCharacterName,"IsSummoned",1)
EndFunction

Function BanishCharacter()
{Banish the character from Tamriel back to the Alcove}
	;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": BanishCharacter!")
	_Book.IsOpen = False
	If Is3DLoaded()
		_Book.IsGlowing = True
	EndIf
	;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Disabling character tracking...")
	CharacterManager.SetCharacterTracking(CharacterName,False)
	;AlcoveActor.DisableNoWait(False)
	Wait(0.25)
	AlcoveActor.SetScale(0.01)
	;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Moving character to staging area...")
	CharacterManager.SetLocalInt(_sCharacterName,"InAlcove",1)
	AlcoveActor.MoveTo(_StatueMarker)
	WaitForCharacterReady()
	If WaitFor3DLoad(AlcoveActor)
		AlcoveActor.SetAlpha(0.01,False)
	EndIf
	;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Moving character to Alcove...")
	AlcoveActor.SetGhost(True)
	AlcoveActor.SetScale(1.2)
	If WaitFor3DLoad(AlcoveActor)
;		AlcoveActor.SetAlpha(0.01,False)
		DA02SummonValorTargetFX.Play(AlcoveActor,8)
		Wait(1.0)
	EndIf
	;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Fading in character...")
	AlcoveActor.SetAlpha(1.0,True)
	If Is3DLoaded()
		_Book.IsGlowing = False
	EndIf
	Wait(3.0)
	AlcoveActor.PlayIdle(IdleStaticPoseA)
	;AlcoveActor.DrawWeapon()
	Wait(0.25)
	;Debug.Trace("MYC/Shrine/Alcove" + _iAlcoveIndex + ": Freezing character!")
	AlcoveActor.EnableAI(False)
	AlcoveStatueState = ALCOVE_STATUE_PRESENT
	CharacterManager.SetLocalInt(_sCharacterName,"IsSummoned",0)
	AlcoveState = ALCOVE_STATE_READY
EndFunction

;==== Utility functions ====----

Function ResetAlcove()
	If AlcoveActor && !AlcoveActor.IsAIEnabled()
		ObjectReference kNowhere = GetFormFromFile(0x02004e4d,"vMYC_MeetYourCharacters.esp") as ObjectReference ; Marker in vMYC_StagingCell
		AlcoveActor.MoveTo(kNowhere)
	EndIf

	_bCharacterSummoned = False
	AlcoveActor = None
	ShrineOfHeroes.SetAlcoveStr(AlcoveIndex,"CharacterName","")
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
	AlcoveState = ALCOVE_STATE_BUSY
	String sCharacterName = CharacterName
	ShrineOfHeroes.SetAlcoveStr(AlcoveIndex,"CharacterName","")
	ReleaseActor()
	SavePlayer(True)
EndFunction

Function EraseAlcove()
	AlcoveState = ALCOVE_STATE_BUSY
	String sCharacterName = CharacterName
	ShrineOfHeroes.SetAlcoveStr(AlcoveIndex,"CharacterName","")
	ReleaseActor()
	ValidateAlcove()
	If sCharacterName
		CharacterManager.DeleteCharacterActor(sCharacterName)
	EndIf
	SendModEvent("vMYC_ForceBookUpdate","",AlcoveIndex)
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
