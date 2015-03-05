Scriptname vMYC_AlcoveLightingController extends ObjectReference
{Handle alcove activation/deactivation effects}

;=== Imports ===--

Import Utility
Import Game
Import vMYC_Registry

;=== Constants ===--
Int Property ALCOVE_LIGHTS_OFF	 	= 0 AutoReadOnly Hidden
Int Property ALCOVE_LIGHTS_BUSY		= 1 AutoReadOnly Hidden
Int Property ALCOVE_LIGHTS_ON	 	= 2 AutoReadOnly Hidden

;=== Properties ===--

Bool Property TorchShadows = False	Auto

Bool Property FogEnabled	= False			Auto

Int Property AlcoveLightState Hidden
	Int Function Get()
		Return _iAlcoveLightState
	EndFunction
	Function Set(Int aiAlcoveLightState)
		SetLightState(aiAlcoveLightState,True)
	EndFunction
EndProperty

Int Property DesiredLightState Hidden
	Int Function Get()
		Return _iDesiredLightState
	EndFunction
	Function Set(Int aiAlcoveLightState)
		SetLightState(aiAlcoveLightState)
	EndFunction
EndProperty

;=== Keywords ===--

Keyword Property vMYC_AlcoveAmbientBlue		Auto
Keyword Property vMYC_AlcoveAmbientTorch	Auto
Keyword Property vMYC_AlcoveFogFill			Auto
Keyword Property vMYC_AlcoveFogLow			Auto
Keyword Property vMYC_AlcoveFogWall			Auto
Keyword Property vMYC_AlcoveFogLit			Auto
Keyword Property vMYC_AlcoveTorchesNS		Auto
Keyword Property vMYC_AlcoveTorchesS		Auto
Keyword Property vMYC_AlcoveTorchesTrig		Auto

;=== Base forms to find objects with ===--

;enableparents
Activator		Property vMYC_AlcoveTorchShadowEnableParent		Auto
Activator		Property vMYC_AlcoveTorchNShadowEnableParent	Auto

;lights
Light			Property vMYC_ShrineActiveLight					Auto
Light			Property vMYC_ShrineActiveTorchLightS			Auto
Light			Property vMYC_ShrineActiveTorchLightNS			Auto
Light			Property vMYC_ShrineAmbientLight				Auto

;Fogs
Activator		Property vMYC_EmptyShrineFog					Auto
;Declared as form since MovableStatic isn't allowed
Form			Property FXAmbBeamSlowFogBig_Dim03				Auto
Form			Property FXFogRollingFacing01					Auto
Form			Property FXAmbBlowingFog01						Auto

;Torch glow
Static			Property FXGlowFillRoundBrt						Auto

;=== Objects ===--

ObjectReference Property AlcoveLightTorchNSPar	Auto 
{Torch noshadowlight parent}
ObjectReference Property AlcoveLightTorchSPar	Auto 
{Torch shadowlight parent}
ObjectReference Property AlcoveLightTorchAmb	Auto
{Torch ambiance (no shadow)}
ObjectReference Property AlcoveLightShrineAmb	Auto
{Shrine ambient light (blue)}
ObjectReference Property AlcoveFogDense			Auto
{Dense fog for filling alcove}
ObjectReference Property AlcoveFogFloor			Auto
{Floor mist}
ObjectReference Property AlcoveFogCurtain		Auto
{Fog wall for blocking alcove}
ObjectReference Property AlcoveFogLit			Auto
{Light rays shining from lit alcove}
ObjectReference Property AlcoveTorchTriggerBox	Auto
{Triggerbox for torch shadows, will be filled by vMYC_ShrineTorchShadowTrigScript.psc}

;=== Variables ===--

String _sFormID

Int _iAlcoveLightState = -1
Int _iDesiredLightState = -1

Bool _bForceLightState = False

;=== Events and Functions ===--

Function CheckVars()
	CheckObjects()
	If GetParentCell().IsAttached() && ( _iAlcoveLightState < 0 || _iDesiredLightState < 0 )
		SetLightState(ALCOVE_LIGHTS_OFF,True)
	EndIf
	If !ValidateLightState()
		_bForceLightState = True
		RegisterForSingleUpdate(1)
	EndIf
EndFunction

Event OnInit()
	DebugTrace("OnInit!")
EndEvent

Event OnLoad()
	DebugTrace("OnLoad!")
EndEvent

Event OnCellAttach()
	DebugTrace("OnCellAttach!")
	CheckVars()
EndEvent

Function SetLightState(Int aiDesiredLightState, Bool abForce = False)
{Set lights to desired state. abForce skips the transition.}
	;CheckObjects()
	DebugTrace("SetLightState(" + aiDesiredLightState + "," + abForce + ")")
	DebugTrace("AlcoveTorchTriggerBox is " + AlcoveTorchTriggerBox)
	_iDesiredLightState = aiDesiredLightState
	_bForceLightState = abForce
	If !Is3DLoaded()
		abForce = True ; Always skip transition if we're not loaded
	EndIf
	If abForce
		DebugTrace("FORCING Lightstate to " + _iDesiredLightState + "!")
		_bForceLightState = True
		SetupLightsAndFog(abForce)
		Return ; No need to continue, everything is set.
	EndIf
	RegisterForSingleUpdate(0.1)
EndFunction

Function SetupLightsAndFog(Bool abForce = False)
	DebugTrace("SetupLightsAndFog - _iDesiredLightState:" + _iDesiredLightState + " _iAlcoveLightState" + _iAlcoveLightState + "!")
	If _iDesiredLightState == _iAlcoveLightState && !abForce
		Return ; Nothing to do
	EndIf
	If abForce
		_bForceLightState = False
		DebugTrace("SetupLightsAndFog will FORCE the lighting setup!")
	EndIf
	If _iDesiredLightState == ALCOVE_LIGHTS_OFF
		ShowFog(True)
		AlcoveTorchTriggerBox.DisableNoWait()
		If AlcoveLightTorchSPar.IsEnabled()
			AlcoveLightTorchSPar.DisableNoWait()
		EndIf
		If AlcoveLightTorchNSPar.IsEnabled()
			AlcoveLightTorchNSPar.DisableNoWait()
		EndIf
		AlcoveLightTorchAmb.DisableNoWait(True)
		_iAlcoveLightState = ALCOVE_LIGHTS_OFF
		DebugTrace("Lights are now OFF!")
		If AlcoveFogLit.IsEnabled()
			AlcoveFogLit.DisableNoWait(True)
		EndIf
	ElseIf _iDesiredLightState == ALCOVE_LIGHTS_BUSY
		If !FogEnabled
			ShowFog(True)
		EndIf
		If !AlcoveLightTorchNSPar.IsEnabled()
			AlcoveLightTorchNSPar.EnableNoWait()
		EndIf
		If AlcoveLightTorchSPar.IsEnabled()
			AlcoveLightTorchSPar.DisableNoWait()
		EndIf
		AlcoveTorchTriggerBox.DisableNoWait(False)
		If !AlcoveLightTorchAmb.IsEnabled()
			AlcoveLightTorchAmb.EnableNoWait(True)
		EndIf
		If AlcoveFogLit.IsEnabled()
			AlcoveFogLit.DisableNoWait(True)
		EndIf
		_iAlcoveLightState = ALCOVE_LIGHTS_BUSY
		DebugTrace("Lights are now BUSY!")
	ElseIf _iDesiredLightState == ALCOVE_LIGHTS_ON
		AlcoveLightTorchAmb.EnableNoWait(True)
		If !AlcoveLightTorchNSPar.IsEnabled()
			AlcoveLightTorchNSPar.EnableNoWait()
		EndIf
		If AlcoveLightTorchSPar.IsEnabled()
			AlcoveLightTorchSPar.DisableNoWait()
		EndIf
		ShowFog(False)
		If !AlcoveFogLit.IsEnabled()
			AlcoveFogLit.EnableNoWait(True)
		EndIf
		AlcoveTorchTriggerBox.EnableNoWait(False)
		_iAlcoveLightState = ALCOVE_LIGHTS_ON
		DebugTrace("Lights are now ON!")
	EndIf
EndFunction

Bool Function ValidateLightState()
	If AlcoveLightState == ALCOVE_LIGHTS_OFF
		If !AlcoveFogCurtain.IsEnabled()
			Return False
		EndIf
		If !AlcoveFogDense.IsEnabled()
			Return False
		EndIf
		If !AlcoveFogFloor.IsEnabled()
			Return False
		EndIf
		If AlcoveTorchTriggerBox.IsEnabled()
			Return False
		EndIf
		If AlcoveLightTorchSPar.IsEnabled()
			Return False
		EndIf
		If AlcoveLightTorchNSPar.IsEnabled()
			Return False
		EndIf
		If AlcoveLightTorchAmb.IsEnabled()
			Return False
		EndIf
		If AlcoveFogLit.IsEnabled()
			Return False
		EndIf
	ElseIf _iDesiredLightState == ALCOVE_LIGHTS_BUSY
		If !AlcoveFogCurtain.IsEnabled()
			Return False
		EndIf
		If !AlcoveFogDense.IsEnabled()
			Return False
		EndIf
		If !AlcoveFogFloor.IsEnabled()
			Return False
		EndIf
		If AlcoveTorchTriggerBox.IsEnabled()
			Return False
		EndIf
		If AlcoveLightTorchSPar.IsEnabled()
			Return False
		EndIf
		If !AlcoveLightTorchNSPar.IsEnabled()
			Return False
		EndIf
		If !AlcoveLightTorchAmb.IsEnabled()
			Return False
		EndIf
		If AlcoveFogLit.IsEnabled()
			Return False
		EndIf
	ElseIf _iDesiredLightState == ALCOVE_LIGHTS_ON
		If AlcoveFogCurtain.IsEnabled()
			Return False
		EndIf
		If AlcoveFogDense.IsEnabled()
			Return False
		EndIf
		If AlcoveFogFloor.IsEnabled()
			Return False
		EndIf
		If !AlcoveTorchTriggerBox.IsEnabled()
			Return False
		EndIf
		If !(AlcoveLightTorchNSPar.IsEnabled() || AlcoveLightTorchSPar.IsEnabled()) ; either shadow or no-shadow lights should be on
			Return False
		EndIf
		If !AlcoveLightTorchAmb.IsEnabled()
			Return False
		EndIf
		If !AlcoveFogLit.IsEnabled()
			Return False
		EndIf
	EndIf
	Return True
EndFunction

Event OnUpdate()
	DebugTrace("OnUpdate - _iDesiredLightState:" + _iDesiredLightState + " _iAlcoveLightState" + _iAlcoveLightState + "!")
	SetupLightsAndFog(_bForceLightState)
EndEvent

Function ShowFog(Bool abShowFog = True)
	If abShowFog
		FogEnabled = True
		AlcoveFogCurtain.EnableNoWait(True)
		AlcoveFogDense.EnableNoWait(True)
		WaitMenuMode(0.25)
		AlcoveFogFloor.EnableNoWait(True)
	Else
		FogEnabled = False
		AlcoveFogDense.DisableNoWait(True)
		WaitMenuMode(0.25)
		AlcoveFogCurtain.DisableNoWait(True)
		AlcoveFogFloor.DisableNoWait(True)
	EndIf
EndFunction

Function CheckObjects()
	If !AlcoveLightTorchNSPar || !AlcoveFogCurtain
		FindObjects()
	EndIf
EndFunction

Function FindObjects()
	;AlcoveLightTorchNSPar = FindClosestReferenceOfTypeFromRef(vMYC_AlcoveTorchNShadowEnableParent,Self,800)
	;AlcoveLightTorchSPar = FindClosestReferenceOfTypeFromRef(vMYC_AlcoveTorchShadowEnableParent,Self,800)
	;AlcoveLightTorchAmb =  FindClosestReferenceOfTypeFromRef(vMYC_ShrineActiveLight,Self,800)
	;AlcoveLightShrineAmb =  FindClosestReferenceOfTypeFromRef(vMYC_ShrineAmbientLight,Self,800)
	;AlcoveFogDense =  FindClosestReferenceOfTypeFromRef(vMYC_EmptyShrineFog,Self,800)
	;
	;FXAmbBlowingFog01 = GetFormFromFile(0x00035267,"Skyrim.esm")
	;FXFogRollingFacing01 = GetFormFromFile(0x00034DB6,"Skyrim.esm")
	;FXAmbBeamSlowFogBig_Dim03 = GetFormFromFile(0x000A6C4D,"Skyrim.esm")
	;
	;AlcoveFogFloor =  FindClosestReferenceOfTypeFromRef(FXAmbBlowingFog01,Self,800)
	;AlcoveFogCurtain =  FindClosestReferenceOfTypeFromRef(FXFogRollingFacing01,Self,800)
	;AlcoveFogLit =  FindClosestReferenceOfTypeFromRef(FXAmbBeamSlowFogBig_Dim03,Self,800)
	;
	;While !AlcoveTorchTriggerBox
	;	DebugTrace("Waiting for AlcoveTorchTriggerBox...")
	;	Wait(1)
	;EndWhile

;Keyword Property vMYC_AlcoveAmbientBlue		Auto
;Keyword Property vMYC_AlcoveAmbientTorch	Auto
;Keyword Property vMYC_AlcoveFogFill			Auto
;Keyword Property vMYC_AlcoveFogLow			Auto
;Keyword Property vMYC_AlcoveFogWall			Auto
;Keyword Property vMYC_AlcoveFogLit			Auto
;Keyword Property vMYC_AlcoveTorchesNS		Auto
;Keyword Property vMYC_AlcoveTorchesS		Auto
;Keyword Property vMYC_AlcoveTorchesTrig		Auto

	GetLinkedRef(vMYC_AlcoveAmbientBlue)

	
	AlcoveLightTorchNSPar 	= GetLinkedRef(vMYC_AlcoveTorchesNS)
	AlcoveLightTorchSPar 	= GetLinkedRef(vMYC_AlcoveTorchesS)
	AlcoveLightTorchAmb 	= GetLinkedRef(vMYC_AlcoveAmbientTorch)
	AlcoveLightShrineAmb 	= GetLinkedRef(vMYC_AlcoveAmbientBlue)
	AlcoveFogDense 			= GetLinkedRef(vMYC_AlcoveFogFill)
	AlcoveFogFloor 			= GetLinkedRef(vMYC_AlcoveFogLow)
	AlcoveFogCurtain 		= GetLinkedRef(vMYC_AlcoveFogWall)
	AlcoveFogLit 			= GetLinkedRef(vMYC_AlcoveFogLit)
	AlcoveTorchTriggerBox	= GetLinkedRef(vMYC_AlcoveTorchesTrig)
	
	DebugTrace("AlcoveFogCurtain is " + AlcoveFogCurtain + ", AlcoveLightTorchSPar is " + AlcoveLightTorchSPar + ", AlcoveTorchTriggerBox is " + AlcoveTorchTriggerBox)
EndFunction

;=== Utility functions ===--

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	If !_sFormID
		_sFormID = GetFormIDString(Self)
	EndIf
	Debug.Trace("MYC/AlcoveLightingController/" + _sFormID + ": " + sDebugString,iSeverity)
	FFUtils.TraceConsole(sDebugString)
EndFunction

String Function GetFormIDString(Form kForm)
	String sResult
	sResult = kForm as String ; [FormName < (FF000000)>]
	sResult = StringUtil.SubString(sResult,StringUtil.Find(sResult,"(") + 1,8)
	Return sResult
EndFunction

Bool Function WaitFor3DLoad(ObjectReference kObjectRef, Int iSafety = 20)
	While !kObjectRef.Is3DLoaded() && iSafety > 0
		iSafety -= 1
		Wait(0.1)
	EndWhile
	Return iSafety as Bool
EndFunction
